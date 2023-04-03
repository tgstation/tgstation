# DMAPI V5

This DMAPI implements bridge requests using HTTP GET requests to TGS. It has no security restrictions.

- [__interop_version.dm](./__interop_version.dm) contains the version of the API used between the DMAPI and TGS.
- [_defines.dm](./_defines.dm) contains constant definitions.
- [api.dm](./api.dm) contains the bulk of the API code.
- [commands.dm](./commands.dm) contains functions relating to `/datum/tgs_chat_command`s.
- [serializers.dm](./serializers.dm) contains function to help convert interop `/datum`s into a JSON encodable `list()` format.
- [undefs.dm](./undefs.dm) Undoes the work of `_defines.dm`.
