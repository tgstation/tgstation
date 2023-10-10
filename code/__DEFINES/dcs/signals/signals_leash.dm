/// Called when a /datum/component/leash must forcibly teleport the parent to the owner.
/// Fired on the object with the leash component.
#define COMSIG_LEASH_FORCE_TELEPORT "leash_force_teleport"

/// Called when a /datum/component/leash plans on pathfinding to the target, if out of range.
/// Fired on the object with the leash component.
#define COMSIG_LEASH_PATH_STARTED "leash_path_started"

/// Called when a /datum/component/leash finishes its pathfinding to the target.
/// Fired on the object with the leash component.
#define COMSIG_LEASH_PATH_COMPLETE "leash_path_complete"
