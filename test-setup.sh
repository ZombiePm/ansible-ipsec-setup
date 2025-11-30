#!/bin/bash

# Test script to verify the IPSEC setup

echo "Testing IPSEC setup..."

# Test 1: Check if VM1 and VM2 can ping each other through the IPSEC tunnel
echo "Test 1: Checking IPSEC tunnel connectivity"
echo "Running: ping -c 3 10.1.0.2 from VM1"
ssh root@IP_OF_VM1 "ping -c 3 10.1.0.2"

echo "Running: ping -c 3 10.1.0.1 from VM2"
ssh root@IP_OF_VM2 "ping -c 3 10.1.0.1"

# Test 2: Check IPSEC tunnel status
echo "Test 2: Checking IPSEC tunnel status"
echo "VM1 IPSEC status:"
ssh root@IP_OF_VM1 "ipsec statusall"

echo "VM2 IPSEC status:"
ssh root@IP_OF_VM2 "ipsec statusall"

# Test 3: Check if port forwarding is working
echo "Test 3: Checking port forwarding"
echo "Accessing web server through VM1:"
curl -I http://IP_OF_VM1

# Test 4: Check if VM2 can access the internet through VM1
echo "Test 4: Checking internet access from VM2 through VM1"
ssh root@IP_OF_VM2 "curl -I http://google.com"

echo "All tests completed."