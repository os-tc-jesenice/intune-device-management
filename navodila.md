# Praktični start DANES - 28 računalnikov v računalnici

Odlični načrt! Gremo na vse točke + danes akcijski plan.

---

## **1. Git encryption - praktično**

### **Git-crypt vs Ansible Vault**

**LAHKO uporabljate Ansible Vault (če že poznate):**

```bash
# Install ansible
pip3 install ansible

# Encrypt YAML
ansible-vault encrypt data/racunalnica/pc01-28.yaml

# Decrypt za Terraform
ansible-vault decrypt data/racunalnica/pc01-28.yaml

# Edit (auto decrypt/encrypt)
ansible-vault edit data/racunalnica/pc01-28.yaml
```

**Problem za Terraform:**
- Terraform ne more direktno prebrati Ansible Vault encrypted YAML
- Potrebujete script: decrypt → terraform apply → encrypt

---

**Git-crypt je BOLJŠI za Terraform workflow:**

```bash
# Install
sudo apt install git-crypt

# Initialize (once)
cd ~/terraform-intune
git-crypt init

# Export key (BACKUP THIS!)
git-crypt export-key ~/git-crypt-key.key
# Store key VARNO (USB, password manager)

# Specify which files encrypt
cat > .gitattributes << 'EOF'
# Encrypt sensitive files
terraform.tfvars filter=git-crypt diff=git-crypt
data/secrets/*.yaml filter=git-crypt diff=git-crypt
EOF

# Commit
git add .gitattributes
git commit -m "Enable git-crypt"

# Lock (encrypt) repository
git-crypt lock

# Unlock (decrypt) with key
git-crypt unlock ~/git-crypt-key.key
```

**Prednosti git-crypt:**
- ✅ Transparentno (Terraform vidi decrypted YAML)
- ✅ Auto-encrypt na git push
- ✅ Ne potrebujete decrypt/encrypt korakov

---

### **Če YAML ni sensitive (priporočam!):**

**Public repo + non-sensitive YAML:**

```yaml
# data/racunalnica/pc01-28.yaml

devices:
  pc01:
    serial_number: "5CD0123ABC"  # NOT sensitive (written on device)
    hostname: "PC-UCINICA-01"     # NOT sensitive (visible to all)
    model: "HP EliteDesk 800 G5"  # NOT sensitive
    # No passwords, no secrets → SAFE for public Git!
```

**Sensitive data (credentials) → terraform.tfvars:**

```hcl
# terraform.tfvars (NOT in Git!)

client_id       = "xxxx"  # Azure credentials
client_secret   = "xxxx"
tenant_id       = "xxxx"
subscription_id = "xxxx"
```

**.gitignore:**

```gitignore
terraform.tfvars  # ✅ This is gitignored (sensitive)
```

**Rezultat:**
- YAML files → public Git (safe)
- Credentials → NOT in Git (safe)

**PRIPOROČAM:** Public repo + non-sensitive YAML (enostavnejše, transparent)

---

## **2. Hostname strategija - praktično**

### **Problem: Hostname messy/useless**

**Trenutno:**
```
Računalnik 1: "DESKTOP-ABC123"
Računalnik 2: "HP-PAVILION-XYZ"
Računalnik 3: "PC-USER-01"
→ Inconsistent, useless for management
```

---

### **Rešitev: Standardizirani hostnames**

**Target naming scheme:**

```
Računalnica:
PC-UC-01, PC-UC-02, ..., PC-UC-28

Učitelji:
PC-TEA-MARIJA, PC-TEA-JANEZ, ...

Tablice:
IPAD-UC-01, ANDROID-UC-01, ...
```

---

### **Kako določiti kje je device BREZ hostname?**

**Opcija A: Serial number pattern (če OEM ima patterns):**

```yaml
# Če HP uporablja serial patterns:
# 5CDxxxx = Desktop
# DMPLxxxx = Laptop
# Serial starts with location code

devices:
  pc01:
    serial_number: "5CD0123ABC"  # "5CD" = Desktop
    device_type: "desktop"
    location: "racunalnica"
  
  teacher01:
    serial_number: "5CG9876XYZ"  # "5CG" = Laptop
    device_type: "laptop"
    location: "kabinet"
```

---

**Opcija B: Manual location field:**

