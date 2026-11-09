{
    description = "tgstation-pr-announcer";

    inputs = {};

    outputs = { ... }: {
        nixosModules = {
            default = { ... }: {
                imports = [ ./tgstation-pr-announcer.nix ];
            };
        };
    };
}
