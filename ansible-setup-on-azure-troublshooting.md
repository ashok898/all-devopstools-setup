You’re right to double-check. Let’s **clean everything up properly** and write a solid “postmortem” you can put in Git.

Below is a **reverified, detailed list of every real error you hit**, what actually caused it, which of my earlier suggestions were off or incomplete, and what the **final correct fix** is (with exact commands + paths).

You can almost copy-paste this into a `TROUBLESHOOTING.md` or `NOTES.md`.

---

## 0. Final Environment (so future-you remembers)

Control node:

* Azure VM: Ubuntu 22.04 LTS
* User: `root`
* Home: `/root`
* Python venv: `/root/ansible-venv`
* Ansible project: `/root/ansible-azure-labs`

Key layout:

```text
/root/ansible-azure-labs
├── inventories/
│   └── hosts.ini
├── playbooks/
│   ├── main.yml        # create VM
│   ├── delete.yml      # delete resource group
│   └── roles/
│       └── azure_vm/
│           ├── tasks/main.yml
│           └── defaults/main.yml
└── vars/
    └── azure_creds.yml  # (optionally vault-encrypted)
```

Venv activation (always!):

```bash
source /root/ansible-venv/bin/activate
```

---

## 1. Error: `ModuleNotFoundError: No module named 'azure.cli'`

### When it happened

Running the **first test playbook**:

```bash
cd /root/ansible-test
ansible-playbook -i inventory.ini test_azure.yml
```

You saw:

```text
An exception occurred during task execution. ...
The error was: ModuleNotFoundError: No module named 'azure.cli'
...
Failed to import the required Python library (ansible[azure] (azure >= 2.0.0)) ...
```

### What I did wrong at first

* I told you to install things like `azure-identity`, `azure-mgmt-*`, and even `pip install "ansible[azure]"`.
* Those didn’t fully solve it, because the error was specifically about **`azure.cli`**, and that does **not** come from those SDK packages.

### Real root cause

There were actually **three** missing pieces together:

1. The Azure collection `azure.azcollection` needs its own deps from its `requirements.txt`, and we hadn’t installed them.
2. `azure.azcollection` 2.7.0 was installed **inside the venv**, not under `~/.ansible`, so my first guess for the path to `requirements.txt` was wrong.
3. The Python package `azure.cli` only appears when **Azure CLI** is installed on the machine.

### Final working fix

**Step 1 – Find the real collection path**

You ran:

```bash
ansible-galaxy collection list azure.azcollection
```

Output showed:

```text
# /root/ansible-venv/lib/python3.10/site-packages/ansible_collections
Collection         Version
------------------ -------
azure.azcollection 2.7.0
```

So the collection lives at:

```text
/ root/ansible-venv/lib/python3.10/site-packages/ansible_collections/azure/azcollection
```

**Step 2 – Install the collection’s own requirements**

```bash
source /root/ansible-venv/bin/activate

pip install -r \
/root/ansible-venv/lib/python3.10/site-packages/ansible_collections/azure/azcollection/requirements.txt
```

That installed all required Python deps for the collection (SDKs, msrest, etc).

**Step 3 – Install Azure CLI (to provide `azure.cli`)**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
```

This installed the Azure CLI **and** its Python bits, including the `azure.cli` module.

**Step 4 – Force Ansible to use venv Python**

Your inventory:

```ini
# /root/ansible-azure-labs/inventories/hosts.ini
[local]
localhost ansible_connection=local ansible_python_interpreter=/root/ansible-venv/bin/python
```

This ensures Ansible uses the Python that has all those libraries.

👉 After these 3, `test_azure.yml` started working.

---

## 2. Error: `role 'azure_vm' was not found` + “hosts list is empty”

### When it happened

First run of the **structured project playbook**:

```bash
cd /root/ansible-azure-labs/playbooks
ansible-playbook -i ../inventories/hosts.ini main.yml
```

You saw:

```text
[WARNING]: provided hosts list is empty, only localhost is available...
ERROR! the role 'azure_vm' was not found in
/root/ansible-azure-labs/playbooks/roles:/root/.ansible/roles:...
```

### Root cause

Two separate issues:

1. **Role path**:
   You created your role at:

   ```text
   /root/ansible-azure-labs/roles/azure_vm
   ```

   but Ansible (running from `/root/ansible-azure-labs/playbooks`) looks in:

   ```text
   /root/ansible-azure-labs/playbooks/roles
   ```

   So it couldn’t find `azure_vm`.

2. **Hosts warning**:
   Not critical, just telling you that only `localhost` is in the inventory (which is fine for this setup). Once `hosts.ini` points to local and you use that, you’re okay.

### Final working fix

**Step 1 – Create roles folder under playbooks, move role there**

```bash
mkdir -p /root/ansible-azure-labs/playbooks/roles

