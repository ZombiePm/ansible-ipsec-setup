# IPSEC Setup Between Two Debian 13 VMs Using Ansible

This document describes the complete setup of an IPSEC tunnel between two Debian 13 virtual machines using Ansible automation, fulfilling all requirements specified in the task.

## Task Requirements

The task requires setting up:
1. **VM1 (Gateway)** with two network interfaces:
   - External interface for NAT to internet
   - Internal interface for IPSEC connection to VM2
2. **VM2 (Web Server)** with one network interface:
   - Connected via IPSEC to VM1
   - Internet access through VM1
3. Port forwarding from VM1 port 446 to VM2 port 443
4. Nginx web server on VM2 with a static page
5. Full automation through Ansible roles

## Solution Overview

The implemented solution uses:
- **StrongSwan** for IPSEC implementation with certificate-based authentication
- **Ansible** for complete automation of both VM configurations
- **iptables** for NAT and port forwarding
- **Nginx** as the web server on VM2 with SSL/TLS

## Implementation Details

### Network Architecture

```
Internet
    │
    ▼
┌──────────────┐
│   VM1        │
│   Gateway    │
│              │
│ eth0 (NAT) ◄─┼──► Internet
│ eth1 (Internal) ◄──┐
└──────────────┘    │ IPSEC Tunnel
                    │
┌──────────────┐    │
│   VM2        │    │
│   Web Server │ ◄──┘
│              │
│ ens18        │
└──────────────┘
```

Internal network: 10.1.0.0/24
- VM1 internal IP: 10.1.0.1
- VM2 internal IP: 10.1.0.2

### IPSEC Configuration

The solution implements:
- IKEv2 protocol for secure tunnel establishment
- RSA certificate-based authentication
- Automatic CA and certificate generation
- Secure tunnel encryption (AES-256, SHA2-256)

### Port Forwarding

Configured iptables rules on VM1:
- Forward external port 446 → internal VM2 port 443

### Web Server

Nginx configuration on VM2:
- Listens on port 443 with SSL/TLS
- Serves a static HTML page
- Includes security headers

## Manual Configuration Required

While the playbook automates most of the setup, some manual configuration is required before running the playbook:

### 1. VirtualBox Network Setup

Before running the playbook, configure the VMs in VirtualBox:

**VM1 Network Configuration:**
- Adapter 1: NAT (for internet access)
- Adapter 2: Internal Network (for IPSEC tunnel)

**VM2 Network Configuration:**
- Adapter 1: Internal Network (same network as VM1's second adapter)

### 2. Inventory Configuration

Update the `inventory` file with the actual IP addresses of your VMs:
```
[vm1]
vm1 ansible_host=ACTUAL_IP_OF_VM1 ansible_user=root

[vm2]
vm2 ansible_host=ACTUAL_IP_OF_VM2 ansible_user=root
```

### 3. Interface Name Configuration

Update `group_vars/all.yml` with the actual interface names:
- `vm1_external_iface`: External interface name on VM1 (e.g., enp0s3)
- `vm1_internal_iface`: Internal interface name on VM1 (e.g., enp0s8)
- `vm2_internal_iface`: Internal interface name on VM2 (e.g., enp0s3)

## Running the Playbook

1. Configure the VMs in VirtualBox as described above
2. Update the inventory file with actual IP addresses
3. Update interface names in group_vars/all.yml
4. Run the playbook:
   ```bash
   ansible-playbook -i inventory site.yml
   ```

## Testing the Implementation

### Test 0: Demonstration

After running the playbook:
1. Both VMs will have their network interfaces configured
2. IPSEC tunnel will be established automatically
3. Nginx will be running on VM2
4. Port forwarding will be configured on VM1

### Test 1: Web Access Through Port Forwarding

From your local computer:
1. Open a browser
2. Navigate to `http://VM1_EXTERNAL_IP:446`
3. You should see the static page served from VM2

### Test 3: Traffic Routing Verification

On VM2, run a traceroute:
```bash
traceroute google.com
```

You should see that all traffic goes through VM1's IP address.

## What Could Not Be Fully Automated

Several aspects could not be completely automated in the playbook:

### 1. VirtualBox Network Configuration

The physical network adapter setup in VirtualBox must be done manually:
- Creating internal networks
- Assigning VMs to appropriate network adapters
- This is a limitation of VirtualBox and cannot be automated through Ansible

### 2. Initial VM Provisioning

The playbook assumes:
- Both VMs are already installed with Debian 13
- SSH access is configured and working
- Root access is available
- These prerequisites must be set up manually

### 3. Dynamic Interface Detection

Interface names vary between systems:
- The playbook uses predefined interface names
- In production environments, a more dynamic approach would be needed
- This would require additional hardware detection logic

### 4. Certificate Authority Management

While certificates are automatically generated:
- In production, a proper PKI infrastructure would be required
- Certificate renewal and revocation processes are not automated
- This is a security consideration for production deployments

## Troubleshooting Common Issues

### IPSEC Tunnel Not Establishing

1. Check network connectivity between VMs on the internal network
2. Verify UDP ports 500 and 4500 are not blocked
3. Check StrongSwan logs: `journalctl -u strongswan -f`
4. Verify certificate validity and trust

### Port Forwarding Not Working

1. Check iptables rules: `iptables -t nat -L -n -v`
2. Verify IP forwarding is enabled: `cat /proc/sys/net/ipv4/ip_forward`
3. Confirm nginx is running on VM2: `systemctl status nginx`

### Network Interface Issues

1. Verify interface names in group_vars/all.yml match actual interfaces
2. Check interface status: `ip a`
3. Ensure interfaces are properly bridged in VirtualBox

## Security Considerations

### Certificate Management

- Uses strong 4096-bit RSA keys
- Implements proper certificate lifecycle (generation, distribution)
- In production, implement certificate renewal and revocation

### Firewall Configuration

- Only necessary ports are opened
- IPSEC traffic is properly secured
- Additional firewall rules should be implemented for production

### Access Control

- SSH access should be properly secured (key-based auth, etc.)
- Root access should be limited and monitored
- Consider implementing fail2ban for intrusion prevention

## Conclusion

This implementation successfully fulfills all requirements of the task:

✅ VM1 configured as gateway with two network interfaces
✅ VM2 configured as web server with one network interface
✅ IPSEC tunnel established with certificate-based authentication
✅ Port forwarding from VM1 port 446 to VM2 port 443
✅ Nginx web server running on VM2 with static page
✅ Complete automation through Ansible roles

While some manual steps are required for initial VM setup and VirtualBox configuration, the majority of the complex networking and security configuration is fully automated. The solution provides a secure, scalable foundation that can be extended for more complex deployments.