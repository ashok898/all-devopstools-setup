 **FULL, DETAILED, PROFESSIONAL DAY-1 DOCUMENT** 
It includes:

✔ Every command
✔ Why that command is used
✔ Expected output
✔ Common issues and challenges
✔ Fixes / troubleshooting notes



# 🧩 **DAY-1: Ansible Setup on Azure — Full Detailed Guide With Explanations & Troubleshooting**

This document provides a complete step-by-step guide to set up an **Ansible control node on Azure**, including detailed explanations of every command and notes on challenges you may encounter.

---

# 🔹 **1. Deploy the Ubuntu VM on Azure**

### **Recommended VM Specs**

| Component | Value                   |
| --------- | ----------------------- |
| OS        | Ubuntu 22.04 / 24.04    |
| Size      | B2s (2 vCPU / 4 GB RAM) |
| Disk      | 30 GB                   |
| Access    | SSH Port 22             |

### **SSH into the VM**

```bash
ssh azureuser@<public-ip-address>
```

### **Why?**

SSH lets you connect securely to your Linux VM and start configuring your Ansible control node.

### **Common Problems & Fixes**

| Problem            | Reason                        | Fix                                             |
| ------------------ | ----------------------------- | ----------------------------------------------- |
| Permission denied  | Wrong key or username         | Verify username `azureuser`, regenerate SSH key |
| Connection timeout | NSG/Firewall blocking port 22 | Add inbound rule for 22                         |
| DNS not resolving  | Wrong IP                      | Use VM Public IP                                |

---

# 🔹 **2. Update System Packages**

```bash
sudo apt update && sudo apt upgrade -y
```

### **What this does**

* `apt update` → Updates package lists
* `apt upgrade` → Installs latest versions of all installed packages

### **Why needed?**

A fresh VM may have outdated packages. Ansible installation requires updated dependencies.

### **Common Issues**

* Slow updates → Azure repo lag
* Kernel upgrade → VM needs restart

---

# 🔹 **3. Install Essential Tools**

```bash
sudo apt install -y python3-pip python3-venv curl git unzip
```

### **What each package does**

| Package        | Purpose                                                      |
| -------------- | ------------------------------------------------------------ |
| `python3-pip`  | Allows Python-based installations (like Ansible)             |
| `python3-venv` | Creates **virtual environments** (required for Ubuntu 23/24) |
| `curl`         | Downloads scripts (used for Azure CLI install)               |
| `git`          | Version control (for managing playbooks)                     |
| `unzip`        | Extracts downloaded files                                    |

---

# 🔹 **4. Create a Python Virtual Environment (venv)**

```bash
python3 -m venv ansible-venv
```

### **What is venv?**

A **virtual environment** that isolates Python packages from the system.

### **Why needed?**

Ubuntu 23+ enforces PEP 668 — **pip cannot install system-wide packages** anymore.
So Ansible must be installed inside a virtual environment.

---

# 🔹 **5. Activate venv**

```bash
source ansible-venv/bin/activate
```

### **What happens now?**

Your shell will show:

```
(ansible-venv) root@server:
```

All Python and pip commands now work **inside this environment only**.

---

# 🔹 **6. Upgrade pip inside venv**

```bash
pip install --upgrade pip
```

### **Why?**

Old pip cannot install Azure or Ansible modules. Upgrading ensures compatibility.

---

# 🔹 **7. Install Ansible**

```bash
pip install ansible
```

### **Why this is required?**

Ansible is not included in Ubuntu 24 repositories.
Installing via pip ensures the latest version.

### **Verify installation**

```bash
ansible --version
```

---

# 🔹 **8. Install Azure CLI**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### **Command Breakdown**

| Part                                | Meaning                                         |                                              |
| ----------------------------------- | ----------------------------------------------- | -------------------------------------------- |
| `curl -sL`                          | Downloads script silently and follows redirects |                                              |
| `https://aka.ms/InstallAzureCLIDeb` | Microsoft’s official install script             |                                              |
| `                                   | sudo bash`                                      | Pipes script into Bash with admin privileges |

### **Why needed?**

Azure CLI will be used to:

* Create Service Principal
* Test authentication
* Manage Azure resources

### **Verify**

```bash
az --version
```

---

# 🔹 **9. Install Azure Ansible Collection**

```bash
ansible-galaxy collection install azure.azcollection
```

### **Why?**

This installs all Ansible modules required to automate:

