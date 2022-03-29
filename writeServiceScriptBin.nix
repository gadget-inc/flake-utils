{ name
, services
, runtimeDir ? "services"
, lib
, ansifilter
, coreutils
, gnugrep
, moreutils
, writeShellScriptBin
}:

let
  compileService = isLast:
    {
      name,
      ansiColor ? null,
      packages ? null,
      env ? null,
      setup ? null,
      run ? null,
      consoleFilter ? null,

      # These attributes are added when a service is created with callPackage
      # We allow them to be included on a service, but ignore their values
      override ? null,
      overrideDerivation ? null,
    }:
    let
      colorize = text:
        if ansiColor != null
        then "$'\\e[1;${ansiColor}m${text}\\e[0m'"
        else text;

      consoleFilterPipe = lib.optionalString (consoleFilter != null)
        " | ${gnugrep}/bin/grep -v ${consoleFilter}";
    in
      builtins.concatStringsSep "\n" ([]
        ++ lib.singleton ''
          mkdir -p ${lib.escapeShellArg name}/data
          cd ${lib.escapeShellArg name}/data
        ''
        ++ lib.optional (packages != null) ''
          export PATH=${lib.makeBinPath packages}:$PATH
        ''
        ++ lib.optional (env != null) env
        ++ lib.optional (setup != null) ''
          (${setup}) 2>&1 | ${moreutils}/bin/pee \
            "${moreutils}/bin/ts ${colorize "${name} (setup)>"}" \
            '${ansifilter}/bin/ansifilter > ../setup.log'
        ''
        ++ lib.optional (run != null) ''
          (${run}) 2>&1 | ${moreutils}/bin/pee \
            "${moreutils}/bin/ts ${colorize "${name}>"}${consoleFilterPipe}" \
            '${ansifilter}/bin/ansifilter > ../run.log'${lib.optionalString (!isLast) " &"}
        ''
        ++ lib.optional (run == null && isLast) ''
          ${coreutils}/bin/sleep infinity
        ''
        ++ lib.singleton ''
          cd ../..
        '');

  compileServices = services:
    builtins.concatStringsSep "\n"
      (lib.imap0
        (i: service:
          compileService
            (i == builtins.length services - 1)
            service)
        services);
in
writeShellScriptBin name ''
  set -e

  # Stop all services when Ctrl-C is pressed or error occurs
  trap 'kill $(jobs -p) 2>/dev/null; wait $(jobs -p)' INT TERM ERR EXIT

  export ROOT="$PWD"
  mkdir -p ${lib.escapeShellArg runtimeDir}
  cd ${lib.escapeShellArg runtimeDir}
  ${compileServices services}
  cd "$ROOT"
''
