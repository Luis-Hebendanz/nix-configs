{ config, pkgs, lib, ... }:

{
services.xserver.enable = true;
services.xserver.layout = "de";
services.xserver.displayManager.gdm = {
  autoLogin.delay = 1;
  enable = true;
  wayland = false;
};

services.xserver.desktopManager.gnome = {
  enable = true;
};

services.xserver.displayManager.autoLogin = {
  enable = true;
  user = config.mainUser;
};

# Needed for tray icon support. Enable in 'extension' gnome app
environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
}