* VMs
* VNets
* NSGs
* NICs
* Public IPs
* Storage
* ARM resources

---

# 🔹 **10. Create Ansible Project Folder Structure**

```bash
mkdir -p ~/ansible-azure-labs/{inventories,playbooks,vars,roles}
```

### **Folder Purpose**

| Folder        | Use                                      |
| ------------- | ---------------------------------------- |
| `inventories` | Hosts (local or Azure dynamic inventory) |
| `playbooks`   | YAML files with tasks                    |
| `vars`        | Credentials / variables                  |
| `roles`       | Reusable automation                      |

---

# 🔹 **11. Create Inventory File**

```bash
nano ~/ansible-azure-labs/inventories/hosts.ini
```

Paste:

```
[local]
localhost ansible_connection=local
```

### **Why?**

We instruct Ansible to run tasks **locally** on the control node, not via SSH.

---

# 🔹 **12. Create Test Playbook**

```bash
nano ~/ansible-azure-labs/playbooks/ping_local.yml
```

Paste:

```yaml
---
- name: Ping localhost
  hosts: local
  connection: local

  tasks:
    - name: Test ping
      ansible.builtin.ping:
```

### **Why test playbook?**

To validate:

* Ansible works
* venv is working
* Inventory is correct

---

# 🔹 **13. Run Test Playbook**

```bash
ansible-playbook -i inventories/hosts.ini playbooks/ping_local.yml
```

### **Expected Output**

```
ok=1 failed=0
```

---

# 🧨 **COMMON DAY-1 CHALLENGES & FIXES**

| Issue                                       | Cause                                 | Fix                                    |
| ------------------------------------------- | ------------------------------------- | -------------------------------------- |
| pip error: *externally-managed-environment* | Ubuntu 23+/24 restricts pip           | Use venv                               |
| OpenSSL errors                              | Old VM versions                       | Use Ubuntu 22/24                       |
| Ansible-galaxy failing                      | Python < 3.8                          | Use venv (Python 3.12)                 |
| localhost unreachable                       | Using SSH instead of local connection | Add `ansible_connection=local`         |
| ansible command not found                   | Not in venv                           | Run `source ansible-venv/bin/activate` |
| Azure CLI command not found                 | Wrong install method                  | Use official curl script               |

---

# 🎉 **Day 1 Completed Successfully**

✔ Ansible installed
✔ Azure CLI installed
✔ Azure Collection installed
✔ Proper folder structure
✔ Virtual environment
✔ A verified working playbook
10  apt update && apt upgrade -y
   11  sudo apt install -y python3-pip python3-venv unzip curl git
   12  pip install --upgrade pip
   13  pip install ansible
   14  sudo apt install python3.12-venv -y
   15  python3 -m venv ansible-venv
   16  source ansible-venv/bin/activate
   17  pip install --upgrade pip
   18  pip install ansible
   19  ansible --version
   20  python --version
   21  echo "source ~/ansible-venv/bin/activate" >> ~/.bashrc
   22  source ~/.bashrc
   23  ansible-galaxy collection install azure.azcollection
   24  ansible --version
   25  top
   26  htop
   27  free -h
   28  df -h
   29  ll
   30  ansible-galaxy collection install azure.azcollection
   31  mkdir -p ~/ansible-azure-labs/{playbooks,inventories,vars,roles}
   32  cd ~/ansible-azure-labs
   37  vi inventories/hosts.ini
   38  ansible-playbook -i inventories/host.ini
   39  vi playbooks/ping_local.yml
   41  ansible-playbook -i inventories/hosts.ini playbooks/ping_local.yml
  

<img width="1607" height="502" alt="image" src="https://github.com/user-attachments/assets/8ab3a024-c11f-488b-9626-4d6c8a26c203" />







Got it. Let’s forget all the confusion and write **one clean, step-by-step guide** with the **exact commands and paths** that match what is working on your VM right now.

I’ll break it into:

* Part A – Azure side (Cloud Shell / your PC, **not** on VM)
* Part B – Ubuntu VM setup (everything in `/root`)
* Part C – Test with Ansible playbook

---

## 🅰️ Part A – Azure side (Cloud Shell or your local machine)

### 1. Login and get Subscription ID

**Run in Cloud Shell or your PC (NOT on the VM):**

```bash
az login
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo $SUBSCRIPTION_ID
```

Copy the `SUBSCRIPTION_ID`.

