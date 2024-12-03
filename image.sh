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

# Check if arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bootimage_zip_path>"
    exit 1
fi

# Check if the provided argument is a valid file
if [ ! -f "$1" ]; then
    echo "Error: '$1' does not exist."
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

echo "Directory 'boot' exists. Removing its contents..."
rm -rf $MOUNT_PATH/boot/*
# Take ownership of the root directory and it's files
sudo chown -R $USER:$USER $MOUNT_PATH/root
echo "Directory 'root' exists. Removing its contents..."
rm -rf $MOUNT_PATH/root/*

copy_files() {
    local bootimage_zip="$1"

    # Copy specific files to boot folder
    for file in BOOT.BIN boot.scr image.ub; do
        if unzip -j "$bootimage_zip" "boot/$file" -d $MOUNT_PATH/boot/ > /dev/null 2>&1; then
            echo "Copied $file to $MOUNT_PATH/boot/"
        else
            echo "Error: $file not found in $bootimage_zip"
        fi
    done

    # Copy rootfs.tar.gz to root folder and extract
    if unzip -j "$bootimage_zip" "root/rootfs.tar.gz" -d $MOUNT_PATH/root/ > /dev/null 2>&1; then
        echo "Copied rootfs.tar.gz to $MOUNT_PATH/root/"

        # Extract the tar.gz in the root folder
        tar -xzf $MOUNT_PATH/root/rootfs.tar.gz -C $MOUNT_PATH/root/
        sync
        echo "Extracted rootfs.tar.gz to ./root/"
        rm -f $MOUNT_PATH/root/rootfs.tar.gz
    else
        echo "Error: rootfs.tar.gz not found in $bootimage_zip"
        exit 1
    fi
}

disk_image() {
    local bootimage_zip="$1"

    # Use df to find the device associated with the mount point
    mount_point="$MOUNT_PATH/root"
    device=$(df | grep "$mount_point" | awk '{print $1}')

    # Check if a device was found
    if [ -z "$device" ]; then
      echo "No device found for mount point $mount_point"
      exit 1
    fi

    # Remove the partition number (e.g., /dev/sdg1 -> /dev/sdg)
    root_device=$(echo "$device" | sed 's/[0-9]*$//')

    # Work out the SD card image path
    imagepath="${bootimage_zip%.zip}.img"
    zippath="${bootimage_zip%.zip}_img.zip"

    echo "Writing image to $imagepath"

    # Make disk image
    sudo dd if=$root_device of=$imagepath

    echo "Compressing disk image to $zippath"

    # Compress the disk image
    zip -j "$zippath" "$imagepath"

    # Check if the zip command was successful
    if [[ $? -eq 0 ]]; then
        echo "Successfully compressed $imagepath to $zippath"
        # Delete the original file
        rm -f "$imagepath"
        echo "Original file $imagepath deleted."
    else
        echo "Error: Failed to compress $imagepath"
    fi
}

# Copy files to SD card
copy_files "$1"

if [[ $? -ne 0 ]]; then
    exit 1
fi

# Make image of SD card
disk_image "$1"

echo "Complete"
