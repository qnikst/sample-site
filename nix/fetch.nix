package:
    let
      versions = builtins.fromJSON (builtins.readFile ./versions.json);
      spec = versions.${package};
    in
      fetchTarball {
        url =
          with spec;
          "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        sha256 = spec.sha256;
      }
