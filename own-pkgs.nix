{config, lib, pkgs, stdenv, ... }:

let

  # Allow callPackage to fill in the pkgs argument
  callPackage = pkgs.lib.callPackageWith (pkgs);

  rmount = callPackage ./own-pkgs/rmount {  };
  nixos-generators = callPackage ./own-pkgs/nixos-generators {};
  myWlroots = with pkgs.xorg; callPackage ./own-pkgs/wlroots {
      xcbutilwm=xcbutilwm;
      libX11=libX11;
      xcbutilimage=xcbutilimage;
      xcbutilerrors=xcbutilerrors;
      };
  mySway = callPackage ./own-pkgs/sway { wlroots=myWlroots;  };


in {
  # Set sway to unstable package
  nixpkgs.config.packageOverrides = super: {
          sway = mySway;
 };

  environment.systemPackages = with pkgs; [
    rmount
    nixos-generators
  ];
}
