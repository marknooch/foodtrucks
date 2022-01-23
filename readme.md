# Goals

I found some foodtruck data on the internet and I'd like to demonstrate how we can mash up terraform with github actions to do something fun with the data.

# Approach

0. Get [Atlantis](https://runatlantis.io/) configured for our repo
1. Write some terraform which gives our files a home on the internet
2. Create a scheduled github action which:
```
    a. transforms the files into a GeoJSON file which contains all of the food trucks that are currently open 
    b. commits it to a data branch in the repo so we can see how it changes through time
    c. deploys the files to our home on the internet
```
3. Create a webpage which uses leaflet to render the GeoJSON
4. Add amazon's CDN to the front of the thing using terraform adjust cache settings so the GeoJSON doesn't get stale
5. Configure a custom domain name for it

# Configure your local development environment

I used VS Code and [the recommended extensions](.vscode/extensions.json) to develop this.  
1.  Configure your AWS credentials using the toolkit.  
2.  Enter the `terraform-bootstrap` directory and `terraform apply` to create the s3 backend bucket.  
3.  Create a github PAT and set the GITHUB_TOKEN environment variable that the github terraform provider utilizes in your atlantis and local development environment

I decided to not use atlantis to create the s3 backend for the state for the app because I was concerned about a circular dependency.  Some poeple use [custom workflows in Atlantis](https://www.runatlantis.io/docs/custom-workflows.html#use-cases) to store terraform state files in a backend consistently.  I would look into this if I were building out Atlantis for a large group of people to use together to reduce the configuration duplication, developer friction, and huamn error risk associated with not storing terraform's state appropriately.

The [terraform code](https://github.com/MarkIannucci/terraform-aws-atlantis/tree/PersistInEFS) I used to deploy Atlantis on AWS is a WIP which I plan to submit to [fix this issue](https://github.com/terraform-aws-modules/terraform-aws-atlantis/issues/206).

# Things I'd do differently if I had more time

* I'd write the script that commits the files to the data branch to only commit data to the data branch if it were running from the main branch.  If it were running from any other branch, it'd commit the files to the data-branchname branch.  The current config could easily split brain.  Additionally the approach to branch switching that I'm using currently makes continued progress on github actions quite clunky.  See [commit fbe6548c](https://github.com/marknooch/foodtrucks/commit/fbe6548c587d931dd31a8b67ce2c1e04dbbb2215) for an example of the clunk.
* Figure out how to configure Atlantis + github to require an apply if necessary for a PR to be completed. #24
* Implement mapbox pubic token creation/rotation with a github action -- current implementation embeds the public access token in source and is [secret sprawly](https://www.hashicorp.com/resources/what-is-secret-sprawl-why-is-it-harmful).  ~~The token has an access policy allowing it to only be accessed from domains I control.~~ once we implement #18.
* Some of the content could be easily hosted on github which would have reduced the github actions complexity and AWS cost.

# Things that are missing that I might implement in the future

* Storing the data as it evolves over time in git is neat intellectually.  It can be a nice start to doing something interesting tracking the trucks moving through time.
* I didn't implement any telemetry so any user usage data can only come from whatever is in Amazon's s3 logs by default.  
* I'd implement [Infracost](https://github.com/infracost/infracost-atlantis).  With this stuff all being priced based on consumption, It'd be interesting to see how infracost prices it.  I do think it is important that developers get an early sense of the cost of their code and it looks like that product would be a fantastic way to have a conversation about it.  

# Things that I learned

* This was a fun exploration of AWS.  To this point, my work in the cloud involved using terraform to manage Azure resources.  It was nice to see those skills transfer to AWS quickly.
* I recently ran across [Act](https://github.com/nektos/act) which lets you run github actions locally.  I wish I knew about that at the outset -- [PR #16](https://github.com/marknooch/foodtrucks/pull/16) would have been much cleaner.  
* writing DRY HCL is difficult.  [CloudPosse](https://github.com/cloudposse) has published quite a few modules which I would explore in an enterprise setting.
* Apply errors are common.  I'd use [terraform's workspace](https://www.terraform.io/language/state/workspaces) functionality to test `apply` steps as part of the pull request process in a team environment.
* I'd rather write HCL than a resume :) 
