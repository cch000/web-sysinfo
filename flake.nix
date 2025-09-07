{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    buildInputs = with pkgs; [
      nodejs
    ];

    name = "info-server";

    info-server = pkgs.buildNpmPackage {
      inherit name;

      src = ./.;

      npmDepsHash = "sha256-vR2Ap08SpK95ETfbQA6G945Yt90MlR6cA0oTqahqetg=";

      version = "0.1.0";

      dontNpmBuild = true;

      installPhase = ''
        mkdir -p $out/bin $out/lib
        cp -rv ./node_modules $out/lib
        cp -rv ./src/main.js $out/lib
        cp -rv package.json $out/lib

        cat > $out/bin/${name} << EOF
        #!/bin/sh
        ${pkgs.lib.getExe pkgs.nodejs} $out/lib/main.js
        EOF

        chmod +x $out/bin/${name}
      '';
      meta.mainProgram = "${name}";
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
