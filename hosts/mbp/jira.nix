{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "jira" ''
      if [ -z "''${JIRA_API_TOKEN:-}" ]; then
        export JIRA_API_TOKEN
        JIRA_API_TOKEN=$(${pkgs._1password-cli}/bin/op item get "ATLASSIAN_MCP_TOKEN" \
          --vault "employee" \
          --fields "password" \
          --reveal)
      fi
      exec ${pkgs.jira-cli-go}/bin/jira "$@"
    '')
  ];
}
