{ name
, keepFiles ? []
, lib
, writeShellScriptBin
, git
}:

writeShellScriptBin name ''
  ${git}/bin/git clean -xdf ${lib.concatStringsSep " " (builtins.map (file: "-e ${file}") keepFiles)}
''
