{ pkgs, ... }:

let
   extensions = (with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
    matklad.rust-analyzer
    ms-python.python
    ms-azuretools.vscode-docker
    redhat.java
    yzhang.markdown-all-in-one
#    ms-vscode-remote.remote-ssh
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
#    {
#      name = "remote-ssh-edit";
#      publisher = "ms-vscode-remote";
#      version = "0.65.6";
#      sha256 = "sha256-W+XJgcMjky9fFLEgnk3Jef4HvhwfBonhVoVjCGYJtIo=";
#    } 
    {
      name = "vscode-clangd";
      publisher = "llvm-vs-code-extensions";
      version = "0.1.11";
      sha256 = "sha256-vgynXP+diy17QrN/RfhYTcQl3KO/7myApu7ULNTo9tA=";
    }
    {
      name = "vscode-rusty-onedark";
      publisher = "jeraldson";
      version = "1.0.3";
      sha256 = "sha256-BuARy+Va+BtF8UqceNDRWHhwaV/PtRePKmd0pJn1DZg=";
    }
  ];
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscode;
    vscodeExtensions = extensions;
  }; 


in {
 environment.variables = {
    EDITOR = ["code"];
    VISUAL = ["code"];
  };

  environment.systemPackages = with pkgs; [
    vscode-with-extensions
    rust-analyzer
    python39Packages.pylint
  ];
}
