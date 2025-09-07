{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    buildInputs = with pkgs; [
      nodejs
    ];

    info-server = pkgs.buildNpmPackage rec {
      name = "info-server";

      src = ./.;

      dontNpmBuild = true;

      npmDepsHash = "sha256-vR2Ap08SpK95ETfbQA6G945Yt90MlR6cA0oTqahqetg=";

      version = "0.1.0";

      postInstall = ''
        mkdir -p $out/bin
        exe="$out/bin/${name}"
        lib="$out/lib/node_modules/${name}"

        touch $exe
        chmod +x $exe
        echo "
            #!/usr/bin/env bash
            cd $lib
            ${pkgs.nodejs_20}/bin/node ./src/main.js" > $exe
      '';
    };
  in {
    packages.${pkgs.system} = {
      inherit info-server;
      default = info-server;
    };

    devShells.${pkgs.system}.default = pkgs.mkShell {
      inherit buildInputs;

      packages = with pkgs; [
        nixd #nix language server
        alejandra
      ];
    };
  };
}
