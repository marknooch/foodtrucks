Install-Module JoinModule -RequiredVersion 3.6.0 -Force  # given more time, we'd fork, build, and package to reduce supply chain injection attacks; for now we'll pin to a particular version
new-item "../../data" -itemtype Container -Force

# get the permits file and filter to ones that are approved
Invoke-WebRequest -Uri "https://data.sfgov.org/api/views/rqzj-sfat/rows.csv" -OutFile ./permits.csv
$permits = Import-Csv "../../data/permits.csv" | where-object { $_.Status -eq "APPROVED" }  
write-host "Downloaded and imported the permits"

# get the schedules file and filter to ones that are open now
Invoke-WebRequest -Uri "https://data.sfgov.org/api/views/jjew-r69b/rows.csv" -OutFile ./schedules.csv
$dayOfWeek = (get-date).DayOfWeek
$schedules = import-csv "../../data/schedules.csv" | where-object { $_.DayOfWeekStr -eq $dayOfWeek }
$schedulesNo2400s = foreach ($schedule in $schedules) {
    if($schedule.end24 -eq "24:00") {$schedule.end24 = "23:59"}
    $schedule
}
$ScheduledFoodTrucks = $schedulesNo2400s | Where-Object {$_.start24 -le $timeOfDay} | Where-Object {$timeOfDay -le $_.end24}
write-host "Downloaded and imported the schedules"

# join the two objects together to find all of the approved food trucks that are open right now --- save that output
$openFoodTrucks = $permits | InnerJoin-Object $ScheduledFoodTrucks -On permit
Export-Csv -InputObject $openFoodTrucks -Path "../../data/openfoodtrucks.csv"
write-host "created the open food trucks"

# now produce the GeoJSON
$features = foreach ($foodTruck in $openFoodTrucks) {
    [string[]]$coordinates = @()
    $coordinates+= $foodTruck.Longitude[0]
    $coordinates+= $foodTruck.Latitude[1]
    $foodtruckFeature = @{}
    $foodtruckFeature.Add("type","Feature")
    $foodtruckFeature.Add("properties", @{popupContent = $foodTruck.FoodItems})
    $foodtruckFeature.Add("geometry", @{
        type = "Point"
        coordinates = $coordinates 
        })
    $foodtruckFeature
}
$featureCollection = @{
    type = "FeatureCollection"
    features = $features
}
ConvertTo-Json -InputObject $featureCollection -Depth 100 > "../../data/openFoodTrucks.json"
write-host "produced the open food trucks json"