# Packager

These scripts are used to simplify the process of copying boot files from a PetaLinux project
into an SD card, and creating a disk image of that SD card.

The SD card must have a `boot` and a `root` partition, and they must be mounted to path
`$MOUNT_PATH/boot` and `$MOUNT_PATH/root`. The `$MOUNT_PATH` variable is defined in a file
called `config.txt` that is located in the root of this repository, alongside the scripts.
It should contain one line specifying the mount path of the SD card, eg:

```
MOUNT_PATH="/media/user"
```

The `config.txt` file is not tracked by version control.
