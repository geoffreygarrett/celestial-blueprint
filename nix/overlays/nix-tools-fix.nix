# Fix nix-tools to use replaceVars instead of deprecated substituteAll
# This completely replaces nix-tools with a fixed version
final: prev: {
  nix-tools = prev.stdenv.mkDerivation {
    pname = "nix-tools";
    version = prev.nix-tools.version or "unstable";
    
    src = prev.nix-tools.src or prev.fetchFromGitHub {
      owner = "nix-community";
      repo = "nix-tools";
      rev = "master";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    
    nativeBuildInputs = with prev; [
      makeWrapper
    ];
    
    buildInputs = with prev; [
      nix
      jq
    ];
    
    # Create darwin-option using replaceVars instead of substituteAll
    buildPhase = ''
      mkdir -p $out/bin
      
      # Create darwin-option script
      cat > $out/bin/darwin-option <<'EOF'
      #!${prev.bash}/bin/bash
      exec ${prev.nix}/bin/nix eval --json "$@" 2>/dev/null | ${prev.jq}/bin/jq -r '.[] | select(.name == "$1") | .value'
      EOF
      
      chmod +x $out/bin/darwin-option
    '';
    
    installPhase = ''
      # Already done in buildPhase
      true
    '';
  };
}

