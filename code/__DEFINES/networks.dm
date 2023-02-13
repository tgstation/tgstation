#define HID_RESTRICTED_END 101 //the first nonrestricted ID, automatically assigned on connection creation.

#define NETWORK_BROADCAST_ID "ALL"

/// To debug networks use this to check
//#define DEBUG_NETWORKS 1


/// We do some macro magic to make sure the strings are created at compile time rather than runtime
/// We do it this way so that if someone changes any of the names of networks we don't have to hunt down
/// all the constants though all the files for them.  hurrah!

/// Ugh, couldn't get recursive stringafy to work in byond for some reason
#define NETWORK_NAME_COMBINE(L,R) ((L) + "." + (R))

/// Station network names.  Used as the root networks for main parts of the station
#define __STATION_NETWORK_ROOT "SS13"
#define __CENTCOM_NETWORK_ROOT "CENTCOM"
#define __SYNDICATE_NETWORK_ROOT "SYNDI"
#define __LIMBO_NETWORK_ROOT "LIMBO" // Limbo is a dead network

/// various sub networks pieces
#define __NETWORK_LIMBO "LIMBO"
#define __NETWORK_TOOLS "TOOLS"
#define __NETWORK_CONTROL "CONTROL"
#define __NETWORK_STORAGE "STORAGE"
#define __NETWORK_CARGO "CARGO"
#define __NETWORK_BOTS "BOTS"
#define __NETWORK_COMPUTER "COMPUTER"
#define __NETWORK_TABLETS "TABLETS"
#define __NETWORK_CIRCUITS "CIRCUITS"

/// Various combined subnetworks
#define NETWORK_TABLETS NETWORK_NAME_COMBINE(__NETWORK_COMPUTER, __NETWORK_TABLETS)
#define NETWORK_BOTS_CARGO NETWORK_NAME_COMBINE(__NETWORK_CARGO, __NETWORK_BOTS)


// Finally turn eveything into strings
#define STATION_NETWORK_ROOT __STATION_NETWORK_ROOT
#define CENTCOM_NETWORK_ROOT __CENTCOM_NETWORK_ROOT
#define SYNDICATE_NETWORK_ROOT __SYNDICATE_NETWORK_ROOT
#define LIMBO_NETWORK_ROOT __LIMBO_NETWORK_ROOT



/// Network name should be all caps and no punctuation except for _ and . between domains
/// This does a quick an dirty fix to a network name to make sure it works
/proc/simple_network_name_fix(name)
	// can't make this as a define, some reason findtext(name,@"^[^\. ]+[A-Z0-9_\.]+[^\. ]+$") dosn't work
	var/static/regex/check_regex = new(@"[ \-]{1}","g")
	return check_regex.Replace(uppertext(name),"_")
/*
 * Helper that verifies a network name is valid.
 *
 * A valid network name (ie, SS13.ATMOS.SCRUBBERS) is all caps, no spaces with periods between
 * branches.  Returns false if it doesn't meat this requirement
 *
 * Arguments:
 * * name - network text name to check
*/
/proc/verify_network_name(name)
	// can't make this as a define, some reason findtext(name,@"^[^\. ]+[A-Z0-9_\.]+[^\. ]+$") dosn't work
	var/static/regex/check_regex = new(@"^(?=[^\. ]+)[A-Z0-9_\.]+[^\. ]+$")
	return istext(name) && check_regex.Find(name)



/// Port protocol.  A port is just a list with a few vars that are used to send signals
/// that something is refreshed or updated.  These macros make it faster rather than
/// calling procs
#define NETWORK_PORT_DISCONNECTED(LIST) (!LIST || LIST["_disconnected"])
#define NETWORK_PORT_UPDATED(LIST) (LIST && !LIST["_disconnected"] && LIST["_updated"])
#define NETWORK_PORT_UPDATE(LIST) if(LIST) { LIST["_updated"] = TRUE }
#define NETWORK_PORT_CLEAR_UPDATE(LIST) if(LIST) { LIST["_updated"] = FALSE }
#define NETWORK_PORT_SET_UPDATE(LIST) if(LIST) { LIST["_updated"] = TRUE }
#define NETWORK_PORT_DISCONNECT(LIST) if(LIST) { LIST["_disconnected"] = TRUE }

/// Error codes
#define NETWORK_ERROR_OK null
#define NETWORK_ERROR_NOT_ON_NETWORK "network_error_not_on_network"
#define NETWORK_ERROR_BAD_NETWORK "network_error_bad_network"
#define NETWORK_ERROR_BAD_RECEIVER_ID "network_error_bad_receiver_id"
#define NETWORK_ERROR_UNAUTHORIZED "network_error_bad_unauthorized"

