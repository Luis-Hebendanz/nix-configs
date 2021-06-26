{ config, pkgs, lib, ... }:
{
  # Hostname
  networking.hostName = "qubasa-desktop";

  # Needed for same origin policy in web dev & debugging
  networking.extraHosts = "127.0.0.1 localhost dev.localhost";

  # Enable networkmanager
  networking.networkmanager.enable = true;

  # Set own dns server
  networking.networkmanager = {
    dns = "systemd-resolved";
  };
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=95.216.223.74#qube.email 2a01:4f9:c010:51cd::2#qube.email
    '';
  };
  networking.networkmanager.insertNameservers = [ "95.216.223.74" "2a01:4f9:c010:51cd::2" ];

}
