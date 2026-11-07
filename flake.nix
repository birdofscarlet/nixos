{
  description = "birdofscarlet's Niri Flake System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    textfox.url = "github:adriankarlen/textfox";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... } @ inputs: {
    nixosConfigurations = {
      "alicebox" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        
        modules = [
          ./hosts/alicebox/configuration.nix
          nix-flatpak.nixosModules.nix-flatpak 
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            
            home-manager.users.cardinal = import ./home.nix;
          }
        ];
      };
    };
  };
}
