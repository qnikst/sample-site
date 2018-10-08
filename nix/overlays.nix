{ fetch ? import ./fetch.nix }:
[ 

(self: super:
    let
      inner = super.haskellPackages.override {
        overrides = new: old: rec
         { swagger2 =
              old.callHackage "swagger2" "2.3" {};
         };
      };

      ourSourceOverrides =
        super.haskell.lib.packageSourceOverrides
         { sample-site = self.lib.cleanSource ../sample-site;

         };
    in
    { haskellPackages = 
        inner.extend ourSourceOverrides;
    }
  )
]
