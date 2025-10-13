---
title: "From Old Mac to DevOps Lab – Part 2: Wi-Fi and Static IP with Netplan"
description: "Setting up Wi-Fi and a permanent IP on my headless Ubuntu Server Mac using Netplan. No GUI, no clicks — just YAML and results."
date: 2025-10-11
tags: [Ubuntu Server, Netplan, WiFi, Static IP, DevOps Lab]
---

# From Old Mac to DevOps Lab – Part 2: Wi-Fi and Static IP with Netplan

After getting Ubuntu Server installed in **Part 1**, I wanted this old Mac to move around the house — no Ethernet leash.  
But here’s the thing: on a headless install, Wi-Fi isn’t plug-and-play.  
So let’s fix that using **Netplan**, the built-in network manager for Ubuntu Server.

---

## Step 1 – Check Your Wi-Fi Adapter

First, I listed network devices to identify the wireless card:

```bash
ip link
```
---

## Step 2 – Install the Broadcom Driver (for Most Macs)

Old MacBooks usually need the Broadcom Wi-Fi driver.
Without it, Ubuntu sees the card but doesn’t connect.

```bash
sudo apt install bcmwl-kernel-source -y
sudo reboot
```
---

## Step 3 – Edit the Netplan Config

Netplan uses YAML files stored in /etc/netplan/.
You can have multiple, but I like creating my own so I know what’s inside:

```bash
sudo nano /etc/netplan/02-wifi.yaml
```
Paste this (replace SSID and password):
```bash
network:
  version: 2
  renderer: networkd
  wifis:
    wlp2s0:
      addresses:
        - 192.168.1.16/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      access-points:
        "YourSSID":
          password: "YourPassword"
```
Save and apply:
```bash
sudo netplan apply
```
---

## Step 4 – Confirm the Connection

Run: 
```bash
ip a
```
You should see your Wi-Fi interface (wlp2s0) with the static IP 192.168.1.16.
Now this address stays the same even after reboots, making SSH and Terraform a breeze later on.

---

## Step 5 – Test Internet Access

Simple connectivity check:
```bash
ping -c 4 8.8.8.8
```
If it replies, congrats — you’ve got Wi-Fi on a headless server!

---

## Troubleshooting Tips

No Wi-Fi networks showing? → Driver missing; reinstall bcmwl-kernel-source.

Interface not UP? → Use sudo ip link set wlp2s0 up.

Still no IP? → Run sudo netplan try to see YAML errors before applying.

---

## What’s Next

Now that the server is fully on Wi-Fi with a static IP, the next step is making it accessible remotely — without touching the keyboard again.

In Part 3, we’ll:

Enable SSH access from WSL (Windows Ubuntu).

Set up passwordless keys.

Add a few quality-of-life commands like a custom battery check and remote shutdown.
