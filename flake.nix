{
  description = "tree-sitter-bash-parser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, devshell, }:

    flake-utils.lib.eachDefaultSystem
      (system:
       let
          dylibExt = if nixpkgs.lib.hasInfix "darwin" system then "dylib" else "so";  
          overlays = [
            devshell.overlays.default
          ];
          # don't treat pkgs as meaning nixpkgs - treat it as all packages!
          pkgs = import nixpkgs {
            inherit overlays system;
          };
          parser = pkgs.stdenv.mkDerivation {
	    name = "parser";
            src = ./.;
	    buildInputs = [pkgs.gcc];
            buildPhase = ''
	      gcc -o parser src/*.c -I./src \
	        -I${pkgs.tree-sitter}/include \
	        ${pkgs.tree-sitter}/lib/libtree-sitter.${dylibExt};
	    '';
	    installPhase = ''
	      mkdir -p $out/bin;
	      cp parser $out/bin/bash-parser;
	    '';
          };
        in
        rec
        {
	  packages.default = parser;

          devShells.default = pkgs.devshell.mkShell {
            name = "tree-sitter";
            packages = with pkgs; [
              tree-sitter
            ];
            commands = [
            ];
          };
        });
}
