/// Sent from /obj/structure/transport/linear/tram when it begins to travel. (obj/effect/landmark/tram/idle_platform, obj/effect/landmark/tram/to_where)
#define COMSIG_TRAM_TRAVEL "tram_travel"

/// Sent from /obj/structure/transport/linear/tram when it hits someone: ()
#define COMSIG_TRAM_COLLISION "tram_collided"

// Sent to and from SStransport for control between various components
#define COMSIG_TRANSPORT_REQUEST "!REQ"
#define COMSIG_TRANSPORT_RESPONSE "!RESP"
#define COMSIG_TRANSPORT_ACTIVE "!ACTV"
#define COMSIG_TRANSPORT_DESTINATION "!DEST"
#define COMSIG_TRANSPORT_LIGHTS "!LITE"
#define COMSIG_COMMS_STATUS "!COMM"
