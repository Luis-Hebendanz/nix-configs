{ config, pkgs, ... }:

let

  patchelf-all = pkgs.writeScriptBin "patchelf-all" ''
    #!/usr/bin/env bash

    export PATH=$PATH:${pkgs.nix}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:${pkgs.patchelf}/bin

    DRV=$(nix-instantiate '<nixpkgs>' -A glibc --quiet --quiet --quiet)
    GLIB=$(nix show-derivation "$DRV" | jq -r ".[\"$DRV\"].env.out")
    INTERPRETER="$GLIB/lib/ld-linux-x86-64.so.2"

    echo "Setting to interpreter $INTERPRETER"

    for bin in "$@"; do
        file "$bin" | grep -i elf &>/dev/null
        if [ "$?" = "1"  ]; then
            echo -e "\e[31mERROR: File $bin is not an ELF file!\e[0m"
            exit 1
        fi
        echo "Patching $bin"
        patchelf --set-interpreter "$INTERPRETER" "$bin"
    done
    '';

  where = pkgs.writeScript "where.sh" ''
    #!/bin/sh

    export PATH=$PATH:${pkgs.nix}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin

    WH=$(which "$1" 2>/dev/null)
    if [ "$?" = "0" ]; then
        echo "$(readlink "$WH" | xargs dirname)/.."
    else
      DRV=$(nix-instantiate '<nixpkgs>' -A "$1" --quiet --quiet --quiet | sed 's/!dev$//g')

      if [ "$?" = "0" ]; then
        OUT=$(nix show-derivation "$DRV" | jq -r ".[\"$DRV\"].env.out")

        if [ -d "$OUT"  ]; then
            echo "$OUT"
        else
          echo "[-] Packet '$1' is not installed!"
          exit 1
        fi
      else
          echo "[-] Packet '$1' does not exist!"
          exit 1
      fi
   fi
'';

  wcd = pkgs.writeScript "wcd" ''
    #!/bin/sh

    export PATH=$PATH:${pkgs.nix}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin

    WH=$(which "$1")
    if [ "$?" = "0" ]; then
        cd "$(readlink "$WH" | xargs dirname)/.."
    else
      DRV=$(nix-instantiate '<nixpkgs>' -A "$1" --quiet --quiet --quiet | sed 's/!dev$//g')

      if [ "$?" = "0" ]; then
        OUT=$(nix show-derivation "$DRV" | jq -r ".[\"$DRV\"].env.out")

        if [ -d "$OUT"  ]; then
            cd "$OUT"
        else
          echo "[-] Packet '$1' is not installed!"
        fi
      else
          echo "[-] Packet '$1' does not exist!"
      fi
   fi
'';

  x11-spawn = pkgs.writeScriptBin "x11-spawn" ''
    #!/bin/sh

    export WAYLAND_DISPLAY=""
    export DISPLAY=:0
    "$@"
  '';


in {
  environment.shellAliases = {
    # Default aliases
    l = "ls -alh";
    ls = "ls --color=tty";
    ll = "ls -l";
    sudo = "sudo ";
    rsync = ''${pkgs.rsync}/bin/rsync -Pav -e "ssh -i ${config.mainUserHome}/.ssh/id_rsa -F ${config.mainUserHome}/.ssh/config"'';

    # Convenience aliases
    qrcode = "${pkgs.qrencode}/bin/qrencode -t UTF8";
    packtar = "tar czvf";
    untar = "tar xvfz";
    share-dir = "${pkgs.python3}/bin/python3 -m http.server 1234";
    t = "${pkgs.taskwarrior}/bin/task";
    video = "mpv --keep-open --really-quiet --pause";
    logout = "kill -9 -1";
    vim = "nvim";
    readelf = "readelf -W";

    # Nix aliases
    nix-rebuild = "nixos-rebuild --fast --show-trace --cores 7 switch --flake /etc/nixos --impure";
    nix-delete-old = "nix-collect-garbage -d 2d && journalctl --vacuum-time=2d";
    aliases = "${pkgs.less}/bin/less /etc/nixos/aliases.nix";
    nd = "nix develop";

    # Needed to overwrite the alias binary 'where' of which
    where = "${where}";
    wcd = "source ${wcd}";

    # Clipboard aliases
    c = "xclip -i"; # Copy to clipboard
    v = "xclip -o"; # Paste

    fromByte = "${pkgs.coreutils}/bin/numfmt --to=iec";
    toByte = "${pkgs.coreutils}/bin/numfmt --from=iec";
  };

  environment.systemPackages = with pkgs; [
    xclip
    x11-spawn
    patchelf-all
  ];
}
