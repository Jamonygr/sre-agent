locals {
  iis_script = <<-POWERSHELL
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    $computer = $env:COMPUTERNAME
    $content = @"
    <!doctype html>
    <html>
      <head>
        <title>${var.lab_title}</title>
        <style>
          body { font-family: Segoe UI, Arial, sans-serif; margin: 48px; color: #1f2937; }
          .status { padding: 12px 16px; background: #e0f2fe; border-left: 4px solid #0284c7; }
          code { background: #f3f4f6; padding: 2px 6px; }
        </style>
      </head>
      <body>
        <h1>${var.lab_title}</h1>
        <p class="status">IIS is running on $computer.</p>
        <p>Use this VM for operations scenarios: patching, outage response, high CPU, and service restart remediation.</p>
        <p>Patch group: <code>${lookup(var.tags, "PatchGroup", "unset")}</code></p>
      </body>
    </html>
    "@
    Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value $content -Encoding UTF8
  POWERSHELL
}

module "vm" {
  source = "../windows-vm"

  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  subnet_id                   = var.subnet_id
  private_ip_address          = var.private_ip_address
  vm_size                     = var.vm_size
  admin_username              = var.admin_username
  admin_password              = var.admin_password
  enable_public_ip            = var.enable_public_ip
  install_azure_monitor_agent = var.install_azure_monitor_agent
  install_dependency_agent    = var.install_dependency_agent
  custom_script               = local.iis_script
  role                        = "iis-web-server"
  tags                        = var.tags
}

