/// Sent from /obj/structure/transport/linear/tram when it begins to travel. (obj/effect/landmark/tram/idle_platform, obj/effect/landmark/tram/to_where)
#define COMSIG_TRAM_TRAVEL "tram_travel"

/// Sent from /obj/structure/transport/linear/tram when it hits someone: ()
#define COMSIG_TRAM_COLLISION "tram_collided"

/// Sent from a mob that just got hit by the tram
#define COMSIG_LIVING_HIT_BY_TRAM "tram_hit_me"

// Sent to and from SStransport for control between various components
/// Requesting transport move to a destination
#define COMSIG_TRANSPORT_REQUEST "!REQ"
/// Response to a COMSIG_TRANSPORT_REQUEST request signal
#define COMSIG_TRANSPORT_RESPONSE "!RESP"
/// Transport controller 'active' (busy) status
#define COMSIG_TRANSPORT_ACTIVE "!ACTV"
/// Transport controller destination change signal
#define COMSIG_TRANSPORT_DESTINATION "!DEST"
/// Transport controller communication status (tram malfunction event)
#define COMSIG_COMMS_STATUS "!COMM"
