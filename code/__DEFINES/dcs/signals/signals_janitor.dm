//Janitor

///Called on an object to "clean it", such as removing blood decals/overlays, etc. The clean types bitfield is sent with it. Return TRUE if any cleaning was necessary and thus performed.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"
	///Returned by cleanable components when they are cleaned.
	#define COMPONENT_CLEANED (1<<0)

// Vacuum signals
/// Called on a bag being attached to a vacuum parent
#define COMSIG_VACUUM_BAG_ATTACH "comsig_vacuum_bag_attach"
/// Called on a bag being detached from a vacuum parent
#define COMSIG_VACUUM_BAG_DETACH "comsig_vacuum_bag_detach"

///(): Returns bitflags of wet values.
#define COMSIG_TURF_IS_WET "check_turf_wet"
///(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"
