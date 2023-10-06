{
  description = "Compiler";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      let pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in stdenv.mkDerivation {
        name = "clang";
        src = pkgs.fetchgit {
          url = "https://github.com/llvm/llvm-project";
          rev = "7e856d1";
          hash = "sha256-KxItJo+Q/oI6A7rV/0sPEVLmKzXN07k93Sege01TVR4=";
        };
        nativeBuildInputs = [
          cmake
          ninja
          python3
        ];
        configurePhase = pkgs.lib.strings.concatStringsSep " " [
          "mkdir build; cd build;"
          "cmake"
          "-G \"Unix Makefiles\""
          "-DLLVM_ENABLE_PROJECTS=\"clang\""
          "-DCMAKE_BUILD_TYPE=Relase"
          "-DCMAKE_INSTALL_PREFIX=\"$out\""
          "../llvm"
        ];
        buildPhase = "make";
        installPhase = "make install";
      };

  };
}
