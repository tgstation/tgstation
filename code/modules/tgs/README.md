# DMAPI Internals

This folder should be placed on its own inside a codebase that wishes to use the TGS DMAPI. Warranty void if modified.

- [includes.dm](./includes.dm) is the file that should be included by DM code, it handles including the rest.
- The [core](./core) folder includes all code not directly part of any API version.
- The other versioned folders contain code for the different DMAPI versions.
    - [v3210](./v3210) contains the final TGS3 API.
    - [v4](./v4) is the legacy DMAPI 4 (Used in TGS 4.0.X versions).
    - [v5](./v5) is the current DMAPI version used by TGS >=4.1.
- [LICENSE](./LICENSE) is the MIT license for the DMAPI.

APIs communicate with TGS in two ways. All versions implement TGS -> DM communication using /world/Topic. DM -> TGS communication, called the bridge method, is different for each version.
