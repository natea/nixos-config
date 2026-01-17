{ lib, stdenvNoCC, fetchurl, _7zz }:

stdenvNoCC.mkDerivation rec {
  pname = "maestro";
  version = "0.14.0";

  src = fetchurl {
    url = "https://github.com/pedramamini/Maestro/releases/download/v${version}/Maestro-${version}-arm64.dmg";
    sha256 = "0pyzjzlzvlcvl2y98x67d6nrhph2xdmybmqbrwi7n60wwc72m362";
  };

  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    7zz x $src -o$TMPDIR
  '';

  installPhase = ''
    mkdir -p $out/Applications
    cp -r $TMPDIR/Maestro.app $out/Applications/
  '';

  meta = with lib; {
    description = "AI agent command center";
    homepage = "https://github.com/pedramamini/Maestro";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
