{ docker-nixpkgs
, nixStatic ? null
}:
if nixStatic == null
then null
else docker-nixpkgs.nix.override {
  nix = nixStatic;
  static = true;
}
