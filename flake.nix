{
  description = "A flake for building Hello World";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      let pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in stdenv.mkDerivation {
        name = "hello";
        src = pkgs.fetchgit {
          url = "https://github.com/llvm/llvm-project";
          rev = "7e856d1";
          hash = "sha256-KxItJo+Q/oI6A7rV/0sPEVLmKzXN07k93Sege01TVR4=";
        };
        buildPhase = "cp README.md speak";
        installPhase = "mkdir -p $out/bin; install -t $out/bin speak";
      };

  };
}
