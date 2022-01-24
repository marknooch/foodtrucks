# Welcome

I found some [foodtruck data](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat) on the internet and I'd like to demonstrate how we can combine AWS, Terraform, and GitHub Actions to capture the data as it evolves and render it on the internet.  This project uses [Atlantis](https://runatlantis.io) to assist with Terraform collaboration.

I documented my [high level approach](./approach.md) early on, and stayed pretty close to it throughout.  The issues and pull reuqests have more details on the work that I completed.  I also added a page about [my goals (both personal and for the project)](./goals.md) which I wrote in retrospect.

# Configure your local development environment

I used VS Code and [the recommended extensions](.vscode/extensions.json) to develop this.  
1.  Configure your AWS credentials using the toolkit extension.  
2.  Enter the `terraform-bootstrap` directory run `terraform init` followed by `terraform apply` to create the s3 backend bucket.  
3.  Fork this repo and set the `domain-name` and `github-repo` variables to your values in your [`terraform.tfvars` file](https://www.terraform.io/language/values/variables).  Update the 
4.  Create a [github PAT](https://github.com/settings/tokens) and set the GITHUB_TOKEN environment variable to your PAT.  This will allow the github terraform provider to set secret values in your repo and will ensure that GitHub Actions can authenticate with AWS when necessary.
5.  Enter the `terraform` directory and run `terraform init` followed by `terraform apply` to create the cloud resources.  I used [an external provider](https://freenom.com) for my domain name which may cause an apply error if Amazon or Terraform validate that the nameservers are the ones specified by the registrar.  If that happens, you can probably fix it by updating the nameservers to the ones for the Route 53 hosted zone this module creates.

I decided to store the Terraform which I used to create the s3 bucket for [the backend state](https://www.terraform.io/language/state/backends) in a separate module in order to reduce the blast radius which is why you'll find it in the terraform-bootstrap folder.  I did not allow Atlantis to plan and apply the backend at the time that I created it which is why you see it excluded from the autoplan functionality in [atlantis.yaml](./atlantis.yaml).  Some poeple use [custom workflows in Atlantis](https://www.runatlantis.io/docs/custom-workflows.html#use-cases) to store terraform state files in a backend consistently.  I would look into this if I were building out Atlantis for a large group of people to use together to reduce the configuration duplication, developer friction, and huamn error risk associated with not storing terraform's state appropriately.

## This is a lot of code to review.  Where do you recommend I start?

A few highlights --- 
* In [createGeoJson.ps1](./.github/workflows/createGeoJson.ps1), I used an open source module to join data from two csv files and filter the results to the foodtrucks that have an approved permit and are currently open.  I enjoy using PowerShell for this sort of thing because it has built in cmdlets which convert all kinds of data to native powershell objects and then you can do stuff with them using other PowerShell cmdlets.  The good lines are 7, 16-21, and 32.  Powershell is cross platform now too.  That code is running on an ubuntu VM.
* In [createGeoJson.yaml](./github/workflows/createGeoJson.yaml), I use GitHub Actions' conditional expression to make everyones lives easier by invalidating the cache on each completed pull request (lines 66-71)
* In [github-actions.tf](./terraform/github-actions.tf), I avoid the curse of Secret Sprawl and hardcoded config as code.  With terraform managing the github-actions AWS user, we're able to inject the secrets necessary for GitHub Actions to Authenticate with AWS as we create them.  In thinking about the functionality that this lacks over Vault or a more proper key management system, the only thing that comes to mind is that we don't have a good way that I know of to cycle the secrets.
* Tests?  Generally, my theory with this code is that we'd want the errors to happen in GitHub.  So. in [createGeoJson.ps1](./.github/workflows/createGeoJson.ps1), I do some file sanity checking that San Francisco didn't change their files on lines 38-44.  


## Things I'd do differently if I had more time

* I'd rework the middle portion of the github action which commits the files to the data branch to only commit data to the data branch if it were running from the main branch.  #33 
* Figure out how to configure Atlantis + github to require an apply if necessary for a PR to be completed. #24
* Implement mapbox pubic token creation/rotation with a github action -- current implementation embeds the public access token in source and is [secret sprawly](https://www.hashicorp.com/resources/what-is-secret-sprawl-why-is-it-harmful).  The token has an access policy allowing it to only be accessed from domains I control which required me to implement #18.
* Some of the content could be easily hosted on github which would have reduced the github actions complexity and AWS cost.
* Implement a test to ensure that the GeoJSON file we produce is correct.  This was part of the original scope but I cut it in #11 when the gneric JSON schema validation github action I found threw some errors which may be accurate, but the file still gets rendered by leaflet (so right for the wrong reasons).

## Things that are missing that I might implement in the future

* Storing the data as it evolves over time in git is neat intellectually.  It can be a nice start to doing something interesting tracking the trucks moving through time.
* I didn't implement any telemetry so any user usage data can only come from whatever is in Amazon's s3 logs by default.  
* I'd implement [Infracost](https://github.com/infracost/infracost-atlantis).  With this stuff all being priced based on consumption, It'd be interesting to see how infracost prices it.  I do think it is important that developers get an early sense of the cost of their code and it looks like that product would be a fantastic way to have a conversation about it.
  

## Things that I learned

* This was a fun exploration of AWS.  To this point, my work in the cloud involved using terraform to manage Azure resources.  It was nice to see those skills transfer to AWS quickly.
* I recently ran across [Act](https://github.com/nektos/act) which lets you run github actions locally.  I wish I knew about that at the outset -- [PR #16](https://github.com/marknooch/foodtrucks/pull/16) would have been much cleaner.  
* writing DRY HCL is difficult.  [CloudPosse](https://github.com/cloudposse) has published quite a few modules which I would explore in an enterprise setting.  I think it may be possible to do that with [template files](https://www.terraform.io/language/functions/templatefile), but was unable to figure it out.  I explored that in the [NeedToFigureOutTemplateFiles branch](https://github.com/marknooch/foodtrucks/tree/NeedToFigureOutTemplateFiles).  I ran into problems embedding values in the variables in the file.  An alternate approach would be to use a loop in terraform and iterate over it.  #27
* Apply errors are common.  I'd use [terraform's workspace](https://www.terraform.io/language/state/workspaces) functionality to test `apply` steps as part of the pull request process in a team environment.
* I'd rather write HCL than a resume :) 
