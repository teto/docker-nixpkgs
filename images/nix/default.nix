{ dockerTools
, bashInteractive
, cacert
, coreutils
, curl
, gitReallyMinimal
, gnutar
, gzip
, iana-etc
# to build a static nix
, static ? false
, nix
, openssh
, xz
, extraContents ? [ ]
, buildImage ? if static then dockerTools.buildLayeredImage  else dockerTools.buildImageWithNixDb
, lib
, pkgsStatic
}:
let
  image = buildImage {
    inherit (nix) name;

    contents = [
      ./root
      # for haskell binaries
      iana-etc
    ] ++ (if static then [
      # pkgsStatic.coreutils
      # pkgsStatic.bashInteractive
    ] else [
      coreutils
      # add /bin/sh
      nix
      bashInteractive

      # runtime dependencies of nix
      cacert
      gitReallyMinimal
      gnutar
      gzip
      openssh
      xz
    ]) ++ extraContents;

    extraCommands = ''
      # for /usr/bin/env
      mkdir usr
      ln -s ../bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 tmp

      # need a HOME
      mkdir -vp root

      echo $PWD
    ''
    + lib.optionalString static ''
      cp "${cacert}/etc/ssl/certs/ca-bundle.crt" ca-bundle.crt
      mkdir bin
      cp ${pkgsStatic.coreutils}/bin/* bin
      cp ${pkgsStatic.bashInteractive}/bin/* bin
    '';

    config = {
      Cmd = [ "/bin/bash" ];
      Env = [
        "ENV=/etc/profile.d/nix.sh"
        "BASH_ENV=/etc/profile.d/nix.sh"
        "NIX_BUILD_SHELL=/bin/bash"
        "NIX_PATH=nixpkgs=${./fake_nixpkgs}"
        "PAGER=cat"
        "PATH=/usr/bin:/bin"
        "SSL_CERT_FILE=${if static then "/ca-bundle.crt" else "${cacert}/etc/ssl/certs/ca-bundle.crt"}"
        "USER=root"
      ];
    };
  };
in
image // { meta = nix.meta // image.meta; }
