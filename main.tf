# main.tf - Terraform za Intune device management

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {}
  
  # Vprašaj skrbnico za te vrednosti ↓
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

# Configure Azure AD Provider
provider "azuread" {
  tenant_id     = var.azure_tenant_id
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
}

# Read YAML file with devices
locals {
  devices = yamldecode(file("${path.module}/racunalnica/devices.yaml"))
}

# Create Azure AD devices (optional - če rabiš v Azure AD)
resource "azuread_device" "school_devices" {
  for_each = { for idx, device in local.devices.devices : device.serial => device }
  
  display_name = each.value.name
  device_id    = each.value.serial  # Using serial as device ID
  
  # Basic device info
  operating_system = "Windows"
  device_type      = "Desktop"
  enabled          = true
  
  tags = [
    "School: OS-TC-Jesenice",
    "Location: Jesenice",
    "ManagedBy: Intune"
  ]
}

# Create Intune managed devices (via Microsoft Graph)
# Note: This requires custom provider or REST API calls
# Here's an example using null_resource to call Graph API

resource "null_resource" "enroll_intune_devices" {
  for_each = { for idx, device in local.devices.devices : device.serial => device }
  
  triggers = {
    serial_number = each.value.serial
    device_name   = each.value.name
  }
  
  provisioner "local-exec" {
    command = <<EOT
      # PowerShell command to enroll device in Intune
      # This requires authentication first
      $Token = Get-AccessToken -Resource "https://graph.microsoft.com"
      
      $Body = @{
        deviceName = "${each.value.name}"
        serialNumber = "${each.value.serial}"
        managedDeviceOwnerType = "company"
        enrolledDateTime = "$(Get-Date -Format o)"
      } | ConvertTo-Json
      
      Invoke-RestMethod `
        -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices" `
        -Method POST `
        -Headers @{Authorization = "Bearer $Token"} `
        -ContentType "application/json" `
        -Body $Body
    EOT
    
    interpreter = ["pwsh", "-Command"]
  }
}

# Output information
output "enrolled_devices" {
  value = {
    for k, v in local.devices.devices : k => {
      name   = v.name
      serial = v.serial
      status = "Pending enrollment"
    }
  }
  description = "List of devices to be enrolled in Intune"
}