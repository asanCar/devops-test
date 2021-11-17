# Terraform template to deploy "test-app" in AWS

The aim of this Terraform module is to deploy the "test-app" application in AWS, with all the infrastructure required for High Availability architecture.

## Prerequisites

To run this template you need first to configure AWS credentials using one of the methods described in [AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication).

Also you will need to define the environment variable `AWS_DEFAULT_REGION` with the region name where do you want to deploy all the components described in this module.

You need to provide user credentials to download the `https://server.com/testapp-autoupdater` script, using Terraform variables `autoupdater_server_username` and `autoupdater_server_pass`.
