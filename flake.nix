{
  description = "birdofscarlet's Niri Flake System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release"; # not wired up yet
    textfox.url = "github:adriankarlen/textfox";                          # not wired up yet
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      mkHost = hostname: homeFile:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs hostname; };
                users.cardinal = import homeFile;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        alicebox = mkHost "alicebox" ./modules/home;
        # alicepad = mkHost "alicepad" ./hosts/alicepad/home.nix;
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
