package testing

import (
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
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
	time.Sleep(30 * time.Second)
	statusCode := DoGetRequest(t, stageUrl)
	assert.Equal(t, 200, statusCode)
}

func DoGetRequest(t *testing.T, url string) int {
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello World!", 10, 5*time.Second)
	return 1
}
