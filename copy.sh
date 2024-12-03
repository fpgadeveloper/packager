#!/bin/bash

# Opsero Electronic Design Inc.

# This script can be used to copy files from the images/linux directory of a PetaLinux project
# to an SD card. It copies BOOT.BIN, boot.scr and image.ub to the "boot" partition,
# and it extracts the rootfs.tar.gz contents to the "root" partition.

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

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_folder_path>"
    exit 1
fi

# Check if the provided argument is a valid directory
if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a valid directory."
    exit 1
fi

# Ensure boot1 and root1 folders exist
if [ ! -d "$MOUNT_PATH/boot/" ]; then
    echo "Error: $MOUNT_PATH/boot/ directory doesn't exist."
    exit 1
fi

if [ ! -d "$MOUNT_PATH/root/" ]; then
    echo "Error: $MOUNT_PATH/root/ directory doesn't exist."
    exit 1
fi

copy_files() {
    local source_folder="$1"

    # Copy specific files to boot folder
    for file in BOOT.BIN boot.scr image.ub; do
        if [ -f "$source_folder/$file" ]; then
            cp "$source_folder/$file" $MOUNT_PATH/boot/
            echo "Copied $file to $MOUNT_PATH/boot/"
        else
            echo "Error: $file not found in $source_folder"
        fi
    done

    # Copy rootfs.tar.gz to root folder and extract
    if [ -f "$source_folder/rootfs.tar.gz" ]; then
        cp "$source_folder/rootfs.tar.gz" $MOUNT_PATH/root/
        echo "Copied rootfs.tar.gz to $MOUNT_PATH/root/"

        # Extract the tar.gz in the root folder
        tar -xzf $MOUNT_PATH/root/rootfs.tar.gz -C $MOUNT_PATH/root/
        sync
        echo "Extracted rootfs.tar.gz to $MOUNT_PATH/root/"
        rm -f $MOUNT_PATH/root/rootfs.tar.gz
        sync
    else
        echo "Error: rootfs.tar.gz not found in $source_folder"
    fi
}

# Take ownership of the root directory and it's files
sudo chown -R $USER:$USER $MOUNT_PATH/root

# Copy files to boot and root partitions
copy_files "$1"
