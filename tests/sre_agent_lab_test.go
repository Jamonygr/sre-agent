package test

import (
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

type testEnv struct {
	environment   string
	locationShort string
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

	return testEnv{environment: env, locationShort: locationShort}
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
