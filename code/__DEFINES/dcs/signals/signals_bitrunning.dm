/// from /atom/movable/screen/alert/bitrunning/qserver_domain_complete
#define COMSIG_BITRUNNER_ALERT_SEVER "bitrunner_alert_sever"

/// from /obj/effect/bitrunning/loot_signal: (points)
#define COMSIG_BITRUNNER_GOAL_POINT "bitrunner_goal_point"

// Netpods

/// from /obj/machinery/netpod/sever_connection()
#define COMSIG_BITRUNNER_NETPOD_SEVER "bitrunner_netpod_sever"

/// from /obj/machinery/netpod/default_pry_open() : (mob/living/intruder)
#define COMSIG_BITRUNNER_CROWBAR_ALERT "bitrunner_crowbar"

/// from /obj/machinery/netpod/on_damage_taken()
#define COMSIG_BITRUNNER_NETPOD_INTEGRITY "bitrunner_netpod_damage"

/// from /obj/machinery/netpod/open_machine()
#define COMSIG_BITRUNNER_NETPOD_OPENED "bitrunner_netpod_opened"

// Server

/// from /obj/machinery/quantum_server/on_goal_turf_entered(): (atom/entered, reward_points)
#define COMSIG_BITRUNNER_DOMAIN_COMPLETE "bitrunner_complete"

/// from /obj/machinery/quantum_server/generate_loot()
#define COMSIG_BITRUNNER_CACHE_SEVER "bitrunner_cache_sever"

/// from /obj/machinery/quantum_server/sever_connection()
#define COMSIG_BITRUNNER_QSRV_SEVER "bitrunner_qserver_sever"

/// from /obj/machinery/quantum_server/shutdown() : (mob/living)
#define COMSIG_BITRUNNER_SHUTDOWN_ALERT "bitrunner_shutdown"

/// from /obj/machinery/quantum_server/notify_threat()
#define COMSIG_BITRUNNER_THREAT_CREATED "bitrunner_threat"

/// from /obj/machinery/quantum_server/scrub_vdom()
#define COMSIG_BITRUNNER_DOMAIN_SCRUBBED "bitrunner_domain_scrubbed"

/// from /obj/machienry/quantum_server/station_spawn()
#define COMSIG_BITRUNNER_STATION_SPAWN "bitrunner_station_spawn"

// Ladder
/// from /obj/structure/hololadder/disconnect()
#define COMSIG_BITRUNNER_LADDER_SEVER "bitrunner_ladder_sever"

/// Sent when a server console is emagged
#define COMSIG_BITRUNNER_SERVER_EMAGGED "bitrunner_server_emagged"
