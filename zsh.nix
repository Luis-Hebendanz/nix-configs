{config, lib, pkgs, ...}:

let


  python_version_long = pkgs.python3.version;
  python_version_dotless = lib.lists.foldr (a: b: a +b) "" (lib.lists.take 2 (lib.strings.splitString "." pkgs.python3.version ));
  python_version =  lib.strings.concatStrings ((lib.lists.zipListsWith (a: b: a +b) (lib.lists.take 2 (lib.strings.splitString "." pkgs.python3.version ))) ["." ""]);
  nix_python_version = "python${python_version_dotless}Packages";

  # TODO: Copy files to /etc with nixos function and then symlink von userspace to it
  # TODO: Use Mic92 zsh that he forked because git integration runs in another process
  # TODO: Root needs direnv_rc too
  direnv_rc = pkgs.writeText "direnvrc" ''

    export_function() {
      local name=$1
      local alias_dir=$PWD/.direnv/aliases
      mkdir -p "$alias_dir"
      PATH_add "$alias_dir"
      local target="$alias_dir/$name"
      if declare -f "$name" >/dev/null; then
        echo "#!$SHELL" > "$target"
        declare -f "$name" >> "$target" 2>/dev/null
        # Notice that we add shell variables to the function trigger.
        echo "$name \$*" >> "$target"
        chmod +x "$target"
      fi
    }

    use_flake() {
        watch_file flake.nix
        watch_file flake.lock
        watch_file shell.nix
        eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
    }

    realpath() {
        [[ $1 = /* ]] && echo "$1" || echo "$PWD/''${1#./}"
    }
    layout_python-venv() {
        local python=''${1:-python3}
        [[ $# -gt 0 ]] && shift
        unset PYTHONHOME
        if [[ -n $VIRTUAL_ENV ]]; then
            VIRTUAL_ENV=$(realpath "''${VIRTUAL_ENV}")
        else
            local python_version
            python_version=$("$python" -c "import platform; print(platform.python_version())")
            if [[ -z $python_version ]]; then
                log_error "Could not detect Python version"
                return 1
            fi
            VIRTUAL_ENV=$PWD/.direnv/python-venv-$python_version
        fi
        export VIRTUAL_ENV
        if [[ ! -d $VIRTUAL_ENV ]]; then
            log_status "no venv found; creating $VIRTUAL_ENV"
            "$python" -m venv "$VIRTUAL_ENV"
        fi
        PATH_add "$VIRTUAL_ENV/bin"
    }
    '';

 nixify = pkgs.writers.writeDashBin "nixify" ''
  set -efuC

  # Generate .envrc
  if [ ! -e ./.envrc ]; then
    cat > .envrc <<'EOF'
    use flake
    layout python-venv
    export PYTHONPATH=".:$PWD/.direnv/python-venv-${python_version_long}/lib/${python_version}/site-packages:$PYTHONPATH"
EOF
    direnv allow
  fi

  # Generate shell.nix
  if [ ! -e shell.nix ]; then
    cat > shell.nix <<'EOF'
  { pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      python3
      (with ${nix_python_version}; [
        pip
        ipython
      ])

    ];
    shellHook = ''''
    export HISTFILE=''$PWD/.history
    # To be able to execute precompiled dynamic binaries
    export NIX_LD=$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker);
    '''';

    # Dynamic libraries your precompiled executable needs
    # Find more with ldd <executable>
    NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
      stdenv.cc.cc
      glib
      zlib
      gtk3
      dbus
      fontconfig
    ]);
  }
EOF
    fi

# Generate flake.nix
if [ ! -e flake.nix ]; then
    cat > flake.nix <<'EOF'
    {
        description = "my project description";
        nixConfig.bash-prompt = "\[nix-develop\]$ ";
        inputs.flake-utils.url = "github:numtide/flake-utils";
        # My fork of nixpkgs with custom packages
        inputs.luispkgs.url = "github:Luis-Hebendanz/nixpkgs/luispkgs";

        outputs = { self, nixpkgs, flake-utils, luispkgs }:
        flake-utils.lib.eachDefaultSystem
        (system:
        let 
            pkgs = import nixpkgs {
		          inherit system;
		          config = { allowUnfree = true; };
	          };

            luis = import luispkgs {
		          inherit system;
		          config = { allowUnfree = true; };
	          };
        in
            {
                devShell = import ./shell.nix { inherit pkgs; inherit luis; };
            }
        );
    }
EOF
  fi

  if [ "$(grep -qxsF ".envrc" .gitignore)" != 0 ]; then
    echo ".envrc" >> .gitignore
  fi
  if [ "$(grep -qxsF ".direnv" .gitignore)" != 0 ]; then
    echo ".direnv" >> .gitignore
  fi

  if [ "$(grep -qxsF ".history" .gitignore)" != 0 ]; then
    echo ".history" >> .gitignore
  fi
  if [ "$(grep -qxsF ".__pycache__" .gitignore)" != 0 ]; then
    echo ".__pycache__" >> .gitignore
  fi
  git init
  git add .gitignore
  git add flake.nix
  git add shell.nix
  git commit -m "Added .gitignore"
'';

in {

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;

    syntaxHighlighting.enable = true;

    interactiveShellInit = ''
      eval "$(direnv hook zsh)"
    '';

    ohMyZsh = {
      enable = true;
      theme = "gnzh";
      plugins = [
        "git"
      ];
  };

};

environment.systemPackages = with pkgs; [
  direnv
  nixify
  python3
];

system.activationScripts.copyZshConfig = ''
    touch ${config.mainUserHome}/.zshrc
    ln -f -s ${direnv_rc} ${config.mainUserHome}/.direnvrc
    chown -h ${config.mainUser}: ${config.mainUserHome}/.direnvrc

    ln -f -s ${direnv_rc} /root/.direnvrc
    chown -h root:root /root/.direnvrc
'';


}
