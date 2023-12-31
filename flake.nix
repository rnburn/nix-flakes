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
	  rev = "f3ea731";
	  hash = "sha256-Ozc7QM+1O3ib1PtzxsG8ZRsPoqmF4TonKVpEXXmTDYA=";
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
	# How to pass options to runtimes?
	#   https://discourse.llvm.org/t/how-to-pass-cmake-options-to-the-runtimes-configuration/61235
	NIX_LDFLAGS="-L${gccForLibs}/lib/gcc/${targetPlatform.config}/${gccForLibs.version} -L${gcc13.libc}/lib";
	CFLAGS="-B${gccForLibs}/lib/gcc/${targetPlatform.config}/${gccForLibs.version} -B${gcc13.libc}/lib";
	patches = [
	  ./clang_options.patch
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
	  "-DCMAKE_VERBOSE_MAKEFILE=ON"
	  "-DC_INCLUDE_DIRS=${gcc13.libc.dev}/include"
          "-DLLVM_TARGETS_TO_BUILD=\"host;NVPTX\""
	  "-DLLVM_BUILTIN_TARGETS=\"x86_64-unknown-linux-gnu\""
          "-DLLVM_RUNTIME_TARGETS=\"x86_64-unknown-linux-gnu\""
          "-DLLVM_ENABLE_PROJECTS=\"clang;clang-tools-extra\""
	  # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind;compiler-rt\""
	  # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind\""
	  # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi\""
	  "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind\""
	  # "-DCLANG_DEFAULT_CXX_STDLIB=\"libc++\""
	  "-DLIBCXX_ENABLE_SHARED=OFF"
	  "-DLIBCXX_ENABLE_STATIC=ON"
	  "-DLIBCXXABI_ENABLE_STATIC=ON"
	  "-DLIBUNWIND_ENABLE_STATIC=ON"
	  "-DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON"
	  "-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON"
	  "-DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON"
	  "-DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=YES"
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