```yaml
devices:
  device_5cd0123abc:  # device_id = serial (lowercase)
    serial_number: "5CD0123ABC"
    location: "racunalnica"
    row: 1
    seat: 3
    target_hostname: "PC-UC-01"  # What we WANT to rename to
  
  device_5cg9876xyz:
    serial_number: "5CG9876XYZ"
    location: "kabinet-ucitelji"
    owner: "Marija Novak"
    target_hostname: "PC-TEA-MARIJA"
```

**Terraform logic:**

```hcl
locals {
  racunalnica_devices = {
    for k, v in local.all_devices : k => v
    if v.location == "racunalnica"
  }
  
  teacher_devices = {
    for k, v in local.all_devices : k => v
    if v.location == "kabinet-ucitelji"
  }
}
```

---

**Opcija C: Eno YAML per lokacija (NAJBOLJŠE za vas):**

```
data/
├── racunalnica.yaml       # All 28 classroom computers
├── kabinet-ucitelji.yaml  # All teacher devices
└── tablice.yaml           # All tablets

# No need for "location" field - filename IS location!
```

---

### **DANES: Collect serials + manual location tracking**

**Excel/Google Sheets (začasno):**

```
Serial Number    | Physical Location | Target Hostname | Model
5CD0123ABC       | Računalnica R1S1  | PC-UC-01       | HP EliteDesk 800 G5
5CD0124XYZ       | Računalnica R1S2  | PC-UC-02       | HP EliteDesk 800 G5
...
```

**Po zbiranju → generate YAML:**

```python
# scripts/excel-to-yaml.py

import pandas as pd
import yaml

# Read Excel
df = pd.read_excel("device-inventory.xlsx")

devices = {}
for _, row in df.iterrows():
    device_id = f"pc{row['Target Hostname'].split('-')[-1]}"  # pc01, pc02, ...
    devices[device_id] = {
        "serial_number": row["Serial Number"],
        "target_hostname": row["Target Hostname"],
        "model": row["Model"],
        "location_note": row["Physical Location"]
    }

# Write YAML
with open("data/racunalnica.yaml", "w") as f:
    yaml.dump({"devices": devices}, f)
```

---

## **3. PowerShell ukazi - Rename + Serial**

### **A) Get Serial Number:**

```powershell
# On each device
wmic bios get serialnumber

# Output:
SerialNumber
5CD0123ABC
```

**ALI kombiniran output (Serial + Current Hostname):**

```powershell
# collect-info.ps1

$Serial = (Get-WmiObject Win32_BIOS).SerialNumber
$Hostname = $env:COMPUTERNAME
$Model = (Get-WmiObject Win32_ComputerSystem).Model
$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer

Write-Output "Serial: $Serial"
Write-Output "Hostname: $Hostname"
Write-Output "Model: $Manufacturer $Model"
Write-Output "---"

# Save to file
$Output = @{
    Serial = $Serial
    Hostname = $Hostname
    Model = "$Manufacturer $Model"
}

$Output | ConvertTo-Json | Out-File "C:\Temp\device-info.json"

Write-Output "✅ Saved to C:\Temp\device-info.json"
```

**Run na vseh računalnikih → zberi JSON datoteke → import v Excel/YAML**

---

### **B) Rename Computer (immediate):**

```powershell
# Rename računalnika (requires admin + restart)

# Method 1: WMI
$NewName = "PC-UC-01"
(Get-WmiObject Win32_ComputerSystem).Rename($NewName)

# Restart required
Restart-Computer -Force

# Method 2: PowerShell cmdlet
Rename-Computer -NewName "PC-UC-01" -Restart -Force
```

**⚠️ WARNING:** Restart je potreben! (moti pouk)

---

### **C) Rename preko Intune (BOLJŠE - no restart needed immediately):**

**Intune portal:**

```
Devices → Select device → Rename
→ Enter new name: PC-UC-01
→ Device syncs → Rename happens (no immediate restart)
```

**Preko Terraform (IaC):**

**Autopilot profile lahko set device name template:**

```hcl
resource "azurerm_windows_autopilot_deployment_profile" "standard" {
  # ...
  
  device_name_template = "PC-UC-%SERIAL:4%"  
  # Uses last 4 digits of serial
  # PC-UC-3ABC
}
```

