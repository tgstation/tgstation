// Aquarium related signals
#define COMSIG_AQUARIUM_SURFACE_CHANGED "aquarium_surface_changed"
#define COMSIG_AQUARIUM_FLUID_CHANGED "aquarium_fluid_changed"

// Fish signals
#define COMSIG_FISH_STATUS_CHANGED "fish_status_changed"
#define COMSIG_FISH_STIRRED "fish_stirred"

/// Fishing challenge completed
#define COMSIG_FISHING_CHALLENGE_COMPLETED "fishing_completed"
/// Called when you try to use fishing rod on anything
#define COMSIG_PRE_FISHING "pre_fishing"

/// Sent by the target of the fishing rod cast
#define COMSIG_FISHING_ROD_CAST "fishing_rod_cast"
	#define FISHING_ROD_CAST_HANDLED (1 << 0)

/// Sent when fishing line is snapped
#define COMSIG_FISHING_LINE_SNAPPED "fishing_line_interrupted"
