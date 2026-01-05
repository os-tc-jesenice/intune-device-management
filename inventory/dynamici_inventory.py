#!/usr/bin/env python3

import json
import subprocess

def get_computers():
    # Scan network for Windows computers
    result = subprocess.run(
        ['nmap', '-p', '5985', '192.168.1.0/24', '--open'],
        capture_output=True, text=True
    )
    
    computers = []
    # Parse nmap output, extract IPs
    # ... (parsing logic)
    
    return {
        'racunalnica': {
            'hosts': computers,
            'vars': {
                'ansible_connection': 'winrm',
                'ansible_user': 'Administrator'
            }
        }
    }

if __name__ == '__main__':
    print(json.dumps(get_computers(), indent=2))