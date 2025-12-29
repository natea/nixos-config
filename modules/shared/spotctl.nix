{ pkgs, lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "spotctl";
  version = "0.35.0";

  src = fetchurl {
    url = "https://github.com/spotinst/spotctl/releases/download/v${version}/spotctl-darwin-arm64-${version}.tar.gz";
    sha256 = "sha256-2fTP4QmIR5YrpTOeJkb14OWgjK4/QMyeq+zMlOBqoXA=";
  };

  # No build required - it's a prebuilt binary
  dontBuild = true;
  dontConfigure = true;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp spotctl $out/bin/
    chmod +x $out/bin/spotctl
  '';

  meta = with lib; {
    description = "CLI for Spot by NetApp (Rackspace Spot)";
    homepage = "https://github.com/spotinst/spotctl";
    license = licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "spotctl";
  };
}