**Problem:** Template ne podpira "map serial → custom name"

---

**Rešitev: Post-enrollment rename script:**

```hcl
# Intune PowerShell script
resource "azurerm_intune_device_management_script" "rename_device" {
  display_name = "Rename Device (Post-Enrollment)"
  
  script_content = base64encode(<<-EOT
    # Read target hostname from registry (set by Terraform)
    $TargetName = Get-ItemProperty -Path "HKLM:\SOFTWARE\School" -Name "TargetHostname" -ErrorAction SilentlyContinue
    
    if ($TargetName) {
      $CurrentName = $env:COMPUTERNAME
      if ($CurrentName -ne $TargetName.TargetHostname) {
        Rename-Computer -NewName $TargetName.TargetHostname -Force
        # Restart during maintenance window (not immediately)
        Shutdown /r /t 7200 /c "Device will restart in 2 hours for hostname update"
      }
    }
  EOT
  )
  
  run_as_account = "system"
}
```

---

### **DANAS PRISTOP: Manual rename KASNEJE, najprej samo enroll**

**Workflow:**

```
1. DANES: Zberi serial numbers (ne spreminjaj hostname!)
2. DANES: Enroll devices v Intune (s Terraform)
3. JUTRI: Ko so vsi enrolled → batch rename script
4. Weekend: Restart vseh (ne moti pouka)
```

---

## **4. Veyon vs Intune - Remote Control**

### **Primerjava:**

| Feature | **Veyon** | **Intune** |
|---------|----------|----------|
| Real-time screen view | ✅✅✅ Live | ❌ Screenshot only |
| Remote control (take over) | ✅✅✅ Full control | ⚠️ Limited (Remote Help app) |
| Screen lock | ✅ Instant | ❌ No |
| Demo mode (show your screen) | ✅✅✅ | ❌ No |
| File transfer | ✅ | ⚠️ Via apps only |
| Power on/off | ⚠️ Wake-on-LAN | ✅ Remote |
| Software deployment | ❌ Manual | ✅✅✅ Automated |
| Compliance monitoring | ❌ | ✅✅✅ |
| Remote wipe/format | ❌ | ✅✅✅ |

---

### **Priporočilo: Obdrži OBE!**

```
Veyon:
- Real-time classroom monitoring
- Screen lock during lectures
- Demo mode (show your screen)
- Remote control for help

Intune:
- Device enrollment & management
- Software deployment
- Compliance & policies
- Remote actions (wipe, scripts)
```

**Use cases:**

```
Med poukom:
→ Veyon (real-time control, demo, lock)

IT management:
→ Intune (deploy apps, policies, wipe)
```

---

### **Če želite izbrisati Veyon (ne priporočam):**

**Intune uninstall:**

```hcl
resource "azurerm_intune_app_assignment" "veyon_uninstall" {
  app_id   = azurerm_intune_windows_app.veyon.id
  intent   = "Uninstall"
  group_id = azuread_group.racunalnica.id
}
```

**Ampak:** Izgubite real-time classroom control!

---

## **5. Admin user management**

### **Lahko izbrišete local admin:**

**Intune PowerShell script:**

```powershell
# Remove local admin account

$AdminUser = "Administrator"

# Disable account (safer than delete)
Disable-LocalUser -Name $AdminUser

# OR: Delete account
Remove-LocalUser -Name $AdminUser -ErrorAction SilentlyContinue
```

---

**Ampak NAJPREJ ustvarite nov admin account (Intune-managed):**

```hcl
# Intune configuration policy
resource "azurerm_intune_device_configuration_policy" "local_admin" {
  display_name = "Create IT Admin Account"
  
  # ...
  
  settings {
    # Create local admin via Intune
    local_users_and_groups {
      local_user {
        name        = "ITAdmin"
        password    = var.it_admin_password  # From Vault
        description = "IT Administrator (Intune-managed)"
        admin       = true
      }
    }
  }
}
```

**Workflow:**

```
1. Intune creates ITAdmin account (known password)
2. Test: Login s ITAdmin → works ✅
3. Remove old Administrator account
4. Vi poznate ITAdmin password → admin access ✅
```

---

## **6. Windows + Office license keys**

### **Autopilot + Volume Licensing:**

