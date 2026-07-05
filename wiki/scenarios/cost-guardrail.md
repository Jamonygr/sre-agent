# Scenario: Cost Guardrail

## Goal

Validate that the lab has a visible cost guardrail for the SRE resource group.

## Prerequisites

- `deploy_cost_management = true`
- `cost_budget_amount` set to a lab-appropriate number

## Steps

1. Open Cost Management in the Azure portal.
2. Navigate to Budgets.
3. Confirm the `budget-<base>` budget exists for the SRE resource group.
4. Confirm notification contacts match `alert_email_receivers` when configured.

## Notes

The budget is a lab visibility control. It does not stop resources automatically.
