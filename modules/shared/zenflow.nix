{ lib, stdenvNoCC, fetchurl, _7zz }:

stdenvNoCC.mkDerivation rec {
  pname = "zenflow";
  version = "latest";

  src = fetchurl {
    url = "https://download.zencoder.ai/zenflowapp/latest/darwin-arm64/Zenflow.dmg";
    # "latest" URL: the hash changes whenever Zencoder ships a release; update from the mismatch error.
    sha256 = "sha256-fHLZd5lRhlweTRAnYyVISvgSzf2nfAnNAfLZ9jy226U=";
  };

  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    7zz x $src -o$TMPDIR
  '';

  # The DMG layout varies between releases (app at the root or inside a volume
  # folder), so locate Zenflow.app instead of assuming a fixed path.
  installPhase = ''
    app=$(find "$TMPDIR" -maxdepth 4 -type d -name 'Zenflow.app' -print -quit)
    if [ -z "$app" ]; then
      echo "Zenflow.app not found in DMG; contents:" >&2
      find "$TMPDIR" -maxdepth 3 >&2
      exit 1
    fi
    mkdir -p $out/Applications
    cp -r "$app" $out/Applications/
  '';

  meta = with lib; {
    description = "Multi-agent orchestration for production engineering";
    homepage = "https://zencoder.ai/zenflow";
    platforms = [ "aarch64-darwin" ];
  };
}
