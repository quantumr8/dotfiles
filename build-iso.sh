#!/bin/bash

# Set the path to the archiso configuration
config_dir="releng"

# Ensure the configuration directory exists
if [ ! -d "$config_dir" ]; then
    echo "ERROR: Configuration directory does not exist: $config_dir"
    exit 1
fi

# Build the ISO
sudo mkarchiso -v -w /tmp/archiso-tmp -o out $config_dir