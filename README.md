# Automated Installation for Linux Docker Host
Install and configure Docker and Grafana Agent

Prerequesits:
- add hosts to inventory.yml
- add usernames and config to vars.yml
- add passwords and API keys to vault.yml (encrypt with ansible-vault, set your own password)

# Create Ansible Vault
ansible-vault create ./ansible/vault.yml
Set your personal password

Example content:
```yaml
---
vault_ansible_user: username
vault_ansible_become_pass: password
vault_grafana_cloud_api_key: api-key
```

# Check Grafana Agent Version
https://github.com/grafana/agent/releases/
using the official ansible galaxy playbooks: 
https://grafana.com/docs/grafana-cloud/developer-resources/infrastructure-as-code/ansible/ansible-grafana-agent-linux/


# Run Ansible Controller Container
Start a ubuntu container with ansible:
```bash
docker-compose up -d
```

SSH keys are in folder ssh-keys. If the folder does not contain id_rsa, it'll generate a new ssh key.

Copy the public key to all target hosts. Example: from the container bash use 
```bash
ssh-copy-id username@host
```

Connect to container:
```bash
docker exec -it ansible-controller bash
```

Run Ansible Playbooks against all configured hosts:
```bash
export VAULT_PASSWORD=<your-vault-password>
ansible-playbook --vault-password-file /ansible/.vault_pass.py -i /ansible/inventory.yml /ansible/playbooks/docker-install.yml
ansible-playbook --vault-password-file /ansible/.vault_pass.py -i /ansible/inventory.yml /ansible/playbooks/grafana-agent-install.yml 
```

# Docker build
```bash
docker compose build 
```
OR
```bash
docker build -t xdeama/ansible-controllerv:v0.1 .
```
