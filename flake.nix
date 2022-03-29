{
  description = "Nix flake utils for Gadget dev environments";

  outputs = { self }: {
    lib = {
      writeServiceScriptBin = import ./writeServiceScriptBin.nix;
    };
  };
}
