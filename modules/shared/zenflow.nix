{ lib, stdenvNoCC, fetchurl, _7zz }:

stdenvNoCC.mkDerivation rec {
  pname = "zenflow";
  version = "latest";

  src = fetchurl {
    url = "https://download.zencoder.ai/zenflowapp/latest/darwin-arm64/Zenflow.dmg";
    sha256 = "sha256-1ZklOPrMOaNbAYxAXFqzQfKWT2+EmUp19CJFRHAIekM=";
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
