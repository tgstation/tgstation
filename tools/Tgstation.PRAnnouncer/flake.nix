{
    description = "Tgstation.PRAnnouncer";

    inputs = {};

    outputs = { ... }: {
        nixosModules = {
            default = { ... }: {
                imports = [ ./Tgstation.PRAnnouncer.nix ];
            };
        };
    };
}
