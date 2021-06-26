{config, lib, pkgs, stdenv,buildPythonPackage, fetchPypi, ... }:

let

  # Allow callPackage to fill in the pkgs argument
  callPackage = pkgs.lib.callPackageWith (pkgs);

  talon = callPackage ./ownpkgs/talon {};
in {


  services.udev.packages = [ talon ];
  environment.systemPackages = [
    talon
  ];
}
