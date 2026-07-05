output "workbook_ids" {
  description = "Workbook IDs."
  value = {
    sre_overview = azurerm_application_insights_workbook.sre_overview.id
    updates      = azurerm_application_insights_workbook.updates.id
    incidents    = azurerm_application_insights_workbook.incidents.id
  }
}
