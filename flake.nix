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

          torchGPU = with pkgs.python310Packages;
            buildPythonPackage rec {
              pname = "torch";
              version = "2.0.1";
              format = "wheel";
              src = fetchPypi {
                inherit pname version format;
                sha256 = "sha256-eHtaeKp5F0Zem5Y5m4g5IMiKCPTrY7Wl0tGhbifS+Js=";
                python = "cp310";
                dist = python;
                platform = "macosx_11_0_arm64";
              };
              propagatedBuildInputs = [
                cffi
                click
                filelock
                jinja2
                networkx
                numpy
                pyyaml
                sympy
                typing-extensions
              ];
            };

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
                self.packages.${system}.torchGPU
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
