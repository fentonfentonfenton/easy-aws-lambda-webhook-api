package testing

import (
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
	"time"
)

func TestApiGateway(t *testing.T) {
	name := "tests"
	awsRegion := "eu-west-1"
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
			"name":       name,
		},
	})
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	stageUrl := terraform.Output(t, terraformOptions, "api_endpoint")
	http_helper.HttpGetWithRetry(t, stageUrl, nil, 200, "Hello World!", 5, 5*time.Second)
	println("Tested OK") // Fails if the above method fails.
}
