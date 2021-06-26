
{config, lib, pkgs, stdenv, ... }:

{

  # Use swap with random encryption on every reboot
  swapDevices = [
    {
      device = "/dev/nvme0n1p3";
      randomEncryption = {
        enable = true;
      };
    }
  ];

  # Enable grub
  boot.loader.grub.version = 2;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";

  # Tried to get initrd working with hdmi output
  boot.initrd.availableKernelModules = [ "xhci-hcd" "xhci-pci"  ];

  # Enable closed source firmware
  hardware.enableRedistributableFirmware = true;

  # Disable IPv6
  #boot.kernelParams = ["ipv6.disable=1"];

  # Enable nested virtualisation
  boot.extraModprobeConfig = "options kvm_amd nested=1";

  # latest
  boot.kernelPackages = pkgs.linuxPackages_5_12;

  # Enable vulkan support
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocm-opencl-icd
  ];

  ####################
  #                  #
  #     GRUB THEME   #
  #                  #
  ####################
  boot.loader.grub.extraConfig = ''
    set theme=($drive1)//themes/fallout-grub-theme/theme.txt
  '';

 boot.loader.grub.splashImage = ./resources/fallout-grub-theme/background.png;

 #boot.loader.grub.extraPrepareConfig = ''
 # # extra prepare config
 # insmod all_video
 # insmod usb
 # insmod usb_keyboard
 # insmod uhci
 # insmod pci
 #'';

  system.activationScripts.copyGrubTheme = ''
    mkdir -p /boot/themes
    cp -R ${./resources/fallout-grub-theme} /boot/themes/fallout-grub-theme
  '';

}
