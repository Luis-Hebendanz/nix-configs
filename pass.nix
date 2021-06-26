{ config, pkgs, ... }:
{
  programs.gnupg.agent = {
    pinentryFlavor = "gnome3";
    enable = true;
  };

  environment.systemPackages = with pkgs; [
      qtpass
      pinentry-gnome
      pinentry
     (pass.withExtensions (ext: [
          ext.pass-otp
        ]))
    ];
}
