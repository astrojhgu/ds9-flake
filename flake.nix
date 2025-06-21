{
  description = "DS9 binary flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        libPath = pkgs.lib.makeLibraryPath [
          pkgs.xorg.libX11
          pkgs.xorg.libXScrnSaver
          pkgs.xorg.libXft
          (pkgs.lib.getLib pkgs.gcc.cc)
          pkgs.fontconfig.lib
          pkgs.libxml2
        ];
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "ds9";
          version = "8.4";

          src = ./ds9;  # 直接引用裸二进制文件
          dontUnpack = true;

          installPhase = ''
            mkdir -p $out/bin
            cp -p $src $out/bin/ds9
            chmod 755 $out/bin/ds9
          '';

          fixupPhase = ''
            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath ${libPath} $out/bin/ds9
          '';

          buildInputs = [
            pkgs.xorg.libX11
            pkgs.xorg.libXScrnSaver
            pkgs.xorg.libXft
            (pkgs.lib.getLib pkgs.gcc.cc)
            pkgs.fontconfig.lib
            pkgs.libxml2
          ];
        };
      }
    );
}
