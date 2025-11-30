# IPSEC Setup with Ansible

This Ansible playbook sets up a secure IPSEC tunnel between two Debian 13 virtual machines:

1. **VM1** - Gateway with two network interfaces:
   - External interface for NAT to the internet
   - Internal interface for IPSEC tunnel to VM2
   - Port forwarding from external interface to VM2's nginx server

2. **VM2** - Web server:
   - Single network interface connected via IPSEC to VM1
   - Nginx web server with a static page
   - Internet access through VM1

## Prerequisites

- Two Debian 13 virtual machines (VM1 and VM2)
- VM1 with two network interfaces:
  - One connected to the internet (NAT)
  - One internal network interface for IPSEC
- VM2 with one network interface connected to the same internal network as VM1's second interface
- Ansible installed on your control machine

## Setup Instructions

1. Update the inventory file with the correct IP addresses for your VMs:
   ```
   [vm1]
   vm1 ansible_host=IP_OF_VM1 ansible_user=root

   [vm2]
   vm2 ansible_host=IP_OF_VM2 ansible_user=root
   ```

2. Update the group variables in `group_vars/all.yml` to match your network configuration:
   - `vm1_external_iface`: The name of VM1's external network interface
   - `vm1_internal_iface`: The name of VM1's internal network interface
   - `vm2_internal_iface`: The name of VM2's network interface

3. Run the playbook:
   ```bash
   ansible-playbook -i inventory site.yml
   ```

## What the Playbook Does

### VM1 (Gateway)
- Installs StrongSwan for IPSEC
- Generates CA, server certificate, and key
- Configures IPSEC for connection to VM2
- Sets up NAT and IP forwarding
- Configures iptables for port forwarding (port 80 to VM2)

### VM2 (Web Server)
- Installs Nginx web server
- Deploys a static index page
- Installs StrongSwan for IPSEC
- Configures IPSEC client to connect to VM1

## Verification

After running the playbook:

1. Check that the IPSEC tunnel is established:
   ```bash
   # On VM1
   ipsec statusall

   # On VM2
   ipsec statusall
   ```

2. Test connectivity between VMs:
   ```bash
   # From VM1
   ping 10.1.0.2

   # From VM2
   ping 10.1.0.1
   ```

3. Test web access through the tunnel:
   ```bash
   # From your local machine (replace VM1_IP with actual IP)
   curl http://VM1_IP
   ```

## Network Diagram

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

## Troubleshooting

If the IPSEC tunnel is not establishing:

1. Check that both VMs can reach each other on the internal network
2. Verify that UDP ports 500 and 4500 are not blocked by firewalls
3. Check the StrongSwan logs:
   ```bash
   journalctl -u strongswan -f
   ```

If port forwarding is not working:

1. Check iptables rules on VM1:
   ```bash
   iptables -t nat -L -n -v
   ```

2. Verify that IP forwarding is enabled:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```"# ansible-ipsec-setup" 
