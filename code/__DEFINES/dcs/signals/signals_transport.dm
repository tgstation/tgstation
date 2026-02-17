/// Sent from /obj/structure/transport/linear/tram when it hits someone: ()
#define COMSIG_TRAM_COLLISION "tram_collided"

/// Sent from a mob that just got hit by the tram
#define COMSIG_LIVING_HIT_BY_TRAM "tram_hit_me"

// Sent to and from SStransport for control between various components
/// Request messages to the transport controller from auxiliary devices (crossing signals, buttons, etc.)
#define COMSIG_TRANSPORT_REQUEST "!REQ"
/// Response messages from the transport controller to a COMSIG_TRANSPORT_REQUEST request signal
#define COMSIG_TRANSPORT_RESPONSE "!RESP"
/// Transport controller general status update. Includes: processing status, status alert bitflags, location info, and destination info
#define COMSIG_TRANSPORT_UPDATED "!ACTV"
