---
title: "From Old Mac to DevOps Lab – Part 3: SSH Access, Battery Command & Remote Control"
description: "Making my Ubuntu Server Mac completely headless — passwordless SSH, remote commands, and a custom battery check that works like magic."
date: 2025-10-09
tags: [Ubuntu Server, SSH, Automation, DevOps Lab, Remote Access]
---

# 🖧 From Old Mac to DevOps Lab – Part 3: SSH Access, Battery Command & Remote Control

By now the Mac is running Ubuntu Server, sitting on Wi-Fi with a static IP.  
Time to take it to the next level — full **remote access** from my Windows machine using WSL (Ubuntu on Windows).  

Once I finished this part, I could log in, run updates, check the battery, even shut it down — all from my Windows terminal.  
No more touching the Mac.

---

## 🔹 Step 1 – Install SSH Server on the Mac

On the Ubuntu Server:
```bash
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
sudo systemctl status ssh
```
If it says “active (running)”, you’re ready to connect.

---

## Step 2 – Generate an SSH Key Pair (on WSL)

On your Windows WSL Ubuntu:
```bash
ssh-keygen -t ed25519 -C "wsl-to-mac"
```
Just hit Enter for the default path and skip the passphrase for now.
This creates two files under ~/.ssh/ → id_ed25519 (private) and id_ed25519.pub (public).

---

##Step 3 – Copy Your Key to the Mac

Still in WSL:
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub tony@192.168.1.16
```
Replace tony with your user.
Once it succeeds, you can log in without typing your password:
```bash
ssh tony@192.168.1.16
```
---

## Step 4 – Make It Even Easier with an Alias

Edit your SSH config on WSL:

```bash
nano ~/.ssh/config
```
Add: 
```bash
Host macserver
    HostName 192.168.1.16
    User tony
    IdentityFile ~/.ssh/id_ed25519
```
Now you can just type:
```bash
ssh macserver
```
and boom — you’re inside.

---  

## Step 5 – Create a Battery Command (Why Not?)

Because it’s still a laptop, I wanted to know its charge without logging in manually.
Inside the Mac, edit ~/.bashrc:
```bash
nano ~/.bashrc
#Add this line:
alias battery="upower -i \$(upower -e | grep BAT) | grep -E 'state|to full|percentage'"
#Save and reload:
source ~/.bashrc
#Now just type:
battery
#and you’ll get something like:
 state:               discharging
  percentage:          84%
  time to empty:       2.4 hours
#Yes — even headless machines can tell you how tired they are. 🔋
```
---

## Step 6 – Remote Shutdown or Reboot

When I’m done for the day:
```bash
sudo shutdown now
```
That’s it. No screen, no keyboard — just commands from my Windows terminal.

---

## What’s Next

The foundation is ready:

The foundation is ready:  
- **Ubuntu Server**
- **Wi-Fi + Static IP**
- **SSH Access**

In Part 4, I’ll connect Docker and Terraform so I can deploy containers on the Mac straight from WSL — as if it were a cloud VM.
That’s where this project really turns into a DevOps playground.

✦ Tony
CloudPilot 365 | Because the cloud starts at home.