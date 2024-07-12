// Main atom signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom signals
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization and has a loc
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON "atom_init_success_on"
///from base of atom/examine(): (/mob, list/examine_text)
#define COMSIG_ATOM_EXAMINE "atom_examine"
///from base of atom/get_examine_name(): (/mob, list/overrides)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE 1
	#define EXAMINE_POSITION_BEFORE 2
	#define EXAMINE_POSITION_NAME 3
///from base of atom/examine(): (/mob, list/examine_text, can_see_inside)
#define COMSIG_ATOM_REAGENT_EXAMINE "atom_reagent_examine"
	/// Stop the generic reagent examine text
	#define STOP_GENERIC_REAGENT_EXAMINE (1<<0)
	/// Allows the generic reaegent examine text regardless of whether the user can scan reagents.
	#define ALLOW_GENERIC_REAGENT_EXAMINE (1<<1)
///from base of atom/examine_more(): (/mob, examine_list)
#define COMSIG_ATOM_EXAMINE_MORE "atom_examine_more"
/// from atom/examine_more(): (/atom/examining, examine_list)
#define COMSIG_MOB_EXAMINING_MORE "mob_examining_more"
///from base of [/atom/proc/update_appearance]: (updates)
#define COMSIG_ATOM_UPDATE_APPEARANCE "atom_update_appearance"
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its name.
	#define COMSIG_ATOM_NO_UPDATE_NAME UPDATE_NAME
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its desc.
	#define COMSIG_ATOM_NO_UPDATE_DESC UPDATE_DESC
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its icon.
	#define COMSIG_ATOM_NO_UPDATE_ICON UPDATE_ICON
///from base of [/atom/proc/update_name]: (updates)
#define COMSIG_ATOM_UPDATE_NAME "atom_update_name"
///from base of [/atom/proc/update_desc]: (updates)
#define COMSIG_ATOM_UPDATE_DESC "atom_update_desc"
///from base of [/atom/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its icon state.
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE UPDATE_ICON_STATE
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its overlays.
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS UPDATE_OVERLAYS
///from base of [atom/update_inhand_icon]: (/mob)
#define COMSIG_ATOM_UPDATE_INHAND_ICON "atom_update_inhand_icon"
///from base of [atom/update_icon_state]: ()
#define COMSIG_ATOM_UPDATE_ICON_STATE "atom_update_icon_state"
///from base of [/atom/update_overlays]: (list/new_overlays)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"
///from base of [/atom/update_icon]: (signalOut, did_anything)
#define COMSIG_ATOM_UPDATED_ICON "atom_updated_icon"
///from base of [/atom/proc/smooth_icon]: ()
#define COMSIG_ATOM_SMOOTHED_ICON "atom_smoothed_icon"
///from [/datum/controller/subsystem/processing/dcs/proc/rotate_decals]: (list/datum/element/decal/rotating)
#define COMSIG_ATOM_DECALS_ROTATING "atom_decals_rotating"
///from base of atom/Entered(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERED "atom_entered"
///from base of atom/movable/Moved(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ABSTRACT_ENTERED "atom_abstract_entered"
/// Sent from the atom that just Entered src. From base of atom/Entered(): (/atom/destination, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERING "atom_entering"
///from base of atom/Exit(): (/atom/movable/leaving, direction)
#define COMSIG_ATOM_EXIT "atom_exit"
	#define COMPONENT_ATOM_BLOCK_EXIT (1<<0)
///from base of atom/Exited(): (atom/movable/gone, direction)
#define COMSIG_ATOM_EXITED "atom_exited"
///from base of atom/movable/Moved(): (atom/movable/gone, direction)
#define COMSIG_ATOM_ABSTRACT_EXITED "atom_abstract_exited"
///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_BUMPED "atom_bumped"
///from base of atom/has_gravity(): (turf/location, list/forced_gravities)
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"
///from internal loop in atom/movable/proc/CanReach(): (list/next)
#define COMSIG_ATOM_CANREACH "atom_can_reach"
	#define COMPONENT_ALLOW_REACH (1<<0)
