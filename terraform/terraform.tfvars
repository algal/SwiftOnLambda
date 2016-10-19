#
# MUST be updated for use
# 

# update the below to a DNS-prefixed bucket name to ensure global uniqueness
s3_bucket = "com.alexisgallagher.swiftlambda2"

#
# MAY be adjusted independently
#

# user!  update the below to your region of choice
region = "us-east-1"

environment = "Dev"
lambda_function_name = "lambdaTester"

#
# MUST be adjusted in tandem with the Makefile
# 

# the builddir must be equal to BUILDDIR in the Makefile
# the filename must be aligned with LAMBDA_DEPLOYMENT_PACKAGE_NAME in Makefile
lambdazip = "../build/lambda_deployment_package.zip"

