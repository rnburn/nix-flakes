{
  description = "Compiler";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      let 
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
	gccForLibs = gcc13.cc;
      in stdenvNoCC.mkDerivation {
        name = "clang";
        src = pkgs.fetchgit {
          url = "https://github.com/llvm/llvm-project";
	  rev = "53c81a8";
          hash = "sha256-VAWUY705XJ+URBvDWaCbnh4tq3v9eYsruUr8ehwihsY=";
        };
        nativeBuildInputs = [
          cmake
	  perl
          ninja
          python3
        ];
	buildInputs = [
	  gcc13
	];
	# configurePhase = "echo hello";
	# buildPhase = ''
	#   cat clang/lib/Driver/ToolChains/Gnu.cpp >> yip
	# '';
	# installPhase = "mkdir -p $out/bin; install -t $out/bin yip";
	NIX_LDFLAGS="-L${gccForLibs}/lib/gcc/${targetPlatform.config}/${gccForLibs.version} -L${gcc13.libc}/lib";
	CFLAGS="-B${gccForLibs}/lib/gcc/${targetPlatform.config}/${gccForLibs.version} -B${gcc13.libc}/lib";
	patches = [
	  ./clang_driver.patch
	];
	postPatch = ''
	  substituteInPlace clang/lib/Driver/ToolChains/Gnu.cpp \
	    --replace 'GLIBC_PATH_ABC123' '${gcc13.libc}/lib'
	'';
        configurePhase = pkgs.lib.strings.concatStringsSep " " [
          "mkdir build; cd build;"
          "cmake"
          "-G \"Unix Makefiles\""
	  "-DGCC_INSTALL_PREFIX=${gccForLibs}"
	  "-DC_INCLUDE_DIRS=${gcc13.libc.dev}/include"
          "-DLLVM_TARGETS_TO_BUILD=\"host;NVPTX\""
	  "-DLLVM_BUILTIN_TARGETS=\"x86_64-unknown-linux-gnu\""
          "-DLLVM_RUNTIME_TARGETS=\"x86_64-unknown-linux-gnu\""
          # "-DLLVM_ENABLE_PROJECTS=\"clang;clang-tools-extra;lld;lldb;openmp\""
          # "-DLLVM_ENABLE_PROJECTS=\"clang;clang-tools-extra\""
          "-DLLVM_ENABLE_PROJECTS=\"clang;clang-tools-extra\""
	  # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind;compiler-rt\""
	  # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind\""
	  # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi\""
	  "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi\""
	  # "-DCLANG_DEFAULT_CXX_STDLIB=\"libc++\""
	  "-DLIBCXX_ENABLE_SHARED=OFF"
	  "-DLIBCXX_ENABLE_STATIC=ON"
	  "-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON"
	  "-DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON"
	  # "-DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=YES"
          # "-DCOMPILER_RT_USE_LIBCXX=ON"
          "-DCMAKE_BUILD_TYPE=Release"
          "-DCMAKE_INSTALL_PREFIX=\"$out\""
          "../llvm"
        ];
        buildPhase = "make";
        installPhase = "make install";
      };

  };
}
