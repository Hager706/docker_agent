# 🚀 Jenkins SSH Agent Setup Guide 

## 🏗️ Steps 

### 1.👤 Create the `jenkins` User 
On the target server (`192.168.105.11`), create the `jenkins` user:

```bash
sudo adduser jenkins
```

Add the `jenkins` user to the sudo group (optional, for administrative tasks):

```bash
sudo usermod -aG sudo jenkins
```

---

### 2.🔑 Generate SSH Keys for the `jenkins` User 
Switch to the `jenkins` user:

```bash
sudo -u jenkins bash
```

Generate an SSH key pair:

```bash
ssh-keygen -t rsa -b 4096 -C "jenkins@192.168.105.11"
```

Save the key in the default location (`/home/jenkins/.ssh/id_rsa`).

---

### 3.📌 Set Up the `.ssh` Directory 
Ensure the `.ssh` directory has the correct permissions:

```bash
chmod 700 /home/jenkins/.ssh
chmod 600 /home/jenkins/.ssh/id_rsa
chmod 644 /home/jenkins/.ssh/id_rsa.pub
```

---

### 4.📝 Add the Public Key to `authorized_keys` 
Copy the public key to the `authorized_keys` file:

```bash
cat /home/jenkins/.ssh/id_rsa.pub >> /home/jenkins/.ssh/authorized_keys
chmod 600 /home/jenkins/.ssh/authorized_keys
```

---

### 5.⚙️ Update SSH Server Configuration 
Open the SSH server configuration file:

```bash
sudo nano /etc/ssh/sshd_config
```
```bash
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PubkeyAcceptedAlgorithms +ssh-rsa
```

Add the `jenkins` user to `AllowUsers` :

```bash
AllowUsers hager jenkins
```

Restart the SSH service:

```bash
sudo systemctl restart sshd
```

---
### 6.🔑 Add the Private Key to Jenkins Credentials 
```bash
cat /home/jenkins/.ssh/id_rsa
```

Add the private key to Jenkins credentials:

1. Go to **Manage Jenkins > Credentials > System > Global credentials**.
2. Click **Add Credentials**.
3. Fill in the following details:
   - **Kind**: SSH Username with private key
   - **Scope**: Global
   - **ID**: jenkins (or any preferred ID)
   - **Username**: jenkins
   - **Private Key**: Paste the private key content
4. Save the credentials.

---

### 8.🔄 Configure the Jenkins Master 
1. Go to **Manage Jenkins > Nodes > New Node >**.
2. Configure the Slave Node
  - Name: ubuntu-slave
  - Remote root directory: Specify a directory on the Ubuntu VM where Jenkins can store files **(/home/jenkins/jenkins-slave)**
  - Labels: Add labels (ubuntu)
2. Launch method: Choose Launch agents via SSH.
  - Host: Enter the IP address of the Ubuntu VM.
  - Credentials: Add credentials that has **ID jenkins**
3. Save the configuration.

---

### 9.📂 Create the Working Directory 
On the target server, create the working directory for the Jenkins agent:

```bash
sudo mkdir -p /home/jenkins/jenkins-slave
sudo chown -R jenkins:jenkins /home/jenkins/jenkins-slave
sudo chmod 755 /home/jenkins/jenkins-slave
```

---
Step 1: Prepare the Ubuntu VM
1. Install Java 17 on the Ubuntu VM:
sudo apt update
sudo apt install openjdk-17-jdk
java -version

2. Steps to Install Docker and Kubernetes CLI on the VM (Agent)
1. Install Docker on the VM
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker
Verify Installation:
docker --version
2. Install Kubernetes CLI (kubectl) on the VM


3. Reuse Credentials from the Master
 can reuse the same Docker and Kubernetes credentials on the agent that are already configured on the Jenkins master.
 Docker:

Copy the Docker configuration file (usually located at ~/.docker/config.json) from the Jenkins master to the agent:
on agent:
mkdir -p ~/.kube ~/.docker
chmod 700 ~/.kube ~/.docker
sudo systemctl restart ssh
 sudo usermod -aG docker jenkins

on master:
scp ~/.docker/config.json jenkins@192.168.105.11:~/.docker/config.json
scp ~/.kube/config jenkins@192.168.105.11:~/.kube/config

