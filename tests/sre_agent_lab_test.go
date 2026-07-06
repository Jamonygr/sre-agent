package test

import (
	"encoding/json"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type testEnv struct {
	environment                   string
	locationShort                 string
	azureSreAgentLocationShort    string
	azureSreAgentName             string
	azureDevOpsRepoName           string
	azureDevOpsRepoURL            string
	validatePortalVisibleSreAgent bool
	validateAzureDevOpsRepo       bool
}

func currentTestEnv() testEnv {
	env := os.Getenv("TEST_ENVIRONMENT")
	if env == "" {
		env = "lab"
	}

	locationShort := os.Getenv("TEST_LOCATION_SHORT")
	if locationShort == "" {
		locationShort = "wus2"
	}

	azureSreAgentLocationShort := os.Getenv("TEST_AZURE_SRE_AGENT_LOCATION_SHORT")
	if azureSreAgentLocationShort == "" {
		azureSreAgentLocationShort = "eus2"
	}

	azureSreAgentName := os.Getenv("TEST_AZURE_SRE_AGENT_NAME")
	if azureSreAgentName == "" {
		azureSreAgentName = "sreag-" + env
	}

	azureDevOpsRepoName := os.Getenv("TEST_AZURE_DEVOPS_REPO_NAME")
	if azureDevOpsRepoName == "" && env == "ado-lab" {
		azureDevOpsRepoName = "Azureboards"
	}

	azureDevOpsRepoURL := os.Getenv("TEST_AZURE_DEVOPS_REPO_URL")
	if azureDevOpsRepoURL == "" && env == "ado-lab" {
		azureDevOpsRepoURL = "https://dev.azure.com/Beyondcloudwithchriz/Azureboards/_git/Azureboards"
	}

	return testEnv{
		environment:                   env,
		locationShort:                 locationShort,
		azureSreAgentLocationShort:    azureSreAgentLocationShort,
		azureSreAgentName:             azureSreAgentName,
		azureDevOpsRepoName:           azureDevOpsRepoName,
		azureDevOpsRepoURL:            azureDevOpsRepoURL,
		validatePortalVisibleSreAgent: os.Getenv("TEST_VALIDATE_AZURE_SRE_AGENT") == "true",
		validateAzureDevOpsRepo:       os.Getenv("TEST_VALIDATE_AZURE_DEVOPS_REPO") == "true",
	}
}

func (e testEnv) rg(role string) string {
	return "rg-" + role + "-sreag-" + e.environment + "-" + e.locationShort
}

func (e testEnv) vnet(role string) string {
	return "vnet-" + role + "-sreag-" + e.environment + "-" + e.locationShort
}

func (e testEnv) logAnalyticsWorkspace() string {
	return "log-sreag-" + e.environment + "-" + e.locationShort
}

func (e testEnv) azureSreAgentResourceGroup() string {
	return "rg-sreagent-sreag-" + e.environment + "-" + e.azureSreAgentLocationShort
}

func azResourceCount(t *testing.T, resourceGroupName string, resourceType string) int {
	t.Helper()

	output, err := exec.Command(
		"az",
		"resource",
		"list",
		"--resource-group", resourceGroupName,
		"--resource-type", resourceType,
		"--query", "[].id",
		"-o", "tsv",
	).CombinedOutput()
	assert.NoError(t, err, "az resource list failed: %s", string(output))

	count := 0
	for _, line := range strings.Split(strings.TrimSpace(string(output)), "\n") {
		if strings.TrimSpace(line) != "" {
			count++
		}
	}
	return count
}

func azResourceExists(t *testing.T, resourceGroupName string, resourceType string, name string) bool {
	t.Helper()

	output, err := exec.Command(
		"az",
		"resource",
		"show",
		"--resource-group", resourceGroupName,
		"--resource-type", resourceType,
		"--name", name,
		"--query", "id",
		"-o", "tsv",
	).CombinedOutput()
	if err != nil {
		t.Logf("az resource show failed: %s", string(output))
		return false
	}

	return strings.TrimSpace(string(output)) != ""
}

func azResourceValue(t *testing.T, args ...string) string {
	t.Helper()

	output, err := exec.Command("az", args...).CombinedOutput()
	require.NoError(t, err, "az command failed: %s", string(output))

	return strings.TrimSpace(string(output))
}

func azureSreAgentRepos(t *testing.T, env testEnv) string {
	t.Helper()

	endpoint := azResourceValue(
		t,
		"resource", "show",
		"--resource-group", env.azureSreAgentResourceGroup(),
		"--resource-type", "Microsoft.App/agents",
		"--name", env.azureSreAgentName,
		"--api-version", "2025-05-01-preview",
		"--query", "properties.agentEndpoint",
		"-o", "tsv",
	)
	require.NotEmpty(t, endpoint)

	token := azResourceValue(
		t,
		"account", "get-access-token",
		"--resource", "https://azuresre.dev",
		"--query", "accessToken",
		"-o", "tsv",
	)
	require.NotEmpty(t, token)

	client := http.Client{Timeout: 30 * time.Second}
	request, err := http.NewRequest(http.MethodGet, strings.TrimRight(endpoint, "/")+"/api/v2/repos", nil)
	require.NoError(t, err)
	request.Header.Set("Authorization", "Bearer "+token)

	response, err := client.Do(request)
	require.NoError(t, err)
	defer response.Body.Close()

	output, err := io.ReadAll(response.Body)
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, response.StatusCode, string(output))

	return string(output)
}

