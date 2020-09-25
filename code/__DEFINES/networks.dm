#define HID_RESTRICTED_END 101		//the first nonrestricted ID, automatically assigned on connection creation.

#define NETWORK_ERROR_DISCONNECTED "exception_disconnected"
#define NETWORK_BROADCAST_ID "ALL"

/// Any device under limbo can only be found in LIMBO with knowing its hardware id
/// Limbo cannot be broadcasted or searched in.  Used for things like assembly or
/// point to point buttons.

#define NETWORK_LIMBO			"LIMBO"

#define STATION_NETWORK_ROOT 	"SS13_NTNET"
#define SYNDICATE_NETWORK_ROOT 	"SYNDI_NTNET"

#define NETWORK_TOOLS			"TOOLS"
#define NETWORK_TOOLS_REMOTES	"TOOLS.REMOTES"

#define NETWORK_AIRLOCKS 		"AIRLOCKS"

#define NETWORK_ATMOS 			"ATMOS"
#define NETWORK_ATMOS_AIRALARMS "ATMOS.AIRALARMS"	// all air alarms
#define NETWORK_ATMOS_SCUBBERS	"ATMOS.SCURBBERS"	// includes vents
#define NETWORK_ATMOS_ALARMS	"ATMOS.ALARMS"		// Console and station wide
#define NETWORK_ATMOS_CONTROL 	"ATMOS.CONTROL"
#define NETWORK_ATMOS_STORAGE 	"ATMOS.STORAGE"
#define NETWORK_CHARLIE_ATMOS 	"CHARLIE.ATMOS"


