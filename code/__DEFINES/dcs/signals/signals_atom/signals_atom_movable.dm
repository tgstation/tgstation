// Atom movable signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/movable/Moved(): (/atom)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE (1<<0)
///from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_MOVED "movable_moved"
///from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS "movable_cross"
///from base of atom/movable/Move(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS_OVER "movable_cross_am"
///from base of atom/movable/Bump(): (/atom)
#define COMSIG_MOVABLE_BUMP "movable_bump"
///from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT "movable_impact"
	#define COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH (1<<0) //if true, flip if the impact will push what it hits
	#define COMPONENT_MOVABLE_IMPACT_NEVERMIND (1<<1) //return true if you destroyed whatever it was you're impacting and there won't be anything for hitby() to run on
///from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"
///from /atom/movable/proc/buckle_mob(): (mob/living/M, force, check_loc, buckle_mob_flags)
#define COMSIG_MOVABLE_PREBUCKLE "prebuckle" // this is the last chance to interrupt and block a buckle before it finishes
	#define COMPONENT_BLOCK_BUCKLE (1<<0)
///from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_BUCKLE "buckle"
///from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
///from /obj/vehicle/proc/driver_move, caught by the riding component to check and execute the driver trying to drive the vehicle
#define COMSIG_RIDDEN_DRIVER_MOVE "driver_move"
	#define COMPONENT_DRIVER_BLOCK_MOVE (1<<0)
///from base of atom/movable/throw_at(): (list/args)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"
	#define COMPONENT_CANCEL_THROW (1<<0)
///from base of atom/movable/throw_at(): (datum/thrownthing, spin)
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"
///from base of datum/thrownthing/finalize(): (obj/thrown_object, datum/thrownthing) used for when a throw is finished
#define COMSIG_MOVABLE_THROW_LANDED "movable_throw_landed"
///from base of atom/movable/on_changed_z_level(): (turf/old_turf, turf/new_turf)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"
///called when the movable is placed in an unaccessible area, used for stationloving: ()
#define COMSIG_MOVABLE_SECLUDED_LOCATION "movable_secluded"
///from base of atom/movable/Hear(): (proc args list(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list()))
#define COMSIG_MOVABLE_HEAR "movable_hear"
	#define HEARING_MESSAGE 1
	#define HEARING_SPEAKER 2
	#define HEARING_LANGUAGE 3
	#define HEARING_RAW_MESSAGE 4
	/* #define HEARING_RADIO_FREQ 5
	#define HEARING_SPANS 6
	#define HEARING_MESSAGE_MODE 7 */

///called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"
// called when movable is expelled from a disposal pipe, bin or outlet on obj/pipe_eject: (direction)
#define COMSIG_MOVABLE_PIPE_EJECTING "movable_pipe_ejecting"
///called when the movable sucessfully has it's anchored var changed, from base atom/movable/set_anchored(): (value)
#define COMSIG_MOVABLE_SET_ANCHORED "movable_set_anchored"
///from base of atom/movable/setGrabState(): (newstate)
#define COMSIG_MOVABLE_SET_GRAB_STATE "living_set_grab_state"
///Called when the movable tries to change its dynamic light color setting, from base atom/movable/lighting_overlay_set_color(): (color)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_SET_RANGE "movable_light_overlay_set_color"
///Called when the movable tries to change its dynamic light power setting, from base atom/movable/lighting_overlay_set_power(): (power)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_SET_POWER "movable_light_overlay_set_power"
///Called when the movable tries to change its dynamic light range setting, from base atom/movable/lighting_overlay_set_range(): (range)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_SET_COLOR "movable_light_overlay_set_range"
///Called when the movable tries to toggle its dynamic light LIGHTING_ON status, from base atom/movable/lighting_overlay_toggle_on(): (new_state)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_TOGGLE_ON "movable_light_overlay_toggle_on"
///called when the movable's glide size is updated: (new_glide_size)
#define COMSIG_MOVABLE_UPDATE_GLIDE_SIZE "movable_glide_size"
///Called when a movable is hit by a plunger in layer mode, from /obj/item/plunger/attack_atom()
#define COMSIG_MOVABLE_CHANGE_DUCT_LAYER "movable_change_duct_layer"
///Called when a movable is teleported from `do_teleport()`: (destination, channel)
#define COMSIG_MOVABLE_TELEPORTED "movable_teleported"

/// from /mob/living/can_z_move, sent to whatever the mob is buckled to. Only ridable movables should be ridden up or down btw.
#define COMSIG_BUCKLED_CAN_Z_MOVE "ridden_pre_can_z_move"
	#define COMPONENT_RIDDEN_STOP_Z_MOVE 1
	#define COMPONENT_RIDDEN_ALLOW_Z_MOVE 2
