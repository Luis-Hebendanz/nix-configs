# NIXOS Complete Installation Guide

## Getting Started
* Download an iso from [----HERE----](https://nixos.org/nixos/download.html)
* Deactivate secure boot in your bios
* Boot from your ISO
* Now change your keyboard layout to whatever yo need:
```bash
$ loadkeys de
```
To find a list of possible keymaps execute:
```bash
$ find $(nix-build '<nixpkgs>' --no-out-link -A kbd)/share/keymaps
```

## Install with encrypted LVM partition
### Why you should use Grub?
Grub supports both Bios and Uefi mode, also it's much more themable
### Why LVM?
LVM enables you to resize the partition if you want to install a bigger or smaller drive later on.


**IMPORTANT**: Your disk needs to have a DOS partition table for Grub to install properly.
To make this happen use 'parted' and execute the following:
```
$ parted /dev/yourLinuxFilesystem

(parted) mktable msdos
(parted) q
```
You now have successfully created a DOS parition table on your drive. If you go into cfdisk check at the top if the 'Label' field indicates 'msdos'.

It is a good idea to create the SWAP parition as big as your installed RAM.
This enables the feature to [hibernate](https://en.wikipedia.org/wiki/Hibernation_(computing)) your Linux without running into problems.
Now create your partitions with cfdisk:
```
$ cfdisk
--> Create a 1GB partition of type 'Linux'
--> Create a 1GB partition of type 'EFI'
--> Create a X-GB partition of type 'SWAP'
--> Create a parition that fills out the rest and is of type 'Linux Filesystem'
--> Write to disk and exit
```

Example partition setup:
* /dev/sdb1 --> Bios parition
* /dev/sdb2 --> Grub partition
* /dev/sdb3 --> Swap partition
* /dev/sdb4 --> Linux partition

Now we create the lvm volume:
```bash
$ vgcreate vg0 /dev/sdb4 # Create LVM group vg0
$ lvcreate -l 100%FREE vg0 -n root # Create LVM container with all available space
$ cryptsetup luksFormat /dev/vg0/root # Encrypt LVM container
$ cryptsetup luksOpen /dev/vg0/root nixosCrypt # Mount encrypted lvm container
$ mkfs.ext4 /dev/mapper/nixosCrypt -L nixos # Write an ext4 filesystem into encrypted lvm container
$ mount /dev/mapper/nixosCrypt /mnt # Mount it
$ mkfs.fat -F 32 -n boot /dev/sdb2 # 'EFI' partition type
$ mkswap -L swap /dev/sdb3 # 'SWAP'  partition type
$ swapon /dev/sdb3 # Enable swap parition
$ mkdir /mnt/boot
$ mount /dev/sdb2 /mnt/boot # Mount grub parition to boot directory
$ nixos-generate-config --root /mnt
```

Your generated configurations now are at /mnt/etc/nixos.
Edit the configuration.nix and uncomment the following lines:
```nix
console.keyMap = "de";
console.font = "Monospace";
i18n.defaultLocale = "en_US.UTF-8";
```
Change the 'consoleKeyMap' option to the keymap you set at the beginning. This is important or your password may be differently typed at bootup.


Now add the following lines to the configuration.nix:
```nix
boot.loader.grub.enable = true;
boot.loader.grub.version = 2;
boot.loader.grub.device = "yourDeviceWithoutNumber" (Example: '/dev/sdb')
```

To enable LVM container detection in initram you need to edit `hardware-configuration.nix` and add `preLVM = false;`:
```nix
  boot.initrd.luks.devices."nixos-crypt" = {
	device = "<some device path>";
	preLVM = false; # Needs to be added
  };
```


Make sure to have internet access. If you don't have a LAN connection
configure WPA supplicant so we can use WIFI:
```bash
$ cat > /etc/wpa_supplicant.conf
network={
  ssid="****"
  psk="****"
}
$ systemctl start wpa_supplicant
```

Before copying your nixos configs over you want to be sure to be able to boot.
So install this minimal nix config with:

```bash
$ nixos-install
$ reboot
```

# Trouble Shooting

If you boot into the nixos menu, great! If not reboot into your nix-usb stick and do the following:
```bash
$ loadkeys de # Or whatever language your keyboard is
$ cryptsetup luksOpen /dev/vg0/root nixosCrypt
$ mount /dev/mapper/nixosCrypt /mnt
$ mount /dev/sdb2 /mnt/boot
```

Now you can edit the configurations at /mnt/etc/nixos. After editing them do:
```
$ nixos-install
```
Check for any error messages!! If no errors occurred execute:

```
$ reboot
```
And hope to boot into your nixos.

## Error nixos-unstable channel not found
If this error occurs when you do a `nixos-install` then
execute instead:
```
$ nixos-install -I nixos-unstable=channel:nixos-unstable
```
