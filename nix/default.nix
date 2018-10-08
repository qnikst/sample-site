let 
  fetch = import ./fetch.nix;
in { nixpkgs ? fetch "nixpkgs" }: import nixpkgs {
  overlays = import ./overlays.nix {inherit fetch;};
}
