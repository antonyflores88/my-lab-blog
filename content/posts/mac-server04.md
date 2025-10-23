---
title: "Terra + Docker – Multi-Environment Setup Part 01"
date: 2025-10-21
author: "Tony"
tags: ["Terraform", "Docker", "Flask", "NGINX", "DevOps Lab"]
cover:
    image: "images/terra_docker_lab02.png"
    alt: "Terraform and Docker multi-environment setup"
    caption: "Simulating multi-environment deployments locally"
---

## 🌩️ Building My Terraform + Docker Cloud Lab (Part 1)

Lately I’ve been building a personal “micro-cloud” lab using **Terraform and Docker**, with one goal — simulate a real multi-environment setup (prod, staging, dev) just like in real-world projects. This first part covers how I built the base infrastructure, set up a reverse proxy, and improved the Flask apps.

---

### ⚙️ Phase 1 – Building the Base Infrastructure

**Goal:** Create a simulated multi-environment setup using Terraform + Docker.

I defined three virtual networks — `vnet-prod`, `vnet-staging`, and `vnet-dev` — each hosting a simple Flask app container.  
All used the same image, listening on port `5000` internally, but mapped to different external ports:

- 5001 → prod  
- 5002 → staging  
- 5003 → dev  

Terraform created everything automatically:

```hcl
resource "docker_network" "vnet_prod" { ... }
resource "docker_network" "vnet_staging" { ... }
resource "docker_network" "vnet_dev" { ... }
```
After deployment, each app was reachable directly at: 

http://192.168.1.16:5001
http://192.168.1.16:5002
http://192.168.1.16:5003

### Phase 2 – Adding the NGINX Reverse Proxy

Goal: Route all traffic through a single gateway on port 8080.

The NGINX container handled routing between environments:

```bash
http {
    server {
        listen 80;
        location /prod/ { proxy_pass http://app-prod:5000/; }
        location /staging/ { proxy_pass http://app-staging:5000/; }
        location /dev/ { proxy_pass http://app-dev:5000/; }
    }
}
```
Important fix: Trailing slashes in location and proxy_pass are critical.
Without them, Flask routes break because the prefixes aren’t stripped.

The result should be you reaching the applications using the port 8080 of the Nginx server, using the /prod, /staging and /dev accordinly.

### 🐍 Phase 3 – Flask Enhancements

I added two simple routes:

- **/check → health info**
- **/env → current environment**

Example output: {"env": "prod", "db_host": null, "redis_host": null}

Bugs I hit along the way:

Forgot to add f before triple quotes → Flask printed {ENVIRONMENT} literally instead of substituting it.
✅ Fix:
```bash
html = f"""Welcome to Tony Cloud Lab Server ({ENVIRONMENT} Environment)"""
```
Got NameError: jsonify not defined — turns out Docker was caching an old version of app.py. This is where I found troubleshooting containers with Terraform is not very practical, because sometimes Terraform will not realize small changes on the Docker image and will not applied them, as a newby on Terraform on those fixes I have been using Terraform destroy and plan + apply again, this has save me more time that traying to "taint" the image, on top of that, if you try to do it, because the image is being use by other container, docker will not allow you to modified it, so that would be a downsize of using the same image for all. 

## 🧩 Phase 4 – Adding Backends (Postgres & Redis)

Goal: Add backend services per environment.

- **Prod → PostgreSQL**
- **Staging → Redis**

Example Terraform snippets:

```bash
resource "docker_container" "postgres" {
  name  = "postgres-prod"
  image = "postgres:16"
  env = [
    "POSTGRES_USER=tony",
    "POSTGRES_PASSWORD=superpass",
    "POSTGRES_DB=tonylab"
  ]
  networks_advanced {
    name = docker_network.vnet_prod.name
  }
}

resource "docker_container" "redis" {
  name  = "redis-staging"
  image = "redis:7"
  networks_advanced {
    name = docker_network.vnet_staging.name
  }
}
```

The painful part: Postgres fought me at every step, not kidding. Authentication errors, socket issues, and password mismatches everywhere. It turns out Postgres only applies environment variables during the first initialization. Even if you change the password later, it won’t take effect unless you remove the data volume.

I tried everything: editing pg_hba.conf, forcing TCP connections, DSN strings, listen_addresses='*', but Docker networking kept breaking external authentication.

Lesson: Postgres is powerful but not friendly for quick multi-container dev lab setups. Because of that, I decided to go full Redis for testing purposes, to simplify everything with one Redis instance to rule them all.

How I did it: I modified the Terraform main.tf file to remove Postgres and repoint the prod container to Redis, removed the other variables, and used only one environment variable: "REDIS_HOST=redis-shared".

### 🧠 Phase 6 – Flask Final Form

Here’s the final /check route that validates Redis connectivity:

```bash
import redis
from flask import Flask, jsonify
import os

app = Flask(__name__)
ENVIRONMENT = os.getenv('ENVIRONMENT', 'dev')
REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')

@app.route('/check')
def check_connections():
    status = {"env": ENVIRONMENT}
    try:
        r = redis.Redis(host=REDIS_HOST, port=6379, socket_connect_timeout=3)
        pong = r.ping()
        status["redis_host"] = REDIS_HOST
        status["redis_status"] = "ok" if pong else "no-pong"
    except Exception as e:
        status["redis_status"] = f"error: {e.__class__.__name__}"
    return jsonify(status), 200
```
Note: on the requirements.txt I just leave it with this 2 lines: 
flask==3.0.3
redis==5.0.8

Final result: 

http://192.168.1.16:8080/prod/check →
{"env":"prod","redis_host":"redis-shared","redis_status":"ok"}

http://192.168.1.16:8080/staging/check →
{"env":"staging","redis_host":"redis-shared","redis_status":"ok"}

Everything connected cleanly — zero auth issues, instant response times.
Redis wins this one 😄.

| Category | Pain | Fix / Lesson |
|-----------|------|--------------|
| Flask | Cached imports, missing `f` | Always rebuild the image after code changes |
| Terraform | State cache | `terraform taint` saves the day |
| NGINX | Route prefix issues | Trailing slashes fix everything |
| Postgres | Auth nightmares | Env vars only apply on first init, destroy volume to reset |
| Redis | Lightweight and instant | One ping = working setup |
| Overall | Debugging patience | The pain builds understanding, not just success |


### ✅ Final Verdict

This project turned into a mini production-style cloud simulation:

- **Reverse proxy gateway (NGINX)**
- **Multiple isolated environments (prod/staging/dev)**
- **Shared backend service**
- **Infrastructure as Code (Terraform)**
- **Self-contained health endpoints**

Not just a lab, this is a cloud playground for testing real-world concepts in isolation.