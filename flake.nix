{
  description = "Compiler";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      let 
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
	gccForLibs = gcc.cc;
      in stdenvNoCC.mkDerivation {
        name = "clang";
        src = pkgs.fetchgit {
          url = "https://github.com/llvm/llvm-project";
          rev = "11caef0";
          hash = "sha256-Rcmw0hMy58toxPhNithea2UH5NMvytRf4fp2WqUjLvs=";
        };
        nativeBuildInputs = [
          cmake
	  perl
          ninja
          python3
        ];
	buildInputs = [
	  gcc
	];
	configurePhase = "echo hello";
	buildPhase = ''
	  echo ${gcc.libc.dev} >> yip
	  echo ${gccForLibs} >> yip
	  echo ${gccForLibs}/lib/gcc/${targetPlatform.config}/${gccForLibs.version} >> yip
	'';
	installPhase = "mkdir -p $out/bin; install -t $out/bin yip";
        # configurePhase = pkgs.lib.strings.concatStringsSep " " [
        #   "mkdir build; cd build;"
        #   "cmake"
        #   "-G \"Unix Makefiles\""
	#   "-DC_INCLUDE_DIRS=${gcc.libc.dev}/include"
        #   "-DLLVM_TARGETS_TO_BUILD=\"host\""
	#   "-DLLVM_BUILTIN_TARGETS=\"x86_64-unknown-linux-gnu\""
        #   "-DLLVM_RUNTIME_TARGETS=\"x86_64-unknown-linux-gnu\""
        #   # "-DLLVM_ENABLE_PROJECTS=\"clang;clang-tools-extra;lld;lldb;openmp\""
        #   "-DLLVM_ENABLE_PROJECTS=\"clang\""
	#   # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind;compiler-rt\""
	#   # "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind\""
	#   "-DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi\""
	#   "-DCLANG_DEFAULT_CXX_STDLIB=\"libc++\""
	#   "-DLIBCXX_ENABLE_SHARED=YES"
	#   "-DLIBCXX_ENABLE_STATIC=YES"
	#   "-DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=YES"
	#   # "-DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=YES"
        #   # "-DCOMPILER_RT_USE_LIBCXX=ON"
        #   "-DCMAKE_BUILD_TYPE=Release"
        #   "-DCMAKE_INSTALL_PREFIX=\"$out\""
        #   "../llvm"
        # ];
        # buildPhase = "make";
        # installPhase = "make install";
      };

  };
}
