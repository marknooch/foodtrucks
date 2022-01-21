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

I used VS Code and [the recommended extensions](.vscode/extensions.json) to develop this.  
1.  Configure your AWS credentials using the toolkit.  
2.  Enter the `terraform-bootstrap` directory and `terraform apply` to create the s3 backend bucket.  

I decided to not use atlantis to create the s3 backend for the state for the app because I was concerned about a circular dependency.  Some poeple use [custom workflows in Atlantis](https://www.runatlantis.io/docs/custom-workflows.html#use-cases) to store terraform state files in a backend consistently.  I would look into this if I were building out Atlantis for a large group of people to use together to reduce the configuration duplication, developer friction, and huamn error risk associated with not storing terraform's state appropriately.
