/// Requests from prayers
#define REQUEST_PRAYER "request_prayer"
/// Requests for Centcom
#define REQUEST_CENTCOM "request_centcom"
/// Requests for the Syndicate
#define REQUEST_SYNDICATE "request_syndicate"
/// Requests for the nuke code
#define REQUEST_NUKE "request_nuke"

/**
 * # Request
 *
 * A representation of an in-game request, such as a prayer.
 */
/datum/request
	/// Unique ID of the request
	var/id
	/// Atomic ID for increment unique request IDs
	var/static/atomic_id = 0
	/// The type of request
	var/req_type
	/// The owner of the request, the player who created it
	var/client/owner
	/// The ckey of the owner, used for re-binding variables on login
	var/owner_ckey
	/// The name of the owner, in format <key>/<name>, assigned at time of request creation
	var/owner_name
	/// The message associated with the request
	var/message
	/// When the request was created
	var/timestamp

/datum/request/New(client/requestee, type, request)
	if (!requestee)
		qdel(src)
		return
	id = ++atomic_id
	owner = requestee
	owner_ckey = owner.ckey
	req_type = type
	message = request
	timestamp = world.time
	owner_name = key_name(requestee, FALSE)
