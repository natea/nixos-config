{ lib, stdenvNoCC, fetchurl, _7zz }:

stdenvNoCC.mkDerivation rec {
  pname = "zenflow";
  version = "latest";

  src = fetchurl {
    url = "https://download.zencoder.ai/zenflowapp/latest/darwin-arm64/Zenflow.dmg";
    sha256 = "1ay4kc3wjvb1mblfd2rdlpm2a0pai9bkdr0220vhrkll1q3ih3nj";
  };

  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    7zz x $src -o$TMPDIR
  '';

  installPhase = ''
    mkdir -p $out/Applications
    cp -r $TMPDIR/Zenflow.app $out/Applications/
  '';

  meta = with lib; {
    description = "Multi-agent orchestration for production engineering";
    homepage = "https://zencoder.ai/zenflow";
    platforms = [ "aarch64-darwin" ];
  };
}