**Scenario A: OEM licenses (preinstalled):**

```
Device ima Windows/Office license v BIOS/firmware
→ Autopilot deployment → Avtomatsko aktivacija
→ NE potrebujete vnesti ključev!
```

**Preverite:**

```powershell
# Check Windows activation
slmgr /dli

# Check Office activation
cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus
```

---

**Scenario B: Volume License keys (MAK/KMS):**

**Intune configuration:**

```hcl
# Windows license key
resource "azurerm_intune_device_configuration_policy" "windows_license" {
  display_name = "Windows Activation"
  
  # ...
  
  settings {
    edition_upgrade {
      license_type = "ProductKey"
      product_key  = var.windows_product_key  # From Vault
    }
  }
}

# Office license
resource "azurerm_intune_windows_app_msi" "office" {
  # ...
  
  # Office deployment tool (ODT) config.xml
  # Includes product key
}
```

---

**Microsoft 365 Education (recommended):**

```
Če imate M365 Education:
→ Office 365 apps (cloud-based)
→ NE potrebujete product keys
→ User login → avtomatska aktivacija

Študent login (ime.priimek@oscufar.si)
→ Office aktiviran za tega uporabnika
```

---

**Wipe device → License reactivation:**

```
Autopilot wipe:
→ Device boot (OOBE)
→ Autopilot profile → Install Office
→ User login → Office aktivacija (cloud)
→ Windows aktivacija (OEM license iz BIOS)

NE potrebujete ponovno vnesti ključev!
```

---

## **7. DANES - Akcijski načrt (28 računalnikov)**

### **PRIPRAVA (doma, 30 min):**

```bash
# 1. Git repo setup
mkdir ~/terraform-intune
cd ~/terraform-intune
git init

# 2. Basic structure
mkdir -p data/racunalnica scripts docs
touch data/racunalnica/devices.yaml
touch scripts/collect-serials.ps1
touch README.md

# 3. Terraform basic
cat > main.tf << 'EOF'
# Placeholder - will add later
terraform {
  required_version = ">= 1.6"
}
EOF

# 4. Git commit
git add .
git commit -m "Initial structure"

# 5. GitHub (optional)
# Create repo on GitHub → git remote add origin → git push
```

---

### **V ŠOLI - FAZA 1: Zbiranje podatkov (1-2 uri)**

**PowerShell script na USB:**

```powershell
# collect-device-info.ps1

$Serial = (Get-WmiObject Win32_BIOS).SerialNumber
$Hostname = $env:COMPUTERNAME
$Model = (Get-WmiObject Win32_ComputerSystem).Model
$Manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
$MAC = (Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1).MacAddress

$DeviceInfo = @{
    Serial       = $Serial
    Hostname     = $Hostname
    Model        = "$Manufacturer $Model"
    MAC          = $MAC
    CollectedAt  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

# Save to USB
$OutputPath = "D:\device-info-$Serial.json"  # D: = USB drive
$DeviceInfo | ConvertTo-Json | Out-File $OutputPath

Write-Host "✅ Device info saved to $OutputPath" -ForegroundColor Green
Write-Host ""
Write-Host "Serial:   $Serial"
Write-Host "Hostname: $Hostname"
Write-Host "Model:    $($DeviceInfo.Model)"
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
```

**Postopek (5 min per računalnik):**

```
1. Vstavite USB ključek v PC-01
2. Desni klik na collect-device-info.ps1 → Run with PowerShell
3. Preberite output (Serial, Hostname) → zapišite fizično lokacijo (row/seat)
4. USB ključek → naslednji računalnik
5. Repeat za vseh 28
```

**Alternative (hitrejša, če imate Veyon):**

```
Če že imate Veyon delujoč:
→ File Transfer: Pošljite collect-device-info.ps1 na vse
→ Run Program: PowerShell -File "C:\Temp\collect-device-info.ps1"
→ File Transfer: Zberi nazaj JSON datoteke
```

---

### **FAZA 2: Generate YAML (doma, 30 min)**