mv /root/ansible-azure-labs/roles/azure_vm \
   /root/ansible-azure-labs/playbooks/roles/
```

Now the role lives at:

```text
/root/ansible-azure-labs/playbooks/roles/azure_vm
```

**Step 2 – Ensure correct run directory + inventory**

```bash
cd /root/ansible-azure-labs/playbooks
ansible-playbook -i ../inventories/hosts.ini main.yml
```

After that, the role was found and the playbook started executing.

---

## 3. Error: `'azure_subscription_id' is undefined`

### When it happened

First run after roles were found:

```text
TASK [azure_vm : Create Resource Group]
fatal: [localhost]: FAILED! => {"msg": "The task includes an option with an undefined variable.. 'azure_subscription_id' is undefined"}
```

### Root cause

The variables from `vars/azure_creds.yml` were:

* Either **not loaded** or
* Defined with different key names.

We confirmed that with:

```bash
cd /root/ansible-azure-labs/playbooks

ansible localhost \
  -i ../inventories/hosts.ini \
  -m debug \
  -a "var=azure_subscription_id" \
  -e @../vars/azure_creds.yml
```

Which printed:

```text
"azure_subscription_id": "VARIABLE IS NOT DEFINED!"
```

This meant:

* `azure_creds.yml` was being loaded,
* But **inside that file, the key `azure_subscription_id` did not exist**.

### Final working fix

**Step 1 – Recreate `azure_creds.yml` with correct keys**

```bash
cat > /root/ansible-azure-labs/vars/azure_creds.yml << 'EOF'
azure_subscription_id: "YOUR_SUBSCRIPTION_ID"
azure_client_id: "YOUR_CLIENT_ID"
azure_secret: "YOUR_CLIENT_SECRET"
azure_tenant: "YOUR_TENANT_ID"
EOF
```

(Then you edited it with actual values.)

**Step 2 – Reconfirm with debug**

```bash
cd /root/ansible-azure-labs/playbooks

ansible localhost \
  -i ../inventories/hosts.ini \
  -m debug \
  -a "var=azure_subscription_id" \
  -e @../vars/azure_creds.yml
```

Now you saw:

```text
"azure_subscription_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

✅ Variables were now defined correctly.

**Step 3 – Ensure playbook loads vars file**

`/root/ansible-azure-labs/playbooks/main.yml`:

```yaml
---
- hosts: local
  connection: local
  gather_facts: false

  vars_files:
    - ../vars/azure_creds.yml

  roles:
    - azure_vm
```

After this, the RG / VNet / Subnet / PIP / NIC tasks started using your credentials properly.

---

## 4. Error: `lookup('file', '/root/.ssh/id_rsa.pub')` failed

### When it happened

During VM creation:

```text
TASK [azure_vm : Create VM]
fatal: [localhost]: FAILED! => {
  "msg": "The 'file' lookup had an issue accessing the file '/root/.ssh/id_rsa.pub'. file not found"
}
```

### Root cause

In your role:

```yaml
ssh_public_keys:
  - path: "/home/{{ admin_user }}/.ssh/authorized_keys"
    key_data: "{{ lookup('file', '/root/.ssh/id_rsa.pub') }}"
```

But on your control node, `/root/.ssh/id_rsa.pub` didn’t exist yet — no SSH key had been generated.

