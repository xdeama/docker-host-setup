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

        if [ $return_code -eq 0 ]; then
            echo "Playbook finished successfully."
        elif [ $return_code -eq 1 ]; then
            echo "Playbook failed."
            exit 1  # Exit the script if a playbook fails
        elif [ $return_code -eq 4 ]; then
            echo "Playbook failed with unreachable hosts."
            exit 2  # Exit the script with code 2 for unreachable hosts
        elif [ $return_code -eq 8 ]; then
            echo "Playbook failed with a break in play."
            exit 1  # Exit the script if a playbook fails
        else
            echo "Unknown error occurred with return code: $return_code"
            exit 255  # Exit with an unknown error code
        fi
    fi
done

echo "All playbooks have been executed"
