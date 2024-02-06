#!/bin/bash

# Path to the SSH key in the /keys folder
KEY_FILE="/root/.ssh/id_rsa"

# Check if the key file exists
if [ ! -f "$KEY_FILE" ]; then
    ssh-keygen -q -t rsa -N '' -f $KEY_FILE
fi

/bin/bash
