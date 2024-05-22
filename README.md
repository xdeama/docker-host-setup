# Automated Installation for Ubuntu Linux Docker Host
Automate intalling and configuring Docker and Grafana Agent on a remote Ubuntu server. Configure Grafana Agent to export logs and metrics to Grafana Cloud.

**This project is a showcase for setting up development environments and comes without any warranty. Use for production is not supported. Thorough testing and hardening for production usage is YOUR responsibility.**

## What it this project is meant to do
1. start a ubuntu linux docker container with ansible preinstalled
2. generyte an SSH key on that container and expose it in folder ./ssh-keys OR load the pre-existing SSH key "id_rsa" from ./ssh-keys to /root/.ssh by docker volume mount
3. mount folder ./ansible to the same container
4. tty or ssh into the container and execute ansible playbooks against remote hosts
5. Playbooks are installing Docker, Git and Grafana Agent
6. Playbooks are checking out a Git Repository with your personal docker-compose configuration and executes docker compose up
7. Playbook execution logs are saved to ./logs

Playbook execution is currently manual, since container and host ssh config are separated. The Container is in the long run meant to be executed by a CI/CD pipeline and acquire all credentials from a Ansible Vault or comparable secret store.

Scripts we're created on a M1 Mac, configured to be both runnable on ARM and AMD, but not tested. Target host may also be ARM or AMD.

Target hosts are expected to be Ubuntu linux server of Ubuntu 18.04.6 LTS or later. Different distributions will require adjustments to package installation commands and required dependencies.

## Prerequesits on your local development machine:
- add your hosts to inventory.yml
- add your usernames and config to ./group_vars/<group>/vars.yml
- add passwords and Grafana Cloud API keys to ./group_vars/<group>/vault.yml (encrypt with ansible-vault, set your own password)
- your vault password is required as an environment variable on the Ansible Runner Linux Container (export VAULT_PASSWORD=<your-vault-password>)
- configure and test SSH connection to your target hosts before running Ansible
- generate a SSH key by running the linux ansible container configured in docker-compose.yml or reuse an existing key by copying it to ./ssh-keys
- secure your ./ssh-keys folder

## ToDo's
- completely automate Playbook execution and replace manual tty/ssh connection, reading secrets from a vault
- install Docker rootless on remote hosts
- install Docker Grafana Plugin
- single resource for all configuration parameters spread over group_vars and playbooks
- store ssh-keys in a vault

## Known Issues
- linux ansible-playbook application is behaving weird and returning exit code 0 on success and fail. The automation script ./ansible/run-all.sh can't determine if a script failed or not
- private SSH key in ./ssh-keys must be secured manually on your development maschine

## Create Ansible Vault
Your SSH username and Grafana Cloud credentials
ansible-vault create ./ansible/<group_name>/vault.yml

Set your personal password

Example content:
```yaml
---
vault_ansible_become_pass: password
vault_grafana_cloud_api_key: api-key
```

## Check Grafana Agent Version
Configuring a Grafana Agent version that's not available at https://github.com/grafana/agent/releases/ or downlaod will fail the Grafana Playbook with a 404 error.

Grafana Agent is installed using the official ansible galaxy playbooks: 
https://grafana.com/docs/grafana-cloud/developer-resources/infrastructure-as-code/ansible/ansible-grafana-agent-linux/


## Run Ansible Controller Container
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
ansible-playbook --vault-password-file /ansible/.vault_pass.py -i /ansible/inventory.yml /ansible/playbooks/ubuntu-docker-install.yml
ansible-playbook --vault-password-file /ansible/.vault_pass.py -i /ansible/inventory.yml /ansible/playbooks/grafana-agent-install.yml 
```

## Docker build
```bash
docker compose build 
```
OR
```bash
docker build -t xdeama/ansible-controllerv:v0.2 .
```

## Check Grafana-Agent service on target host
```bash
sudo systemctl status grafana-agent.service
```

or check the logs since last boot:
```bash
sudo journalctl -u grafana-agent.service -b
```
