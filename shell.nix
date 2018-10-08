let pkgs = import ./nix {};
    ROOT = builtins.toString ./.;
in pkgs.haskellPackages.shellFor {
   packages=p: [p.sample-site];
   shellHook=
     ''
     '';
   LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath
     [ pkgs.xz.out
     ];
   buildInputs = [pkgs.cabal-install pkgs.xz ];
}
