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

