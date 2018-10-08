{ pkgs
, dockerTools
, writeScript
, sample-site
, busybox
, iana-etc
}:
let
  startupScript = writeScript "run" ''
     #!/bin/sh
     echo "starting web server.."
     ${sample-site.exe}/bin/sample-site
     wait
  '';
in
dockerTools.buildImage {
  name = "sample-site";
  fromImageName = "scratch";
  tag = "latest"; # XXX: this is not nice, but it's easy to manage;
  contents = [sample-site.exe busybox iana-etc ];
  config = {
    ExposedPorts = {
      "8080/tcp" = {};
    };
    Entrypoint = [ "${startupScript}" ];
    Cmd = [ ];
  };
}
