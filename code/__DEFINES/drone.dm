
/// If drones are blacklisted from certain sensitive machines
GLOBAL_VAR_INIT(drone_machine_blacklist_enabled, TRUE)

#define DRONE_HANDS_LAYER 1
#define DRONE_HEAD_LAYER 2
#define DRONE_TOTAL_LAYERS 2

/// Message displayed when new drone spawns in drone network
#define DRONE_NET_CONNECT span_notice("DRONE NETWORK: [name] connected.")
/// Message displayed when drone in network dies
#define DRONE_NET_DISCONNECT span_danger("DRONE NETWORK: [name] is not responding.")

/// Maintenance Drone icon_state (multiple colors)
#define MAINTDRONE "drone_maint"
/// Repair Drone icon_state
#define REPAIRDRONE "drone_repair"
/// Scout Drone icon_state
#define SCOUTDRONE "drone_scout"
/// Clockwork Drone icon_state
#define CLOCKDRONE "drone_clock"

/// [MAINTDRONE] hacked icon_state
#define MAINTDRONE_HACKED "drone_maint_red"
/// [REPAIRDRONE] hacked icon_state
#define REPAIRDRONE_HACKED "drone_repair_hacked"
/// [SCOUTDRONE] hacked icon_state
#define SCOUTDRONE_HACKED "drone_scout_hacked"
