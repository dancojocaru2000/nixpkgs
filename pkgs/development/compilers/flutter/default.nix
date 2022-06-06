{ callPackage, fetchurl, dart }:
let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
  version = "3.0.1";
  channel = "stable";
  filename = "flutter_linux_${version}-${channel}.tar.xz";

  # Decouples flutter derivation from dart derivation,
  # use specific dart version to not need to bump dart derivation when bumping flutter.
  dartVersion = "2.17.1";
  dartSourceBase = "https://storage.googleapis.com/dart-archive/channels";
  dartForFlutter = dart.override {
    version = dartVersion;
    sources = {
      "${dartVersion}-x86_64-linux" = fetchurl {
        url = "${dartSourceBase}/stable/release/${dartVersion}/sdk/dartsdk-linux-x64-release.zip";
        sha256 = "696862ad8b7ecdceed43b85d4eb8279bc0f8dbb5b61b9e9afc86c54ecd7b40a2";
      };
    };
  };
in {
  inherit mkFlutter;
  stable = mkFlutter rec {
    inherit version;
    dart = dartForFlutter;
    pname = "flutter";
    src = fetchurl {
      url = "https://storage.googleapis.com/flutter_infra_release/releases/${channel}/linux/${filename}";
      sha256 = "fe088c6c399d3bf6958171cec1dfdb387bacb1b643413fa07e6c353fad80adc1";
    };
    patches = getPatches ./patches;
  };
}
