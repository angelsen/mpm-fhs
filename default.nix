{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.mpm-fhs;

  matlabInstallPath = "${config.home.homeDirectory}/matlab";

  nix-matlab = pkgs.fetchGit {
    url = "https://gitlab.com/doronbehar/nix-matlab.git";
    ref = "master";
  };

  matlabDeps = import "${nix-matlab}/common.nix" pkgs;

  mpmBinary = pkgs.stdenv.mkDerivation {
    pname = "mpm";
    version = "1.0";

    src = pkgs.fetchurl {
      url = "https://www.mathworks.com/mpm/glnxa64/mpm";
      sha256 = "sha256-opDYqv+RcoGlwVHvdERf1DLnboWdhhrpeQB/+rGTCxM=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/mpm
      chmod +x $out/bin/mpm
    '';

    meta = with lib; {
      description = "MATLAB Package Manager";
      homepage = "https://www.mathworks.com/products/matlab.html";
      platforms = platforms.linux;
    };
  };

  mpmFhsEnv = pkgs.buildFHSUserEnv {
    name = "mpm-fhs-env";
    targetPkgs = pkgs: matlabDeps ++ [mpmBinary];
    runScript = "${mpmBinary}/bin/mpm";
  };

  matlabFhsEnv = pkgs.buildFHSUserEnv {
    name = "matlab-fhs-env";
    targetPkgs = pkgs: matlabDeps;
    runScript = "${matlabInstallPath}/bin/matlab";
  };

  mpmEnvCommand = pkgs.writeShellScriptBin "mpm-env" ''
    ${mpmFhsEnv}/bin/mpm-fhs-env "$@"
  '';

  matlabEnvCommand = pkgs.writeShellScriptBin "matlab-env" ''
    ${matlabFhsEnv}/bin/matlab-fhs-env "$@"
  '';

  matlabInstallScript = pkgs.writeShellScriptBin "install-matlab" ''
    ${mpmFhsEnv}/bin/mpm-fhs-env install \
      --release ${escapeShellArg cfg.release} \
      --destination ${escapeShellArg matlabInstallPath} \
      --products ${escapeShellArgs cfg.products}
  '';

  matlabDesktopEntry = pkgs.makeDesktopItem {
    name = "matlab";
    desktopName = "MATLAB";
    exec = "${matlabFhsEnv}/bin/matlab-fhs-env -desktop %F";
    icon = "${matlabInstallPath}/bin/glnxa64/cef_resources/matlab_icon.png";
    comment = "MATLAB: The Language of Technical Computing";
    categories = ["Development" "Education" "Science"];
  };
in {
  options.programs.mpm-fhs = {
    enable = mkEnableOption "MATLAB Package Manager (MPM) with FHS environment";

    release = mkOption {
      type = types.str;
      default = "R2024b";
      description = "MATLAB release version to install";
    };

    products = mkOption {
      type = types.listOf types.str;
      default = ["MATLAB" "Simulink"];
      description = "List of MATLAB products to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      mpmEnvCommand
      matlabEnvCommand
      matlabInstallScript
      matlabDesktopEntry
    ];

    home.activation.installMatlab = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "${matlabInstallPath}" ]; then
        ${matlabInstallScript}/bin/install-matlab
      fi
    '';
  };
}
