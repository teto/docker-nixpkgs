{
  description = "A list of docker images built with nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }: 
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlay
        ];
      };
    in
    {

      # 
      packages =  {

        nix = pkgs.docker-nixpkgs.nix;
        nix-static = pkgs.docker-nixpkgs.nixStatic;
      };

    }) // {

      overlay = (import ./overlay.nix);
      
    };
}
