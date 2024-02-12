
#define TORN_WALL_RUINED 2
#define TORN_WALL_DAMAGED 1
#define TORN_WALL_INITIAL 0

/**
 * Component applied to a wall to progressively destroy it.
 * If component is applied to something which already has it, stage increases.
 * Wall is destroyed on third application.
 * Can be fixed using a welder
 */
/datum/component/torn_wall
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/current_stage = TORN_WALL_INITIAL

/datum/component/torn_wall/Initialize()
	. = ..()
	if (!isclosedturf(parent) || isindestructiblewall(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/torn_wall/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welded))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changed))
	apply_visuals()

/datum/component/torn_wall/UnregisterFromParent()
	var/atom/atom_parent = parent
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_TOOL_ACT(TOOL_WELDER),
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_TURF_CHANGE,
	))
	atom_parent.update_appearance(UPDATE_ICON)

/datum/component/torn_wall/InheritComponent(datum/component/C, i_am_original)
	increase_stage()

/// Play a fun animation and make our wall look damaged
/datum/component/torn_wall/proc/apply_visuals()
	var/atom/atom_parent = parent
	playsound(atom_parent, 'sound/effects/bang.ogg', 50, vary = TRUE)
	atom_parent.update_appearance(UPDATE_ICON)
	atom_parent.Shake(shake_interval = 0.1 SECONDS, duration = 0.5 SECONDS)

/// Make the effect more dramatic
/datum/component/torn_wall/proc/increase_stage()
	current_stage++
	if (current_stage != TORN_WALL_RUINED)
		apply_visuals()
		return
	var/turf/closed/wall/attached_wall = parent
	playsound(attached_wall, 'sound/effects/meteorimpact.ogg', 100, vary = TRUE)

	if(ismineralturf(attached_wall))
		var/turf/closed/mineral/mineral_turf = attached_wall
		mineral_turf.gets_drilled()
		return

	attached_wall.dismantle_wall(devastated = TRUE)

/// Fix it up on weld
/datum/component/torn_wall/proc/on_welded(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_repair), source, user, tool)
	return ITEM_INTERACT_BLOCKING

/// Fix us up
/datum/component/torn_wall/proc/try_repair(atom/source, mob/user, obj/item/tool)
	source.balloon_alert(user, "repairing...")
	if(!tool.use_tool(source, user, 5 SECONDS, amount = 2, volume = 50))
		source.balloon_alert(user, "interrupted!")
		return
	current_stage--
	if (current_stage < TORN_WALL_INITIAL)
		qdel(src)
		return
	source.update_appearance(UPDATE_ICON)
	try_repair(source, user, tool) // Keep going

/// Give them a hint
/datum/component/torn_wall/proc/on_examined(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/intensity = (current_stage == TORN_WALL_INITIAL) ? "slightly" : "badly"
	examine_list += span_notice("It looks [intensity] damaged.")
	examine_list += span_info("You may be able to repair it using a welding tool.")

/// Show a little crack on here
/datum/component/torn_wall/proc/on_update_overlays(turf/source, list/overlays)
	SIGNAL_HANDLER
	var/mutable_appearance/crack = mutable_appearance('icons/turf/overlays.dmi', "explodable", source.layer + 0.1)
	if (current_stage == TORN_WALL_INITIAL)
		crack.alpha *= 0.5
	overlays += crack

/// If the wall becomes any other turf, delete us. Transforming into a different works fine as a fix.
/datum/component/torn_wall/proc/on_turf_changed()
	SIGNAL_HANDLER
	qdel(src)

#undef TORN_WALL_RUINED
#undef TORN_WALL_DAMAGED
#undef TORN_WALL_INITIAL