```python
# scripts/json-to-yaml.py

import json
import yaml
from pathlib import Path

# Load all JSON files
json_dir = Path("usb-collected-data")  # Copy JSON files from USB here
devices = {}

for json_file in json_dir.glob("device-info-*.json"):
    with open(json_file) as f:
        data = json.load(f)
    
    # Generate device_id from serial
    device_id = f"pc{len(devices)+1:02d}"  # pc01, pc02, ...
    
    devices[device_id] = {
        "serial_number": data["Serial"],
        "current_hostname": data["Hostname"],
        "target_hostname": f"PC-UC-{len(devices)+1:02d}",  # PC-UC-01, ...
        "model": data["Model"],
        "mac_address": data["MAC"],
        "collected_at": data["CollectedAt"]
    }

# Write YAML
output = {
    "# Device inventory - Računalnica": None,
    "# Collected on": devices[list(devices.keys())[0]]["collected_at"][:10],
    "devices": devices
}

with open("data/racunalnica/devices.yaml", "w") as f:
    yaml.dump(output, f, default_flow_style=False, sort_keys=False)

print(f"✅ Generated YAML with {len(devices)} devices")
```

**Run:**

```bash
# Copy JSON files from USB
cp /media/usb/device-info-*.json ~/terraform-intune/usb-collected-data/

# Generate YAML
python3 scripts/json-to-yaml.py

# Review
cat data/racunalnica/devices.yaml
```

---

### **FAZA 3: Terraform basic setup (doma, 1 ura)**

**Minimalen Terraform za DANES:**

```hcl
# main.tf

terraform {
  required_version = ">= 1.6"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# Load devices
locals {
  devices = yamldecode(file("data/racunalnica/devices.yaml")).devices
}

# Register devices (minimal - just serial numbers)
resource "azurerm_windows_autopilot_device" "racunalnica" {
  for_each = local.devices
  
  serial_number = each.value.serial_number
  display_name  = each.value.target_hostname
}

output "enrolled_devices" {
  value = {
    for k, v in azurerm_windows_autopilot_device.racunalnica :
    k => {
      serial = v.serial_number
      name   = v.display_name
    }
  }
}
```

---

### **FAZA 4: Terraform apply (doma, 15 min)**

```bash
# Initialize
terraform init

# Plan (review)
terraform plan

# Apply
terraform apply

# Output:
# Apply complete! Resources: 28 added

# Verify in Intune portal
# Devices → Windows Enrollment → Devices
# → See all 28 devices listed
```

---

### **JUTRI: Test enrollment**

```
1. Izberi 1 testni računalnik (PC-01)
2. Wipe device (Settings → Recovery → Reset)
3. Device boot (OOBE)
4. Check: "This device belongs to OŠ Toneta Čufarja"
5. Autopilot deploys (20-30 min)
6. Verify:
   - Device renamed to PC-UC-01
   - Standard apps installed
   - Compliance policies applied

✅ If works → repeat za ostale 27 (batch wipe)
```

---

## **8. Troubleshooting checklist**

### **Če Autopilot ne deluje:**

```bash
# 1. Check serial number v Intune
# Intune Portal → Devices → Windows Enrollment → Devices
# Search: 5CD0123ABC

# 2. Check Autopilot profile assigned
# Device → Properties → Autopilot profile: "Standard" ✅

# 3. Check network connectivity
# Device mora imeti internet za Autopilot

# 4. Check Windows version
# Autopilot needs Windows 10 1809+ or Windows 11

# 5. Logs on device
# Event Viewer → Applications and Services Logs
# → Microsoft → Windows → Provisioning-Diagnostics-Provider
```

---

## **TL;DR - DANES CHECKLIST**

```
☐ PRIPRAVA (doma):
  - Git repo struktura
  - PowerShell script na USB
  - Excel/paper za tracking fizične lokacije

☐ V ŠOLI (računalnica):
  - Zberi serial numbers (28x ~5min = 2.5h)
  - Zapišite fizične lokacije (row/seat)
  
☐ DOMA (zvečer):
  - Generate YAML iz collected data
  - Terraform basic setup
  - terraform init
  - terraform plan (review!)
  
☐ JUTRI:
  - terraform apply (enroll devices)
  - Test Autopilot na 1 device
  - Če dela → batch wipe vseh 28
```

---

**Srečno DANES! Po tem koraku bo sistem postal ZELO močan.** 💪🚀

**Če naletite na kakšen problem ali vprašanje MED delom - pišite, bom takoj pomagal!** 📱