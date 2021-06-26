{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/21.05";
  inputs.nix-ld.url = "github:Mic92/nix-ld";
  inputs.nur.url = github:nix-community/NUR;
  # this line assume that you also have nixpkgs as an input
  inputs.nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  inputs.luispkgs.url = "github:Luis-Hebendanz/nixpkgs/luispkgs";

  outputs = { self, nix-ld, nixpkgs, nur, luispkgs }: {
     # replace 'qubasa-desktop' with your hostname here.
     nixosConfigurations.qubasa-desktop = nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       modules = [ 
        ./configuration.nix 
        nix-ld.nixosModules.nix-ld
        { nixpkgs.overlays = [ nur.overlay ]; }

          ({...}: {
            nixpkgs.config ={
              allowUnfree = true;
              packageOverrides = pkgs:
              {
                luis = import luispkgs 
                {
                  system = "x86_64-linux";
                };
              };
            };
          })
        ];
     };
  };
}
# This allows the global use of unstable channel through
# pkgs.unstable.<package-name>!!
#nixpkgs.config =
#{
#    # Allow proprietary packages
#    allowUnfree = true;
#
#    # Create an alias for the unstable channel
#    packageOverrides = pkgs:
#    {
#        unstable = import <nixos-unstable>
#            {
#                # pass the nixpkgs config to the unstable alias
#                # to ensure `allowUnfree = true;` is propagated:
#                config = config.nixpkgs.config;
#            };
#    };
#};