func TestCoreResourceGroups(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set")
	}

	env := currentTestEnv()
	for _, rg := range []string{env.rg("network"), env.rg("windows"), env.rg("sre"), env.rg("governance")} {
		group := azure.GetAResourceGroup(t, rg, subscriptionID)
		assert.NotNil(t, group)
		assert.NotNil(t, group.Tags)
	}
}

func TestNetworkExists(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set")
	}

	env := currentTestEnv()
	assert.True(t, azure.VirtualNetworkExists(t, env.vnet("hub"), env.rg("network"), subscriptionID))
	assert.True(t, azure.VirtualNetworkExists(t, env.vnet("management"), env.rg("network"), subscriptionID))
	assert.True(t, azure.VirtualNetworkExists(t, env.vnet("workload"), env.rg("network"), subscriptionID))
}

func TestSreWorkspaceAndAgentExist(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set")
	}

	env := currentTestEnv()
	assert.True(t, azure.LogAnalyticsWorkspaceExists(t, env.logAnalyticsWorkspace(), env.rg("sre"), subscriptionID))
	assert.Greater(t, azResourceCount(t, env.rg("sre"), "Microsoft.Automation/automationAccounts"), 0)
}

func TestSreTelemetryResourcesExist(t *testing.T) {
	t.Parallel()

	if os.Getenv("ARM_SUBSCRIPTION_ID") == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set")
	}

	env := currentTestEnv()
	assert.Greater(t, azResourceCount(t, env.rg("sre"), "Microsoft.Insights/dataCollectionRules"), 0)
	assert.Greater(t, azResourceCount(t, env.rg("sre"), "Microsoft.Insights/actionGroups"), 0)
	assert.Greater(t, azResourceCount(t, env.rg("sre"), "Microsoft.Insights/scheduledQueryRules"), 0)
}

func TestAzureSreAgentExists(t *testing.T) {
	t.Parallel()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	if subscriptionID == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set")
	}

	env := currentTestEnv()
	if !env.validatePortalVisibleSreAgent {
		t.Skip("TEST_VALIDATE_AZURE_SRE_AGENT is not true")
	}

	rg := env.azureSreAgentResourceGroup()
	assert.NotNil(t, azure.GetAResourceGroup(t, rg, subscriptionID))

	assert.True(t, azResourceExists(t, rg, "Microsoft.App/agents", env.azureSreAgentName))
	assert.Greater(t, azResourceCount(t, rg, "Microsoft.App/agents"), 0)
	assert.Greater(t, azResourceCount(t, rg, "Microsoft.ManagedIdentity/userAssignedIdentities"), 0)
	assert.Greater(t, azResourceCount(t, rg, "Microsoft.Insights/components"), 0)
	assert.Greater(t, azResourceCount(t, rg, "Microsoft.OperationalInsights/workspaces"), 0)
}

func TestAzureSreAgentAzureDevOpsRepoConnected(t *testing.T) {
	t.Parallel()

	if os.Getenv("ARM_SUBSCRIPTION_ID") == "" {
		t.Skip("ARM_SUBSCRIPTION_ID not set")
	}

	env := currentTestEnv()
	if !env.validatePortalVisibleSreAgent {
		t.Skip("TEST_VALIDATE_AZURE_SRE_AGENT is not true")
	}
	if !env.validateAzureDevOpsRepo {
		t.Skip("TEST_VALIDATE_AZURE_DEVOPS_REPO is not true")
	}
	require.NotEmpty(t, env.azureDevOpsRepoName, "set TEST_AZURE_DEVOPS_REPO_NAME when validating Azure DevOps outside ado-lab")
	require.NotEmpty(t, env.azureDevOpsRepoURL, "set TEST_AZURE_DEVOPS_REPO_URL when validating Azure DevOps outside ado-lab")

	var repos any
	rawRepos := azureSreAgentRepos(t, env)
	assert.NoError(t, json.Unmarshal([]byte(rawRepos), &repos), rawRepos)
	assert.Contains(t, rawRepos, env.azureDevOpsRepoName)
	assert.Contains(t, rawRepos, env.azureDevOpsRepoURL)
}
