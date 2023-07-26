/// from /obj/machinery/netpod/default_pry_open() : (mob/living/intruder)
#define COMSIG_BITMINING_CROWBAR_ALERT "bitmining_crowbar"

/// from /obj/machinery/quantum_server/shutdown() : (obj/machinery/quantum_server)
#define COMSIG_BITMINING_SHUTDOWN_ALERT "bitmining_shutdown"

/// from /obj/machinery/quantum_server/on_destroyed()
#define COMSIG_BITMINING_SERVER_CRASH "bitmining_crash"

/// from /obj/structure/netchair/enter_matrix() : (datum/weakref/mind_ref)
#define COMSIG_BITMINING_CLIENT_CONNECTED "bitminining_connected"

/// from /obj/structure/netchair/disconnect_occupant() : (datum/weakref/mind_ref)
#define COMSIG_BITMINING_CLIENT_DISCONNECTED "bitmining_disconnected"
