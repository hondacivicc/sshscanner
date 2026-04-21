# GhostLogin (sshscanner)

A bash-based SSH network scanner with optional automated brute-force capability, built for CTF competitions and security research in lab environments.
Be aware that in no way you're invisible. GhostLogin is just the name for the project.

## Features

- Accepts single IPs, IP ranges (`192.168.1.1-192.168.1.254`), and CIDR notation (`192.168.1.0/24`)
- Scans targets for open SSH services using nmap
- Optional brute-force via Medusa with custom wordlists
- Launches a test payload on successful logins via sshpass
- Displays results in a clean formatted table

## Requirements

- `nmap`
- `medusa` (only needed for brute-force mode)
- `sshpass` (only needed for brute-force mode)

## Usage

```bash
chmod +x sshscanner.sh
sudo ./sshscanner.sh
```

You will be prompted to:
1. Choose whether to enable automatic brute-forcing
2. Enter a target (IP, range, or CIDR)
3. If brute-forcing: provide paths to username and password wordlists

## Disclaimer

This tool is intended for use in authorized environments only — CTF competitions, personal labs, and penetration testing engagements where you have explicit permission. Unauthorized use against systems you do not own is illegal.
