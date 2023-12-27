#!/bin/bash

# Set the path to the archiso configuration
config_dir="/__w/dotfiles/dotfiles/releng"

# Ensure the configuration directory exists
if [ ! -d "$config_dir" ]; then
    echo "ERROR: Configuration directory does not exist: $config_dir"
    exit 1
fi

# Build the ISO
mkarchiso -v -w /tmp/archiso-tmp -o out $config_dir