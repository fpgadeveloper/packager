#!/bin/bash

# Source the configuration file
CONFIG_FILE="./config.txt"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Error: Configuration file not found at $CONFIG_FILE"
  exit 1
fi

# Use the variables
echo "Using MOUNT_PATH: $MOUNT_PATH"

# Check if "boot" directory exists
if [ -d "$MOUNT_PATH/boot" ]; then
    echo "Directory 'boot' exists. Removing its contents..."
    rm -rf $MOUNT_PATH/boot/*
fi

# Check if "root" directory exists
if [ -d "$MOUNT_PATH/root" ]; then
    echo "Directory 'root' exists. Removing its contents..."
    # Take ownership of the root directory and it's files
    sudo chown -R $USER:$USER $MOUNT_PATH/root
    rm -rf $MOUNT_PATH/root/*
fi

echo "Done!"
