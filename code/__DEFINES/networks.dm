#define HID_RESTRICTED_END 101		//the first nonrestricted ID, automatically assigned on connection creation.

#define NETWORK_ERROR_DISCONNECTED "exception_disconnected"
#define NETWORK_BROADCAST_ID "ALL"

/// Any device under limbo can only be found in LIMBO with knowing its hardware id
/// Limbo shouldn't be searched or broadcasted.  Its for things like ruins and such

#define NETWORK_LIMBO			"LIMBO"

#define STATION_NETWORK_ROOT 	"SS13"
#define CENTCOM_NETWORK_ROOT 	"CENTCOM"
#define SYNDICATE_NETWORK_ROOT 	"SYNDI"

#define NETWORK_TOOLS			"TOOLS"
#define NETWORK_TOOLS_REMOTES	"TOOLS.REMOTES"

#define NETWORK_AIRLOCKS 		"AIRLOCKS"

#define NETWORK_ATMOS 			"ATMOS"
#define NETWORK_ATMOS_AIRALARMS "ATMOS.AIRALARMS"	// all air alarms
#define NETWORK_ATMOS_SCUBBERS	"ATMOS.SCURBBERS"	// includes vents
#define NETWORK_ATMOS_ALARMS	"ATMOS.ALARMS"		// Console and station wide
#define NETWORK_ATMOS_CONTROL 	"ATMOS.CONTROL"
#define NETWORK_ATMOS_STORAGE 	"ATMOS.STORAGE"
#define NETWORK_BOTS_CARGO	 	"BOTS.CARGO"

#define NETWORK_SET_ROOT(A,B)   ((A) + "." + (B))

GLOBAL_LIST_EMPTY(map_to_station_root_id)


#define NETWORK_PORT_DISCONNECTED(LIST) (!LIST || LIST["_disconnected"])
#define NETWORK_PORT_UPDATED(LIST) (LIST && !LIST["_disconnected"] && LIST["_updated"])
#define NETWORK_PORT_UPDATE(LIST) if(LIST) { LIST["_updated"] = TRUE }
#define NETWORK_PORT_CLEAR_UPDATE(LIST) if(LIST) { LIST["_updated"] = FALSE }
#define NETWORK_PORT_SET_UPDATE(LIST) if(LIST) { LIST["_updated"] = TRUE }
#define NETWORK_PORT_DISCONNECT(LIST)  if(LIST) { LIST["_disconnected"] = TRUE }

