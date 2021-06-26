# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, lib, ... }:

{
imports = [
  ./hardware-configuration.nix
  ./hardware-specific.nix
  ./security.nix
  ./firefox.nix
  ./packages.nix
  ./options.nix
  ./networking.nix
  ./display.nix
  ./editor.nix
  ./htop.nix
  ./virtualisation.nix
  ./pass.nix
  ./zsh.nix
  ./terminal.nix
  ./own-pkgs.nix
  ./aliases.nix
  ./restic.nix
];

nixpkgs.config.allowUnfree = true;

# Options
mainUser = "lhebendanz";
mainUserHome = ''${config.users.extraUsers.${config.mainUser}.home}'';
secrets = "/root/secrets";

# Define a user account. Don't forget to set a password with ‘passwd’.
users.extraUsers.${config.mainUser} = rec {
  name = config.mainUser;
  initialPassword = name;
  isNormalUser = true;
  uid = 1000;
  extraGroups = ["adbuser" "wheel" "networkmanager" "video" "audio" "input" "wireshark" "dialout" "disk"];
};

# Language settings
console.keyMap = "de";
console.font = "Monospace";
i18n.defaultLocale = "en_US.UTF-8";
time.timeZone = "Europe/Berlin";

# Printing support
services.printing.enable = true;
services.printing.drivers = [
  pkgs.gutenprint
  pkgs.gutenprintBin
];

hardware.pulseaudio.enable = true;

# Android ADB
programs.adb.enable = true;
services.udev.packages = [
  pkgs.android-udev-rules
];

# nix daemon optimizations
# fetchtarball ttl set to one week
# enabled flakes
nix = {
  package = pkgs.nixUnstable;
  autoOptimiseStore = true;
  gc.automatic = true;
  gc.dates = "weekly";
  gc.options = "--delete-older-than 30d";
  extraOptions = ''
      builders-use-substitutes = true
      keep-outputs = true
      keep-derivations = true
      tarball-ttl = 604800
      experimental-features = nix-command flakes
    '';
};

# Exfat support
#boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
boot.supportedFilesystems = [ "ntfs" ];

# This value determines the NixOS release with which your system is to be
# compatible, in order to avoid breaking some software such as database
# servers. You should change this only after NixOS release notes say you
# should.
system.stateVersion = "21.05"; # Did you read the comment?

}
