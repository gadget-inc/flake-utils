{ services
, runtimeDir ? "services"
, lib
}:

let
  compileServiceEnv = {
    name,
    packages ? null,
    env ? null,
    ...
  }: builtins.concatStringsSep "\n" ([]
    ++ lib.singleton ''
      export PWD="$PWD"/${lib.escapeShellArg name}/data
    ''
    ++ lib.optional (packages != null) ''
      export PATH=${lib.makeBinPath packages}:$PATH
    ''
    ++ lib.optional (env != null) env
    ++ lib.singleton ''
      export PWD=$(dirname $(dirname "$PWD"))
    '');

  compileServiceEnvs = services:
    builtins.concatStringsSep "\n"
      (builtins.map compileServiceEnv services);
in
''
  export ROOT="$PWD"
  export PWD="$PWD"/${lib.escapeShellArg runtimeDir}
  ${compileServiceEnvs services}
  export PWD="$ROOT"
''
