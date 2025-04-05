inputs@{
  config,
  lib,
  systemdUtils,
  nixpkgs,
  pkgs,
  ...
}:

let
  cfg = config.services.tgstation-pr-announcer;

  package = import ./package.nix inputs;
in
{
  ##### interface. here we define the options that users of our service can specify
  options = {
    # the options for our service will be located under services.foo
    services.tgstation-pr-announcer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable tgstation-pr-announcer.
        '';
      };

      username = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "tgstation-pr-announcer";
        description = ''
          The name of the user used to execute tgstation-pr-announcer.
        '';
      };

      groupname = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "tgstation-pr-announcer";
        description = ''
          The name of group the user used to execute tgstation-pr-announcer will belong to.
        '';
      };

      production-appsettings = lib.mkOption {
        type = lib.types.path;
        default = '''';
        description = ''
          A formatted appsettings.Production.json file.
        '';
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
         Environment file as defined in {manpage}`systemd.exec(5)`
        '';
      };

      wants = lib.mkOption {
        type = lib.types.listOf systemdUtils.lib.unitNameType;
        default = [];
        description = ''
          Start the specified units when this unit is started.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups."${cfg.groupname}" = { };

    users.users."${cfg.username}" = {
      isSystemUser = true;
      group = cfg.groupname;
    };

    environment.etc = {
      "tgstation-pr-announcer.d/appsettings.Production.json" = {
        source = cfg.production-appsettings;
        group = cfg.groupname;
        mode = "0640";
      };
    };

    systemd.services.tgstation-pr-announcer = {
      description = "tgstation-pr-announcer";
      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        User = cfg.username;
        Type = "notify";
        WorkingDirectory = "/etc/tgstation-pr-announcer.d";
        ExecStart = "${package}/bin/Tgstation.PRAnnouncer";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ];
    };
  };
}
