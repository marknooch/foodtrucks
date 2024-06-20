Install-Module JoinModule -RequiredVersion 3.6.0 -Force  # given more time, we'd fork, build, and package to reduce supply chain injection attacks; for now we'll pin to a particular version
new-item "../../data" -itemtype Container -Force

# get the permits file and filter to ones that are approved
$permitspath = "../../data/permits.csv"
Invoke-WebRequest -Uri "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv" -OutFile $permitspath
$permits = Import-Csv $permitspath | where-object { $_.Status -eq "APPROVED" }  
write-host "Downloaded and imported the permits.  There are $($permits.count) permits in the file"

# get the schedules file and filter to ones that are open now
$schedulespath = "../../data/schedules.csv"
Invoke-WebRequest -Uri "https://data.sfgov.org/api/views/jjew-r69b/rows.csv" -OutFile $schedulespath
$now = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"Pacific Standard Time") # TODO: deal with daylight savings time #32
$dayOfWeek = $now.DayOfWeek
$timeOfDay = $now.TimeOfDay
$schedules = import-csv $schedulespath | where-object { $_.DayOfWeekStr -eq $dayOfWeek }
$schedulesNo2400s = foreach ($schedule in $schedules) {
    if($schedule.end24 -eq "24:00") {$schedule.end24 = "23:59"}
    $schedule
}
$ScheduledFoodTrucks = $schedulesNo2400s | Where-Object {$_.start24 -le $timeOfDay} | Where-Object {$timeOfDay -le $_.end24}
write-host "Downloaded and imported the schedules.  There are $($ScheduledFoodTrucks.count) scheduled right now"

if ($ScheduledFoodTrucks.Count -eq 0) 
{
    # there probably aren't any food trucks open right now 
    # create empty files that don't break the website 
} else {
    
    # join the two objects together to find all of the approved food trucks that are open right now --- save that output
    $openfoodtruckspath = "../../data/openfoodtrucks.csv"
    $openFoodTrucks = $permits | InnerJoin-Object $ScheduledFoodTrucks -On permit
    $openFoodTrucks | ConvertTo-Csv > $openfoodtruckspath
    write-host "created the open food trucks.  There are $($openfoodtrucks.count) open right now"

    if ($openFoodTrucks.count -gt 0)
    {
        # confirm we have Latitude and Longitude in our source data.  If we don't error and do something about it in github actions
        $nullLongitude = $openFoodTrucks | where-object { $null -eq $_.Longitude }
        $nullLatitude = $openFoodTrucks | where-object { $null -eq $_.Latitude } 
        if ($nullLatitude + $nullLongitude -gt 0 )
        {
            exit 1
        }
    }

    # now produce the GeoJSON
    $features = foreach ($foodTruck in $openFoodTrucks) {
        [string[]]$coordinates = @()
        $coordinates+= $foodTruck.Longitude[0]
        $coordinates+= $foodTruck.Latitude[1]
        $foodtruckFeature = @{}
        $foodtruckFeature.Add("type","Feature")
        $foodtruckFeature.Add("properties", @{
            fooditems = $foodTruck.FoodItems
            applicant = $foodtruck.ApplicantS    
        })
        $foodtruckFeature.Add("geometry", @{
            type = "Point"
            coordinates = $coordinates 
            })
        $foodtruckFeature
    }
}

$openfoodtrucksjsonpath = "../../data/openFoodTrucks.json"
$featureCollection = @{
    type = "FeatureCollection"
    features = $features
}
ConvertTo-Json -InputObject $featureCollection -Depth 100 > $openfoodtrucksjsonpath
write-host "produced the open food trucks json"