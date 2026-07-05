# =============================================================================
# TERRAFORM BACKEND CONFIGURATION
# =============================================================================
# CI/CD supplies Azure Storage backend settings through -backend-config.
# For local validation, run: terraform init -backend=false
# =============================================================================

terraform {
  backend "azurerm" {}
}

