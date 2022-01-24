# grant access to github-actions AWS account.  In an enterprise setting, I'd look at storing the secret in Vault 
# and then using a gihub action to fetch the secret from vault.  This still has the problem of how does the 
# action authenticate with Vault.  With a hosted runner, we could use environment variables to provision access
# at worst case.  I'd look to use the github jwt option first though.
resource "aws_iam_user" "github-actions" {
  name = "github-actions"
}

resource "aws_iam_access_key" "github-actions" {
  user = aws_iam_user.github-actions.name
}

resource "aws_iam_user_policy_attachment" "github-actions" {
  user       = aws_iam_user.github-actions.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

# populate secrets in repo for github actions account programmatically
data "github_repository" "repo" {
  full_name = var.github-repo
}

resource "github_actions_secret" "AWS_ACCESS_KEY_ID" {
  repository      = data.github_repository.repo.name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.github-actions.id
}

resource "github_actions_secret" "AWS_SECRET_ACCESS_KEY" {
  repository      = data.github_repository.repo.name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.github-actions.secret
}

# this is a hack.  By doing this I can let the terraform region dictate the region that we use in the github actions.  
# Ideally we'd obtain these non-secret values from the files themselves and avoid this circling back approach I used here.
resource "github_actions_secret" "AWS_REGION" {
  repository      = data.github_repository.repo.name
  secret_name     = "AWS_REGION"
  plaintext_value = var.region
}

resource "github_actions_secret" "S3_BUCKET" {
  repository      = data.github_repository.repo.name
  secret_name     = "S3_BUCKET"
  plaintext_value = aws_s3_bucket.s3-home.bucket
}
