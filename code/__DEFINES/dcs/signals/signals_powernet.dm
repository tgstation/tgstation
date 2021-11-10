// powernet related signals

/// Machine hardwired to powernet: (machine, new_powernet)
#define COMSIG_POWERNET_CABLE_ATTACHED "powernet_cable_attached"
/// Machine removed hardwiring from powernet: (machine, old_powernet)
#define COMSIG_POWERNET_CABLE_DETACHED "powernet_cable_detached"
/// Is there anything that can take a refund from speculatively provided power?
/// Typically SMES units with high power output. Looks at and adjusts netexcess on the attached powernet.
///from /datum/powernet/proc/reset: (powernet)
#define COMSIG_POWERNET_DO_REFUND "powernet_do_refund"
/// Should a cable not be allowed to connect between these two positions?
/// Typically between a terminal and the master it is attached to
///from each turf: (direction_from_turf)
#define COMSIG_POWERNET_CABLE_CHECK_BLOCK "powernet_cable_check_block"
	// If the connection should be blocked
	#define PREVENT_CABLE_LINK (1<<0)
