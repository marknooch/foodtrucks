# Project Goals

* We'll use Infrastructure as code to manage our cloud resources.  Changes required to those resources will occur with pull requests.  There should not be a need to login to a cloud console to provision resources.
* We'll deploy any changes to our application (including the data it depends on) using GitHub Actions.

# Project Non-goals

* Produce a project with perfect code.  Those things never ship.  We'll do the reverse, we'll spend time focusing on shipping quickly which encourage us to refactor and improve our code when we find that [it isn't as elegant as we'd like](https://github.com/marknooch/foodtrucks/pull/21).

# Personal Goals

* Determine how transferrable my Terraform skills are from Azure to AWS.  I found that they were :)
* Create a repo which will allow me to test [my fork of an Atlantis on AWS terraform module](https://github.com/MarkIannucci/terraform-aws-atlantis/tree/PersistInEFS) as I work to finish the pull request to fix [an issue with lost locks on redeployments](https://github.com/terraform-aws-modules/terraform-aws-atlantis/issues/206).
* Improve my familiarity with GitHub Actions.  I've used Azure DevOps Pipelines quite a bit.  Given the prevalence of GitHub in the open source community, improving my familiarity with GitHub actions will be an appreciating asset.