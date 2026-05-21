{
  lib,
  stdenv,
  fetchurl,
  gmp,
}:

stdenv.mkDerivation {
  pname = "lrs";
  version = "7.1b";

  src = fetchurl {
    url = "https://cgm.cs.mcgill.ca/~avis/C/lrslib/archive/lrslib-071b.tar.gz";
    sha256 = "sha256-3yJoLNdCMV/gT4Zs/kgE1ZUPfcf1FNW1829bf1r/kYg=";
  };
  buildInputs = [ gmp ];

  patches = [ ./071b.patch ];
  postPatch =  ''
    # 移除 Apple Clang 不支持的 -static-libgcc 标志
    substituteInPlace makefile \
      --replace-fail "-static-libgcc" ""
  '';
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-fgnu89-inline";
  makeFlags = [
    "prefix=${placeholder "out"}"
    "CC:=$(CC)"
  ];

  postFixup = ''
    for dll in $out/bin/*.dll; do
      orig=$(readlink -f $dll)
      rm $dll
      cp $orig $dll
    done
  '';

  meta = {
    description = "Implementation of the reverse search algorithm for vertex enumeration/convex hull problems";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.raskin ];
    platforms = with lib.platforms; (linux ++ windows ++ darwin);
    homepage = "http://cgm.cs.mcgill.ca/~avis/C/lrs.html";
  };
}
