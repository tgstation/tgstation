#if DM_VERSION < 510
#error The TGS DMAPI does not support BYOND versions < 510!
#endif

#define TGS_UNIMPLEMENTED "___unimplemented"
#define TGS_VERSION_PARAMETER "server_service_version"

#ifndef TGS_DEBUG_LOG
#define TGS_DEBUG_LOG(message)
#endif
