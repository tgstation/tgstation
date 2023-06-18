/// The amount of cell charge drained during a drain failure.
#define MICROFUSION_CELL_DRAIN_FAILURE 500
/// The heavy EMP range for when a cell suffers an EMP failure.
#define MICROFUSION_CELL_EMP_HEAVY_FAILURE 2
/// The light EMP range for when a cell suffers an EMP failure.
#define MICROFUSION_CELL_EMP_LIGHT_FAILURE 4
/// The radiation range for when a cell suffers a radiation failure.
#define MICROFUSION_CELL_RADIATION_RANGE_FAILURE 1

/// The lower most time for a microfusion cell meltdown.
#define MICROFUSION_CELL_FAILURE_LOWER (10 SECONDS)
/// The upper most time for a microfusion cell meltdown.
#define MICROFUSION_CELL_FAILURE_UPPER (15 SECONDS)

/// A charge drain failure.
#define MICROFUSION_CELL_FAILURE_TYPE_CHARGE_DRAIN 1
/// A small explosion failure.
#define MICROFUSION_CELL_FAILURE_TYPE_EXPLOSION 2
/// EMP failure.
#define MICROFUSION_CELL_FAILURE_TYPE_EMP 3
/// Radiation failure.
#define MICROFUSION_CELL_FAILURE_TYPE_RADIATION 4

/// Returned when the phase emtiter process is successful.
#define SHOT_SUCCESS "success"
/// Returned when a gun is fired but there is no phase emitter.
#define SHOT_FAILURE_NO_EMITTER "no phase emitter!"

/// The error message returned when the phase emitter is processed but damaged.
#define PHASE_FAILURE_DAMAGED "PHASE EMITTER: Emitter damaged!"
/// The error message returned when the phase emitter has reached it's htermal throttle.
#define PHASE_FAILURE_THROTTLE "PHASE EMITTER: Thermal throttle active!"

/// The heat dissipation bonus of an emitter being in space!
#define PHASE_HEAT_DISSIPATION_BONUS_SPACE 30
/// The heat dissipation bonus of an emitter being in air!
#define PHASE_HEAT_DISSIPATION_BONUS_AIR 10

// Slot defines for the gun.
/// The gun barrel slot.
#define GUN_SLOT_BARREL "barrel"
/// The gun underbarrel slot.
#define GUN_SLOT_UNDERBARREL "underbarrel"
/// The gun rail slot.
#define GUN_SLOT_RAIL "rail"
/// Unique slots, can hold as many as you want.
#define GUN_SLOT_UNIQUE "unique"
/// Camo slot. Because why would you put four overlapping camos on your gun?
#define GUN_SLOT_CAMO "camo"

/// Max name size for changing names
#define GUN_MAX_NAME_CHARS 20
/// Min name size for changing names
#define GUN_MIN_NAME_CHARS 3