///for when an atom has been created through processing (atom/original_atom, list/chosen_processing_option)
#define COMSIG_ATOM_CREATEDBY_PROCESSING "atom_createdby_processing"
///when an atom is processed (mob/living/user, obj/item/process_item, list/atom/results)
#define COMSIG_ATOM_PROCESSED "atom_processed"
///called when teleporting into a possibly protected turf: (channel, turf/origin, turf/destination)
#define COMSIG_ATOM_INTERCEPT_TELEPORTING "intercept_teleporting"
///called after teleporting into a protected turf: (channel, turf/origin)
#define COMSIG_ATOM_INTERCEPT_TELEPORTED "intercept_teleported"
	#define COMPONENT_BLOCK_TELEPORT (1<<0)
///called when an atom is added to the hearers on get_hearers_in_view(): (list/processing_list, list/hearers)
#define COMSIG_ATOM_HEARER_IN_VIEW "atom_hearer_in_view"
///called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"
///called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"
///from base of atom/set_opacity(): (new_opacity)
#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"
///from base of atom/throw_impact, sent by the target hit by a thrown object. (hit_atom, thrown_atom, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_PREHITBY "atom_pre_hitby"
	#define COMSIG_HIT_PREVENTED (1<<0)
///from base of atom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_HITBY "atom_hitby"
///when an atom starts playing a song datum (datum/song)
#define COMSIG_ATOM_STARTING_INSTRUMENT "atom_starting_instrument"

///When the transform or an atom is varedited through vv topic.
#define COMSIG_ATOM_VV_MODIFY_TRANSFORM "atom_vv_modify_transform"

/// generally called before temporary non-parallel animate()s on the atom (animation_duration)
#define COMSIG_ATOM_TEMPORARY_ANIMATION_START "atom_temp_animate_start"

/// called on [/obj/item/lazarus_injector/afterattack] : (injector, user)
#define COMSIG_ATOM_ON_LAZARUS_INJECTOR "atom_on_lazarus_injector"
	#define LAZARUS_INJECTOR_USED (1<<0) //Early return.

/// from internal loop in /atom/proc/propagate_radiation_pulse: (atom/pulse_source)
#define COMSIG_ATOM_PROPAGATE_RAD_PULSE "atom_propagate_radiation_pulse"
/// from cosmetic items to restyle certain mobs, objects or organs: (atom/source, mob/living/trimmer, atom/movable/original_target, body_zone, restyle_type, style_speed)
#define COMSIG_ATOM_RESTYLE "atom_restyle"
/// when a timestop ability is used on the atom: (datum/proximity_monitor/advanced/timestop)
#define COMSIG_ATOM_TIMESTOP_FREEZE "atom_timestop_freeze"
/// when the timestop ability effect ends on the atom: (datum/proximity_monitor/advanced/timestop)
#define COMSIG_ATOM_TIMESTOP_UNFREEZE "atom_timestop_unfreeze"

/// Called on [/atom/SpinAnimation()] : (speed, loops, segments, angle)
#define COMSIG_ATOM_SPIN_ANIMATION "atom_spin_animation"

/// when atom falls onto the floor and become exposed to germs: (datum/component/germ_exposure)
#define COMSIG_ATOM_GERM_EXPOSED "atom_germ_exposed"
/// when atom is picked up from the floor or moved to an elevated structure: (datum/component/germ_exposure)
#define COMSIG_ATOM_GERM_UNEXPOSED "atom_germ_unexposed"
/// signal sent to puzzle pieces by activator
#define COMSIG_PUZZLE_COMPLETED "puzzle_completed"

/// From /datum/compomnent/cleaner/clean()
#define COMSIG_ATOM_PRE_CLEAN "atom_pre_clean"
	///cancel clean
	#define COMSIG_ATOM_CANCEL_CLEAN (1<<0)

/// From /obj/item/stack/make_item()
#define COMSIG_ATOM_CONSTRUCTED "atom_constructed"

/// From /obj/effect/particle_effect/sparks/proc/sparks_touched(datum/source, atom/movable/singed)
#define COMSIG_ATOM_TOUCHED_SPARKS "atom_touched_sparks"
#define COMSIG_ATOM_TOUCHED_HAZARDOUS_SPARKS "atom_touched_hazardous_sparks"
