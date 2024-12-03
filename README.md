# Packager

These scripts are used to simplify the process of copying boot files from a PetaLinux project
into an SD card, and creating a disk image of that SD card. We use these scripts internally
to simplify our dev processes and the sharing of reference designs.

The SD card must have a `boot` and a `root` partition, and they must be mounted to path
`$MOUNT_PATH/boot` and `$MOUNT_PATH/root`. The `$MOUNT_PATH` variable is defined in a file
called `config.txt` that is located in the root of this repository, alongside the scripts.
It should contain one line specifying the mount path of the SD card, eg:

```
MOUNT_PATH="/media/user"
```

The `config.txt` file is not tracked by version control.

## delete

This script deletes all files in the `boot` and `root` partitions.

## copy

This script copies the relevant boot files from the `images/linux` directory of a PetaLinux project
into the `boot` and `root` partitions of the SD card.

Boot partition:
* BOOT.BIN
* boot.scr
* image.ub

Root partition:
* rootfs.tar.gz is extracted into the root partition

To run the script, you must pass a single argument: the complete path of the `images/linux`
directory.

## image

This script produces a disk image given the boot files of a PetaLinux project. This script takes a 
single argument providing the path to the compressed boot files of a PetaLinux project. To produce 
the disk image it does the following:

1. Deletes all files in the `boot` and `root` partitions of the SD card
2. Extracts the boot files and copies them to the `boot` and `root` partitions (just as 
   the copy script does)
3. Uses `dd` to create a disk image (`.img`) of the SD card
4. Compresses the disk image to a `.zip` file in the same location and with the same filename as the 
   input `.zip` file apart for the added postfix `_img`.

