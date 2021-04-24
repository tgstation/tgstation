# DMAPI V5

This DMAPI implements bridge requests using HTTP GET requests to TGS. It has no security restrictions.

- [_defines.dm](./_defines.dm) contains constant definitions.
- [api.dm](./api.dm) contains the bulk of the API code.
- [commands.dm](./commands.dm) contains functions relating to `/datum/tgs_chat_command`s.
- [undefs.dm](./undefs.dm) Undoes the work of `_defines.dm`.
