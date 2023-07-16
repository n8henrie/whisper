{
  description = "OpenAI Whisper";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    systems = ["aarch64-darwin"];
  in
    builtins.foldl' (acc: system: let
      pkgs = import nixpkgs {inherit system;};
    in
      lib.recursiveUpdate acc
      {
        packages.${system} = {
          default = self.packages.${system}.whisper;
          whisper = with pkgs.python310Packages;
            buildPythonPackage {
              name = "whisper";
              version = "20230314";
              format = "setuptools";
              src = ./.;

              doCheck = false;
              propagatedBuildInputs = [
                numba
                numpy
                torch
                tqdm
                more-itertools
                tiktoken
              ];
            };
        };
        apps.${system} = {
          default = self.apps.${system}.whisper;
          whisper = {
            type = "app";
            program = "${self.packages.${system}.whisper}/bin/whisper";
          };
        };
      }) {}
    systems;
}
