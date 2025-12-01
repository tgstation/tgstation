# DMAPI V5

This DMAPI implements bridge requests using HTTP GET requests to TGS. It has no security restrictions.

- [\_\_interop_version.dm](./__interop_version.dm) contains the version of the API used between the DMAPI and TGS.
- [\_defines.dm](./_defines.dm) contains constant definitions.
- [api.dm](./api.dm) contains the bulk of the API code.
- [bridge.dm](./bridge.dm) contains functions related to making bridge requests.
- [chunking.dm](./chunking.dm) contains common function for splitting large raw data sets into chunks BYOND can natively process.
- [commands.dm](./commands.dm) contains functions relating to `/datum/tgs_chat_command`s.
- [serializers.dm](./serializers.dm) contains function to help convert interop `/datum`s into a JSON encodable `list()` format.
- [topic.dm](./topic.dm) contains functions related to processing topic requests.
- [undefs.dm](./undefs.dm) Undoes the work of `_defines.dm`.
