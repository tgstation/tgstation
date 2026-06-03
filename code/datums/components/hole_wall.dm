#define HOLED_WALL_HOLE 2
#define HOLED_WALL_DAMAGED 1
#define HOLED_WALL_INITIAL 0

/**
 * Component(which is child of /datum/component/torn_wall) applied to a wall to make a hole in it.
 * If component is applied to something which already has it, stage increases.
 * Wall will get the hole on third application.
 * Can be fixed using a welder
 */
/datum/component/hole_wall
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/current_stage = HOLED_WALL_INITIAL

	var/atom/dir_for_hole = 1

	var/atom/dir_of_tearer = 1

/datum/component/hole_wall/torn_wall_hole/Initialize(current_stage, dir_of_tearer = 1)
	. = ..()
	if (!isclosedturf(parent) || isindestructiblewall(parent))
		return COMPONENT_INCOMPATIBLE
	src.current_stage = current_stage || src.current_stage
	src.dir_for_hole = dir_of_tearer

/datum/component/hole_wall/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welded))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changed))
	apply_visuals()

/datum/component/hole_wall/UnregisterFromParent()
	var/atom/atom_parent = parent
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_TOOL_ACT(TOOL_WELDER),
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_TURF_CHANGE,
	))
	atom_parent.update_appearance(UPDATE_ICON)

/datum/component/hole_wall/InheritComponent(datum/component/C, i_am_original)
	increase_stage()

/// Play a fun animation and make our wall look damaged, same as torn wall component
/datum/component/hole_wall/proc/apply_visuals()
	var/atom/atom_parent = parent
	playsound(atom_parent, 'sound/effects/bang.ogg', 50, vary = TRUE)
	atom_parent.update_appearance(UPDATE_ICON)
	atom_parent.Shake(shake_interval = 0.1 SECONDS, duration = 0.5 SECONDS)

/// Make the effect more dramatic
/datum/component/hole_wall/proc/increase_stage()
	current_stage++
	if (current_stage != HOLED_WALL_HOLE)
		apply_visuals()
		return
	var/turf/closed/wall/attached_wall = parent
	playsound(attached_wall, 'sound/effects/meteorimpact.ogg', 100, vary = TRUE)

	message_admins("so, hole appeared?")

	if(ismineralturf(attached_wall))
		var/turf/closed/mineral/mineral_turf = attached_wall
		mineral_turf.gets_drilled()
		return

	attached_wall.dismantle_wall(devastated = TRUE)

/// Give them a hint
/datum/component/hole_wall/proc/on_examined(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/intensity = (current_stage == TORN_WALL_INITIAL) ? "slightly" : "badly"
	examine_list += span_notice("It looks [intensity] damaged.")
	examine_list += span_info("You may be able to repair it using a welding tool.")

#undef HOLED_WALL_HOLE
#undef HOLED_WALL_DAMAGED
#undef HOLED_WALL_INITIAL
