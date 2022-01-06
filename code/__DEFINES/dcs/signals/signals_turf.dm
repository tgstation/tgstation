// Turf signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/// from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/post_change_callbacks).
/// `post_change_callbacks` is a list that signal handlers can mutate to append `/datum/callback` objects.
/// They will be called with the new turf after the turf has changed.
#define COMSIG_TURF_CHANGE "turf_change"
///from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"
///from base of turf/multiz_turf_del(): (turf/source, direction)
#define COMSIG_TURF_MULTIZ_DEL "turf_multiz_del"
///from base of turf/multiz_turf_new: (turf/source, direction)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"
///from base of turf/proc/onShuttleMove(): (turf/new_turf)
#define COMSIG_TURF_ON_SHUTTLE_MOVE "turf_on_shuttle_move"
///from /turf/open/temperature_expose(datum/gas_mixture/air, exposed_temperature)
#define COMSIG_TURF_EXPOSE "turf_expose"
///called when an industrial lift enters this turf
#define COMSIG_TURF_INDUSTRIAL_LIFT_ENTER "turf_industrial_life_enter"

///from /datum/element/decal/Detach(): (description, cleanable, directional, mutable_appearance/pic)
#define COMSIG_TURF_DECAL_DETACHED "turf_decal_detached"

/// from base /turf/zPassIn(): (atom/movable/A, direction, turf/source)
#define COMSIG_TURF_PRE_ZMOVE_CHECK_IN "turf_pre_zmove_check_in"
	#define COMPONENT_BLOCK_Z_IN_DOWN DOWN
	#define COMPONENT_BLOCK_Z_IN_UP UP

/// from base /turf/zPassOut(): (atom/movable/A, direction, turf/destination)
#define COMSIG_TURF_PRE_ZMOVE_CHECK_OUT "turf_pre_zmove_check_out"
	#define COMPONENT_BLOCK_Z_OUT_DOWN DOWN
	#define COMPONENT_BLOCK_Z_OUT_UP UP
