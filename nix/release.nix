let
  pkgs = import ./. {};

  # Sample site that strips all unneeded parts and dependencies
  # from the package.
  smpl =
   (let smpl = pkgs.haskell.lib.overrideCabal
                pkgs.haskellPackages.sample-site (drv: {
     enableSharedExecutables = false;
     enableSeparateDataOutput = true;
     enableSeparateDocOutput = true;
     isLibrary = false;
     doHaddock = false;
     doCheck = true;
     testTarget = "--show-details=streaming";
   });
   in pkgs.stdenv.mkDerivation
     { name = "smpl-files";
       src = smpl;
       builder = pkgs.writeScript "files-builder"
         ''
         source $stdenv/setup
         mkdir -p $exe/bin
         for i in sample-site; do
           cp ${smpl}/bin/$i $exe/bin/$i
           chmod +w $exe/bin/$i
         done; 
         touch $out
         '';
       outputs = [
         "out"
         "exe"
       ];
    });

  # Build docker image.
  docker-sample-site = pkgs.callPackages ./docker.nix
    { sample-site = smpl;
    };

  self = rec {
    inherit pkgs;
    sample-site = pkgs.haskellPackages.sample-site;
    sample-site-docker = docker-sample-site;
    };
in self
