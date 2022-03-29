{
  description = "Nix flake utils for Gadget dev environments";

  outputs = { self }: {
    lib = {
      compileServiceEnv = import ./compileServiceEnv.nix;
      writeCleanScriptBin = import ./writeCleanScriptBin.nix;
      writeServiceScriptBin = import ./writeServiceScriptBin.nix;
    };
  };
}
