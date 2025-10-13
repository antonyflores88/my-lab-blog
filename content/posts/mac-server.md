---
title: "From Old Mac to DevOps Lab – Part 1: Installing Ubuntu Server (Headless Setup)"
description: "Breathing new life into a 2012 MacBook by turning it into a lightweight Ubuntu Server — no GUI, no bloat, just pure performance."
date: 2025-10-07
tags: [Ubuntu Server, Linux, DevOps Lab, Headless Setup, MacBook]
---

# From Old Mac to DevOps Lab – Part 1: Installing Ubuntu Server (Headless Setup)

I’ve had this old 2012 Intel MacBook collecting dust.  
Every time I tried running Ubuntu Desktop on it, it turned into a hand-warmer instead of a computer.  
So I thought: what if I strip it down completely?  
No GUI, no fluff — just **Ubuntu Server**, running lean and cool, and see if I can turn it into a mini DevOps lab.

This post kicks off a short series where I rebuild that Mac into a proper remote server — the kind you’d use in the cloud — but running right at home.

---

## Step 1 — Download Ubuntu Server

Head over to [ubuntu.com/download/server](https://ubuntu.com/download/server) and grab the latest LTS ISO (I used 24.x).  
On Windows, I flashed it onto a USB stick with **Rufus** — choose “GPT / UEFI” if your Mac supports it.

Then I plugged it into the Mac, held `Option` while booting, and selected the USB drive.

---

## Step 2 — The Installation

During setup:
- Pick **Install Ubuntu Server**, not “Try”.
- Choose your language, keyboard, and time zone.
- When it asks about network, **plug in Ethernet** for now — it’ll make everything smoother.
- Disk setup: I went for “Use entire disk” (this wipes it, so back up first).

When it’s done, reboot and remove the USB.  
If you did it right, you’ll land in a black login screen — no desktop, no icons, just a terminal blinking at you.  
Perfect.

---

## Step 3 — First Login and Update

Login with the username you created.  
Then update the packages:

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

---

## Step 4 — Why Headless?

No GUI = no wasted CPU cycles, no fans screaming, no lag.
This Mac went from running hot to running quietly cool.
And I’m not missing anything — I can do everything through SSH later.

---

## Step 5 — Next Up
In Part 2, I’ll handle Wi-Fi and static IP setup using Netplan, so the Mac stays connected even without Ethernet.
We’ll also prep it for remote access over SSH so I can control it entirely from my Windows machine.

Stay tuned — things are about to get real fun.

✦ Tony
CloudPilot 365 | Because the cloud starts at home.