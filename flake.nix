{
  description = "Nix flake utils for Gadget dev environments";

  outputs = { self }: {
    lib = {
      compileServiceEnv = import ./compileServiceEnv.nix;
      writeServiceScriptBin = import ./writeServiceScriptBin.nix;
    };
  };
}
