# VS Code Server on EC2 – User Management Documentation

---

## 1. Accessing the EC2 Instance

Use SSH with your private key:

```bash
ssh -i vscode-key.pem ubuntu@13.251.220.49
```

- [`vscode-key.pem`](https://github.com/apperph/code-server/blob/e92d27702e2c7d0d61bf92a5d3a48f9f3de67759/vscode-key.pem) – your SSH private key  
- `ubuntu` – default EC2 user  
- `13.251.220.49` – public IP of the EC2 instance  

---

## 2. Checking Existing Users

### List all home directories:

```bash
ls /home
```

Shows Linux users like `user1`, `user12`, `user16`, etc.

### Check which code-server instances are running:

```bash
ps aux | grep code-server
```

Example output:

```bash
user1   588  ... /usr/lib/code-server/lib/node /usr/lib/code-server
user12  1789 ... /usr/lib/code-server/lib/node /usr/lib/code-server
```

The port each user is using can be found in their `config.yaml`.

---

## 3. Viewing a User’s code-server Configuration

Each user has a per-user configuration at:

```
/home/<username>/.config/code-server/config.yaml
```

Example:

```bash
sudo cat /home/user1/.config/code-server/config.yaml
```

Output:

```yaml
bind-addr: 127.0.0.1:8081
auth: password
password: DevPassword2026!
```

- `bind-addr` – the local port the code-server listens on  
- `auth/password` – the login password  

> ⚠️ Note: You need `sudo` to read other users’ config files.

---

## 4. Adding a New User

### Create the Linux user:

```bash
sudo adduser user36
echo "user36:DevPassword2026!" | sudo chpasswd
```

### Assign a unique code-server port (make sure it’s not in use):

```bash
# Example: assign port 9006
sudo -u user36 mkdir -p /home/user36/.config/code-server
sudo tee /home/user36/.config/code-server/config.yaml > /dev/null <<EOF
bind-addr: 0.0.0.0:9006
auth: password
password: "DevPassword2026!"
cert: false
EOF
```

---

## 5. Starting code-server for the New User

If using systemd template:

```bash
sudo systemctl enable --now code-server@user36
```

Verify it’s running:

```bash
ps aux | grep code-server | grep user36
```

---

## 6. Configuring Nginx for the New User

Add a new location block in Nginx config (`/etc/nginx/sites-available/default`):

```nginx
# USER 36
location = /user36 { return 301 /user36/; }
location /user36/ {
    proxy_pass http://127.0.0.1:9006/;
    proxy_set_header Host $host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection upgrade;
    proxy_set_header Accept-Encoding gzip;
}
```

- `9006` matches the port in the user’s `config.yaml`

After editing, test and reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 7. Accessing the User’s Code-Server

URL format:

```
http://<your-domain-or-IP>/<username>/
```

Example:

```
http://13.251.220.49/user36/
```

Password: `DevPassword2026!`

Users do not need direct SSH access; Nginx handles routing.

---

## 8. Notes

- Always assign a unique port per user to avoid conflicts  
- Code-server runs locally (`127.0.0.1`); only Nginx exposes it externally  
- Security Group: Only open ports **22 (SSH)**, **80 (HTTP)**, **443 (HTTPS)**  
- Do NOT open code-server ports (`9001–9006`) to the internet
