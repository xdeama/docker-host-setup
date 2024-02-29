#!/bin/bash

if [ -z "$VAULT_PASSWORD" ]; then
    echo "VAULT_PASSWORD environment variable is not set. Set Ansible Vault password before running the playbooks."
    exit 1
fi

playbooks_dir="/ansible/playbooks"
logs_dir="./logs"

if [ ! -d "$playbooks_dir" ]; then
    echo "Playbooks directory '$playbooks_dir' does not exist."
    exit 1
fi

if [ ! -d "$logs_dir" ]; then
    mkdir -p "$logs_dir"
fi

for playbook in "$playbooks_dir"/[0-9][0-9]*.yml; do
    if [ -f "$playbook" ]; then
        playbook_name=$(basename "$playbook" .yml)
        timestamp=$(date +"%Y%m%d%H%M%S")
        log_file="$logs_dir/$playbook_name-$timestamp.log"

        echo "Running playbook: $playbook"
        
        ansible-playbook --vault-password-file /ansible/.vault_pass.py -i /ansible/inventory.yml "$playbook" | tee "$log_file"
        return_code=$?

        echo "return_code=$return_code"

        grep -q "unreachable=0" "$log_file"
        unreachable=$?

        grep -q "failed=0" "$log_file"
        failed=$?

        if [ $unreachable -ne 0 ] || [ $failed -ne 0 ]; then
            echo "Playbook finished, rescued, ignored or skipped successfully."
        else
            echo "Playbook failed or host unreachable."
            exit 1
        fi
    fi
done

echo "All playbooks have been executed"
