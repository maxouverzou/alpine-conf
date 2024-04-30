let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = with pkgs; [
    execline
  ];

  shellHook = ''
    export PATH="$PATH:$(pwd)/bin"
  '';

  BIN = toString ./bin;
}
