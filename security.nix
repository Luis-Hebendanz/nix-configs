{ pkgs, config, lib, ... }:
{
  # Set sudo timeout to 30 mins
  security.sudo = {
    enable = true;
    extraConfig = "Defaults        env_reset,timestamp_timeout=30";
    wheelNeedsPassword = false;
  };

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    dates = "0/3:00:00"; # Check every 3 hours for updates
    flake = "/etc/nixos";
  };
}
