# Simple Lambda Webhook

A lambda function behind a webhook that returns a response from `curl`.

## Description

Contains the `terraform` and the source code.
Lambda uses best practices, kms encryption, dead letter queue and etc.

It uses [apigatewayv2_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) from `terraform` to implement a [`quick-start` api gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api#argument-reference)

> target - (Optional) Part of quick create. Quick create produces an API with an integration, a default catch-all route, and a default stage which is configured to automatically deploy changes. For HTTP integrations, specify a fully qualified URL. For Lambda integrations, specify a function ARN. The type of the integration will be HTTP_PROXY or AWS_PROXY, respectively. Applicable for HTTP APIs.

There should be IAM settings for everything to work.

### Outputs:

```bash
api_endpoint = "https://xyz123.execute-api.eu-west-1.amazonaws.com"
```

## Getting Started

### Dependencies

You would need `AWS` credentials in your shell for this to work.
We reccomend you setup and use `aws-vault`

### Installing

* `terraform init` <- Downloads and installs the terraform modules you need.
* `terraform plan -var="aws_region=eu-west-1" -var="name=test"` <- Shows you what would be created in AWS
* `terraform apply -var="aws_region=eu-west-1" -var="name=test"`<- Actually creates the stuff
* `terraform destroy -var="aws_region=eu-west-1" -var="name=test"` <- Tears everything down, you don't want to spend money!

### Testing

Uses a `terratest` [github action](https://github.com/fac/terratest-github-action) to run the tests in [/test](/test) which check the endpoint for the correct response.

## Version History

* 0.1
    * Initial Release
* 0.2
    * Tests

## TODO

- [x] Create terraform for `lambda`
- [x] Create terraform for `apigateway`
- [x] Testing