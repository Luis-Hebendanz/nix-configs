{ stdenv, fetchurl  }:

stdenv.mkDerivation rec {
    pname = "dark-reader-${version}";
    version = "4.8.4";

    extid = "addon@darkreader.org";
    signed = true;

    src = fetchurl {
      url = "https://addons.mozilla.org/firefox/downloads/file/3436917/dark_reader-${version}-an+fx.xpi";
      sha256 = "07aqvslfa6appda0m5bszzsbmypivcy9srya7bhdv7ssg2836ffg";
    };

    phases = [ "installPhase" ];

    installPhase = ''
      install -D ${src} "$out/${extid}.xpi"

      '';

  meta = {
    description = "Dark reader firefox addon";
    homepage = https://outgoing.prod.mozaws.net/v1/3898cac9f9fd2d2702f9668f877d1e6066acd4864d5d806cf311f15502a17be1/https%3A//darkreader.org/;
    license = stdenv.lib.licenses.mit;
    maintainers = [];
    platforms = stdenv.lib.platforms.all;
  };
}
