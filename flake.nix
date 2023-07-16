{
  description = "OpenAI Whisper";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-23.05";

  outputs = {nixpkgs, ...}: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = with pkgs.python310Packages;
      buildPythonPackage {
        name = "whisper";
        version = "20230314";
        format = "setuptools";
        src = ./.;

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
}