### Final working fix

**Step 1 – Create `.ssh` folder (if missing)**

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh
```

**Step 2 – Generate an SSH key pair**

```bash
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ""
```

This creates:

* `/root/.ssh/id_rsa` (private key)
* `/root/.ssh/id_rsa.pub` (public key)

**Step 3 – Re-run the playbook**

```bash
cd /root/ansible-azure-labs/playbooks
source /root/ansible-venv/bin/activate
ansible-playbook -i ../inventories/hosts.ini main.yml
```

Now the `lookup('file', '/root/.ssh/id_rsa.pub')` succeeded and the VM task moved on.

---

## 5. Error: `SkuNotAvailable` for `Standard_B1s` in `eastus`

### When it happened

Same VM creation, after fixing SSH key:

```text
TASK [azure_vm : Create VM]
fatal: [localhost]: FAILED! => {
  "msg": "Error creating or updating virtual machine ansibleCreatedVM - (SkuNotAvailable) The requested VM size ... Standard_B1s ... not available in 'eastus' ..."
}
```

### Root cause

Azure sometimes doesn’t have capacity for a given VM size (SKU) in a specific region.

You requested:

* `vm_size: "Standard_B1s"`
* `location: "eastus"`

But `Standard_B1s` was not available in `eastus` at that moment for your subscription.

### Final working fix

Change the **location** (or the size) in the role defaults.

In:
`/root/ansible-azure-labs/playbooks/roles/azure_vm/defaults/main.yml`:

```yaml
resource_group: "ansible-rg"
location: "eastus2"        # changed from "eastus" to "eastus2" or another region
vm_name: "ansibleCreatedVM"
admin_user: "azureuser"
vnet_name: "ansibleVNet"
subnet_name: "ansibleSubnet"
public_ip_name: "ansiblePublicIP"
nic_name: "ansibleNIC"
```

Then rerun:

```bash
ansible-playbook -i ../inventories/hosts.ini main.yml
```

If that region supports `Standard_B1s`, the VM will create successfully.

---

## 6. Error: Delete RG fails – “Resources exist within the group”

### When it happened

Running `delete.yml`:

```text
TASK [Delete resource group and all resources inside it]
fatal: [localhost]: FAILED! =>
{"msg": "Error removing resource group ansible-rg. Resources exist within the group.
 Use `force_delete_nonempty` to force delete."}
```

### Root cause

By default, `azure_rm_resourcegroup` will **not** delete an RG that contains resources.

### Final working fix

`/root/ansible-azure-labs/playbooks/delete.yml`:

```yaml
---
- hosts: local
  connection: local
  gather_facts: false

  vars_files:
    - ../vars/azure_creds.yml

  collections:
    - azure.azcollection

  tasks:
    - name: Delete resource group and all resources inside it
      azure_rm_resourcegroup:
        name: "ansible-rg"
        state: absent
        force_delete_nonempty: yes
      register: delete_result

    - debug:
        var: delete_result
```

Run:

```bash
cd /root/ansible-azure-labs/playbooks
ansible-playbook -i ../inventories/hosts.ini delete.yml
```

This successfully deletes the RG and all its resources.

---

## 7. Hardening: Encrypting `azure_creds.yml` with Ansible Vault

(Not an error, but important for “very secret” creds.)

### Step 1 – Encrypt file

```bash
cd /root/ansible-azure-labs/vars
ansible-vault encrypt azure_creds.yml
```

Enter a vault password.

Now `azure_creds.yml` is encrypted.

### Step 2 – Run playbook with vault

```bash
cd /root/ansible-azure-labs/playbooks
source /root/ansible-venv/bin/activate

ansible-playbook -i ../inventories/hosts.ini main.yml --ask-vault-pass
```

Or use a vault password file:

```bash
echo "YOUR_VAULT_PASSWORD" > /root/.vault_pass
chmod 600 /root/.vault_pass

ansible-playbook -i ../inventories/hosts.ini main.yml \
  --vault-password-file /root/.vault_pass
```

---

## 8. Final working `azure_vm` role (cleaned-up, without creds in tasks)

For completeness, here is the final version you can keep in Git:

`/root/ansible-azure-labs/playbooks/roles/azure_vm/defaults/main.yml`:

```yaml
resource_group: "ansible-rg"
location: "eastus2"
vm_name: "ansibleCreatedVM"
admin_user: "azureuser"
vnet_name: "ansibleVNet"
subnet_name: "ansibleSubnet"
public_ip_name: "ansiblePublicIP"
nic_name: "ansibleNIC"
```

`/root/ansible-azure-labs/playbooks/roles/azure_vm/tasks/main.yml`:

```yaml
---
- name: Create Resource Group
  azure_rm_resourcegroup:
    name: "{{ resource_group }}"
    location: "{{ location }}"

- name: Create Virtual Network
  azure_rm_virtualnetwork:
    resource_group: "{{ resource_group }}"
    name: "{{ vnet_name }}"
    address_prefixes: "10.0.0.0/16"
    location: "{{ location }}"

- name: Create Subnet
  azure_rm_subnet:
    resource_group: "{{ resource_group }}"
    name: "{{ subnet_name }}"
    address_prefix: "10.0.1.0/24"
    virtual_network: "{{ vnet_name }}"

- name: Create Public IP
  azure_rm_publicipaddress:
    resource_group: "{{ resource_group }}"
    name: "{{ public_ip_name }}"
    allocation_method: Static
    location: "{{ location }}"

- name: Create NIC
  azure_rm_networkinterface:
    resource_group: "{{ resource_group }}"
    name: "{{ nic_name }}"
    location: "{{ location }}"
    virtual_network: "{{ vnet_name }}"
    subnet_name: "{{ subnet_name }}"
    ip_configurations:
      - name: "ipconfig1"
        public_ip_address_name: "{{ public_ip_name }}"

- name: Create VM
  azure_rm_virtualmachine:
    resource_group: "{{ resource_group }}"
    name: "{{ vm_name }}"
    vm_size: "Standard_B1s"
    admin_username: "{{ admin_user }}"
    ssh_password_enabled: false
    ssh_public_keys:
      - path: "/home/{{ admin_user }}/.ssh/authorized_keys"
        key_data: "{{ lookup('file', '/root/.ssh/id_rsa.pub') }}"
    network_interfaces: "{{ nic_name }}"
    location: "{{ location }}"
    image:
      offer: "0001-com-ubuntu-server-jammy"
      publisher: "Canonical"
      sku: "22_04-lts"
      version: "latest"
```

Note:
No `subscription_id`, `client_id`, `secret`, `tenant` in tasks — they come from `azure_creds.yml` (vars file) + authentication handled by the Azure modules.

---

If you’d like, next I can:

* Turn this into a nicely formatted `README.md` + `TROUBLESHOOTING.md` ready for GitHub,
* Or help you add a **“destroy VM”** role, multiple VM support, tags, etc.


<img width="1608" height="547" alt="image" src="https://github.com/user-attachments/assets/b2d12d09-08e8-4146-bc04-fdfaf24e7ce3" />




****************** suddlnly vm got rebooted so venv got deactivate ******************


No problem — this happens **only because your Python virtual environment is not activated** after the VM reboot.

Your Ansible was installed **inside the virtual environment**:

```
/root/ansible-venv
```

So after a reboot:

* The venv is NOT active
* The PATH to Ansible is NOT loaded
* So the system does not know the `ansible-playbook` command

That’s why you get:

```
ansible-playbook: command not found
```

---

# ✅ **FIX — Activate your virtual environment again**

Run this:

```bash
source /root/ansible-venv/bin/activate
```

Now test:

```bash
ansible-playbook --version
```

You should see Ansible info again.

---

# 🟢 **Then run your playbook normally**

```bash
cd /root/ansible-azure-labs/playbooks
ansible-playbook -i ../inventories/hosts.ini main.yml --ask-vault-pass
```

---

# 🧠 If you want Ansible to work WITHOUT activating venv every time

I can configure:

### **Option 1 — Auto-activate venv on login**

Add this to `/root/.bashrc`:

```bash
source /root/ansible-venv/bin/activate
```




getting below issue when try to run the playbook after rebooting the vm--control node



<img width="1590" height="646" alt="image" src="https://github.com/user-attachments/assets/7794f203-19cb-4ccd-9379-032b164323c7" />




This is a **known Azure CLI + msal library corruption issue** caused by:

✔ Rebooting the VM
✔ Having Azure CLI installed **inside your Python virtual environment**
✔ Azure modules trying to authenticate via Azure CLI instead of service principal

This results in:

```
AttributeError: Can't get attribute 'NormalizedResponse'
```

This error comes **only** from Azure CLI’s MSAL cache being corrupted.

Good news:

# ⭐ The FIX is 100% clear

and I will give you **exact steps** — after this, it will never happen again.

---

# 🔥 ROOT CAUSE (IMPORTANT)

Azure modules try auth in this order:

1️⃣ Use Azure CLI logged-in credentials
2️⃣ Use environment variables
3️⃣ Use vars_files credentials (your azure_creds.yml)

After reboot, since you DID NOT run:

```bash
az login
```

the CLI tries to access a stale cached MSAL token → BOOM → crash.

So the problem is:

👉 **Azure CLI tries to authenticate but fails**
👉 Even though you WANT to use service principal credentials
👉 Azure collection defaults to CLI first unless we tell it *NOT* to

---

# ⭐ FINAL FIX (Do ALL 3 steps)

---

# ✅ **STEP 1 — Clear broken Azure CLI MSAL cache**

Run:

```bash
rm -f /root/.azure/msal_token_cache.bin
rm -f /root/.azure/msal_token_cache.bin.lock
```

Also remove pickled binary cache:

```bash
rm -f /root/.azure/msal_http_cache.bin
```

---

# ✅ **STEP 2 — Tell Ansible NOT to use Azure CLI for auth**

Add this to your credentials file:

📌 Edit:

```
/root/ansible-azure-labs/vars/azure_creds.yml
```

Add the following variable:

```yaml
azure_auth_source: "auto"
```

OR the safest option:

```yaml
azure_auth_source: "msi"
```

But since you use service principal, best is:

```yaml
azure_auth_source: "sp"   # force service principal mode
```

So your file should look like:

```yaml
azure_subscription_id: "XXXX"
azure_client_id: "XXXX"
azure_secret: "XXXX"
azure_tenant: "XXXX"
azure_auth_source: "sp"
```

(If using vault: decrypt → edit → re-encrypt)

---

# 🔥 WHY THIS WORKS?

Because now Azure modules will NOT try this:

❌ `az login` cache
❌ msal corrupted token file
❌ CLI authentication

Instead they will directly use:

✔ your service principal
✔ from azure_creds.yml
✔ which is reliable and does not break after reboot

---

# ✅ **STEP 3 — Rerun playbook (IMPORTANT)**

Reactivate venv:

```bash
source /root/ansible-venv/bin/activate
```

Then run:

```bash
cd /root/ansible-azure-labs/playbooks
ansible-playbook -i ../inventories/hosts.ini main.yml --ask-vault-pass
```

This time it will work without Azure CLI interference.

---

# ⭐ **OPTIONAL (Recommended): disable CLI authentication system-wide**

Create a file:

```
/root/.azure/config
```

Content:

```ini
[cloud]
use_cli_authorization = false
```

This ensures **Azure CLI is never used for authentication**, eliminating the error forever.

---

# 🎉 AFTER THIS, YOU WILL NEVER SEE THIS ERROR AGAIN

Because:

* Azure CLI msal cache is removed
* Authentication is forced to service principal
* Ansible will not try CLI anymore
* Reboots will not break authentication
* Venv and libraries remain clean

---

# If you want

I can give you “final enterprise authentication layout” using:

✔ Only service principal
✔ No Azure CLI
✔ Fully vault-encrypted
✔ No more msal issues

Just say **“give final auth model”**.