### 2. Reset / get service principal credentials

You already have `ansible-app`, but we reset its secret to be sure:

```bash
az ad sp credential reset --name "ansible-app" \
  --query "{clientId:appId, clientSecret:password, tenant:tenant}" -o json
```

From this output, copy:

* `clientId` → this is **CLIENT_ID**
* `clientSecret` → this is **CLIENT_SECRET**
* `tenant` → this is **TENANT_ID**

You now have:

* SUBSCRIPTION_ID
* CLIENT_ID
* CLIENT_SECRET
* TENANT_ID

Keep them safe.

---

## 🅱️ Part B – On the Ubuntu VM (everything as root in `/root`)

You are usually at:

```bash
root@ansible-azure:~#
pwd          # shows /root
```

### 1. Install system packages

**Run in `/root`:**

```bash
sudo apt update -y
sudo apt install -y python3 python3-pip python3-venv git curl
```

### 2. Create and activate virtual environment

**Run in `/root`:**

```bash
python3 -m venv /root/ansible-venv
source /root/ansible-venv/bin/activate
```

Your prompt should look like:

```bash
(ansible-venv) root@ansible-azure:~#
```

### 3. Install Ansible

**Still in `/root` with venv active:**

```bash
pip install --upgrade pip
pip install ansible
```

### 4. Install Azure Ansible collection

**Still in `/root` with venv active:**

```bash
ansible-galaxy collection install azure.azcollection
```

This installed the collection under:

```text
/root/ansible-venv/lib/python3.10/site-packages/ansible_collections/azure/azcollection
```

### 5. Install the collection’s Python dependencies

**Still in `/root` with venv active:**

```bash
pip install -r /root/ansible-venv/lib/python3.10/site-packages/ansible_collections/azure/azcollection/requirements.txt
```

### 6. Install Azure CLI (this fixes `azure.cli` error)

**Still in `/root` (venv can be active or not, doesn’t matter):**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
```

Let this finish completely.

After that, if needed, reactivate venv:

```bash
source /root/ansible-venv/bin/activate
```

### 7. Set Azure environment variables

**In `/root` with venv active:**

Replace with your actual values:

```bash
export AZURE_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
export AZURE_CLIENT_ID="YOUR_CLIENT_ID"
export AZURE_SECRET="YOUR_CLIENT_SECRET"
export AZURE_TENANT="YOUR_TENANT_ID"
```

Check they’re set:

```bash
env | grep AZURE_
```

To make them persistent:

```bash
cat << 'EOF' >> /root/.bashrc
export AZURE_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
export AZURE_CLIENT_ID="YOUR_CLIENT_ID"
export AZURE_SECRET="YOUR_CLIENT_SECRET"
export AZURE_TENANT="YOUR_TENANT_ID"
EOF
```

Later, when you log in again:

```bash
source /root/.bashrc
source /root/ansible-venv/bin/activate
```

---

## 🅲 Part C – Ansible test setup (in `/root/ansible-test`)

### 1. Create project folder

**Run in `/root` (venv active):**

```bash
mkdir -p /root/ansible-test
cd /root/ansible-test
pwd        # should show /root/ansible-test
```

### 2. Create `inventory.ini`

**Run in `/root/ansible-test`:**

```bash
cat > /root/ansible-test/inventory.ini << 'EOF'
[local]
localhost ansible_connection=local ansible_python_interpreter=/root/ansible-venv/bin/python
EOF
```

> `ansible_python_interpreter` is important: it forces Ansible to use the Python from your venv where all Azure stuff is installed.

### 3. Create `test_azure.yml`

**Run in `/root/ansible-test`:**

```bash
cat > /root/ansible-test/test_azure.yml << 'EOF'
---
- hosts: local
  connection: local
  gather_facts: false
  collections:
    - azure.azcollection

  tasks:
    - name: Test Azure
      azure_rm_resourcegroup_info:
      register: out

    - debug:
        var: out.resourcegroups
EOF
```

### 4. Run the playbook

**Make sure you’re in `/root/ansible-test` and venv is active:**

```bash
cd /root/ansible-test
source /root/ansible-venv/bin/activate
ansible-playbook -i inventory.ini test_azure.yml
```

If everything is correct, you’ll see a list (or at least an empty list) of `resourcegroups` from your Azure subscription.

---

That’s the full **working process**, command by command, with **where to run each one**.
If you want, next I can add a **second playbook** to create a VM using the same setup.



