# Goals

I found some foodtruck data on the internet and I'd like to demonstrate how we can mash up terraform with github actions to do something fun with the data.

# Approach

0. Get Atlantis configured for our repo
1. Write some terraform which gives our files a home on the internet
2. Create a scheduled github action which:
    a. transforms the files into a GeoJSON file which contains all of the food trucks that are currently open 
    b. commits it to a data branch in the repo so we can see how it changes through time
    c. deploys the files to our home on the internet
3. Create a webpage which uses leaflet to render the GeoJSON
4. Add amazon's CDN to the front of the thing using terraform adjust cache settings so the GeoJSON doesn't get stale
5. Configure a custom domain name for it

# Configure your local development environment

<<<<<<< Updated upstream
I used VS Code and the [AWS Toolkit](https://aws.amazon.com/visualstudiocode/) extension to develop this.  Configure your AWS credentials using the toolkit.  Enter the `terraform-bootstrap` directory and `terraform apply` to create the s3 backend bucket.  I decided to not use atlantis to create the s3 backend for the state for the app because I was concerned about a circular dependency.  Some poeple use [custom workflows in Atlantis](https://www.runatlantis.io/docs/custom-workflows.html#use-cases) to store terraform state files in a backend consistently.  I would look into this if I were building out Atlantis for a large group of people to use together to reduce the configuration duplication, developer friction, and huamn error risk associated with not storing terraform's state appropriately.
=======
I used VS Code and [the recommended extensions](.vscode/extensions.json) to develop this.  
1.  Configure your AWS credentials using the toolkit.  
2.  Enter the `terraform-bootstrap` directory and `terraform apply` to create the s3 backend bucket.  
3.  Create a github PAT and set the GITHUB_TOKEN environment variable that the github terraform provider utilizes in your atlantis and local development environment

I decided to not use atlantis to create the s3 backend for the state for the app because I was concerned about a circular dependency.  Some poeple use [custom workflows in Atlantis](https://www.runatlantis.io/docs/custom-workflows.html#use-cases) to store terraform state files in a backend consistently.  I would look into this if I were building out Atlantis for a large group of people to use together to reduce the configuration duplication, developer friction, and huamn error risk associated with not storing terraform's state appropriately.

# Things I'd do differently if I had more time

* I'd write the script that commits the files to the data branch to only commit data to the data branch if it were running from the main branch.  If it were running from any other branch, it'd commit the files to the data-branchname branch.  The current config could easily split brain.
>>>>>>> Stashed changes
