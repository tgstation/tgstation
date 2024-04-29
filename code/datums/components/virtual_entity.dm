/// Handles all special considerations for "virtual entities" such as bitrunning ghost roles or digital anomaly antagonists.
/datum/component/virtual_entity
	///The cooldown for balloon alerts, so the player isn't spammed while trying to enter a restricted area.
	COOLDOWN_DECLARE(OOB_cooldown)

/datum/component/virtual_entity/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))

/datum/component/virtual_entity/proc/on_parent_pre_move(atom/movable/source, atom/new_location)
	var/area/location_area = get_area(new_location)
	if(!location_area)
		stack_trace("Virtual entity entered a location with no area!")
		return

	if(location_area.area_flags & VIRTUAL_SAFE_AREA)
		source.balloon_alert(source, "out of bounds!")
		COOLDOWN_START(src, OOB_cooldown, 1 SECONDS)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
