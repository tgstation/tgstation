# Core DMAPI functions

This folder contains all DMAPI code not directly involved in an API.

- [_definitions.dm](./definitions.dm) contains defines needed across DMAPI internals.
- [byond_world_export.dm](./byond_world_export.dm) contains the default `/datum/tgs_http_handler` implementation which uses `world.Export()`.
- [core.dm](./core.dm) contains the implementations of the `/world/proc/TgsXXX()` procs. Many map directly to the `/datum/tgs_api` functions. It also contains the /datum selection and setup code.
- [datum.dm](./datum.dm) contains the `/datum/tgs_api` declarations that all APIs must implement.
- [tgs_version.dm](./tgs_version.dm) contains the `/datum/tgs_version` definition
