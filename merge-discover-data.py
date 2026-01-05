#!/usr/bin/env python3
"""
Merge discovered device data into main YAML files
"""

import yaml
from pathlib import Path

# Load existing main YAML
main_yaml_path = "data/racunalnica/pc01-28.yaml"
with open(main_yaml_path) as f:
    main_data = yaml.safe_load(f)

# Load discovered YAML
discovered_yaml_path = "data/discovered/racunalnica-discovered.yaml"
with open(discovered_yaml_path) as f:
    discovered_data = yaml.safe_load(f)

# Merge: Update main with discovered data (preserve manual edits)
for device_id, discovered_device in discovered_data["devices"].items():
    if device_id in main_data["devices"]:
        # Device exists in main YAML
        main_device = main_data["devices"][device_id]
        
        # Update fields that came from discovery
        main_device["hostname"] = discovered_device["hostname"]
        main_device["model"] = discovered_device["model"]
        main_device["os"] = discovered_device["os"]
        main_device["last_sync"] = discovered_device["last_sync"]
        
        # Update hardware_hash if was missing
        if main_device.get("hardware_hash") == "# Not available" and discovered_device["hardware_hash"] != "# Not available":
            main_device["hardware_hash"] = discovered_device["hardware_hash"]
        
        # Update apps (merge discovered + manual)
        manual_apps = set(main_device.get("apps", []))
        discovered_apps = set(discovered_device["apps"])
        all_apps = sorted(list(manual_apps.union(discovered_apps)))
        main_device["apps"] = all_apps
        
        # Add metadata
        main_device["_last_discovered"] = discovered_device["discovered_at"]
        main_device["_intune_id"] = discovered_device["intune_device_id"]
        
        print(f"✅ Updated: {device_id}")
    else:
        # New device (not in main YAML)
        print(f"⚠️  New device discovered: {device_id}")
        print(f"    Add to main YAML? (hostname: {discovered_device['hostname']})")
        # Optionally auto-add or prompt for manual review

# Write back
with open(main_yaml_path, "w") as f:
    yaml.dump(main_data, f, default_flow_style=False, sort_keys=False)

print(f"\n✅ Merge complete! Updated: {main_yaml_path}")