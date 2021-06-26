{ config, pkgs, lib, ... }:

{

  programs.wireshark.enable = true;
  programs.bcc.enable = true;

  environment.systemPackages =
  
  # My modified nixpkgs set found under  
  (with pkgs.luis.pkgs; [ 
    python38Packages.dragonfly2 
  ])
  # Import packages from NUR repository
  # Package search: https://nur.nix-community.org/repos/mic92/
  ++ (with pkgs.nur.repos.mic92; [
    hello-nur
  ])
  
  ++ (with pkgs; [
    # bash basics
    man-pages
    posix_man_pages # Use the posix standarized manpages with `man p <keyword>`
    file
    wget
    git
    curl
    tree # display files as tree
    pwgen # generates passwords
    entr # Runs command if files changed
    jq # Json parsing in shell
    cifs-utils # Samba mount
    sshfs # Mount a filesystem through ssh
    neovim
    bat # Cat with syntax highlighting
    calc # Simple calculator
    fzf # fuzzy finder
    ag # grep replacement with sane cli interface
    fd # find replacement
    tmux
    unzip
    git-lfs

    # Nixos specific
    nixos-generators # Generate nixos images
    patchelf
    niv # NixOS project creator
    nix-prefetch # Sha256sum a link for nixos
    nix-index # apt-file equivalent

    gnome.gnome-tweak-tool
    binutils # Binary inspection
    radare2 # Binary reversing
    ghidra-bin
    lmms # DAW 
    powertop # A power saving tool
    dos2unix # Convert win newlines to unix ones
    rr # reverse execute and debug elfs
    libreoffice # Opening docs
    gimp # Editing pictures
    cargo-watch # Rust on demand recompile
    taskwarrior # Task list
    pavucontrol # audio device switcher per programm!
    sqlite-interactive # Sqlite cli
    tmate # remote shared terminal
    linuxPackages.perf # profiling utilities
    tracy # Best Gui for profiling
    docker-compose
    mitmproxy # Great to debug https traffic
    picocom # good uart reader
    mumble # Voice chat
    remmina # Remote Desktop application
    gnupg # Email encryption
    okular # Pdf reader with bookmarks
    signal-desktop
    kaldi
    

    # Media
    ffmpeg-full # Convert video formats

    # hardware inspections
    pciutils
    smartmontools # ssd health check

    # Network debugging
    nmap # Network discovery
    traceroute
    tcpdump
    wireshark
    netcat-gnu # nc tool
    tunctl # to create tap devices
    bridge-utils # to create bridges
    ldns  # DNS tool 'drill'
  ]);
}
