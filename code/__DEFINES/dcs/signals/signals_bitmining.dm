/// from /obj/structure/netchair/enter_matrix() : (datum/weakref/mind_ref)
#define COMSIG_BITMINING_CLIENT_CONNECTED "bitminining_connected"

/// from /obj/structure/netchair/disconnect_occupant() : (datum/weakref/mind_ref)
#define COMSIG_BITMINING_CLIENT_DISCONNECTED "bitmining_disconnected"

/// from /obj/machinery/netpod/default_pry_open() : (mob/living/intruder)
#define COMSIG_BITMINING_CROWBAR_ALERT "bitmining_crowbar"

/// from /obj/effect/spawner/bitminer_loot() : (points)
#define COMSIG_BITMINING_GOAL_POINT "bitmining_goal_point"

/// from /obj/machinery/quantum_server/on_exit_turf_entered(): (atom/entered)
#define COMSIG_BITMINING_DOMAIN_COMPLETE "bitmining_complete"

/// from /obj/machinery/netpod/on_take_damage()
#define COMSIG_BITMINING_NETPOD_INTEGRITY "bitmining_netpod_damage"

/// from /obj/structure/hololadder and others:
#define COMSIG_BITMINING_SAFE_DISCONNECT "bitmining_disconnect"

/// from /obj/machinery/netpod/open_machine(), /obj/machinery/quantum_server, etc (obj/machinery/netpod)
#define COMSIG_BITMINING_SEVER_AVATAR "bitmining_sever"

/// from /obj/machinery/quantum_server/shutdown() : (obj/machinery/quantum_server)
#define COMSIG_BITMINING_SHUTDOWN_ALERT "bitmining_shutdown"

