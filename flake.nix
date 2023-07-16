{
  description = "OpenAI Whisper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    mach-nix.url = "github:davhau/mach-nix";
  };

  outputs = {
    nixpkgs,
    mach-nix,
    ...
  }: let
    pythonVersion = "python39";
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
    mach = mach-nix.lib.${system};

    pythonEnv = mach.mkPython {
      python = pythonVersion;
      requirements = builtins.readFile ./requirements.txt;
    };
  in {
    devShells.${system}.default = pkgs.mkShellNoCC {
      packages = [
        pythonEnv
        pkgs.ffmpeg
        pkgs.rustc
      ];

      shellHook = ''
        export PYTHONPATH="${pythonEnv}/bin/python"
      '';
    };
  };
}
