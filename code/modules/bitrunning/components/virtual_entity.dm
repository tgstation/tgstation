/// Handles all special considerations for "virtual entities" such as bitrunning ghost roles or digital anomaly antagonists.
/datum/component/virtual_entity
	///The cooldown for balloon alerts, so the player isn't spammed while trying to enter a restricted area.
	COOLDOWN_DECLARE(OOB_cooldown)

/datum/component/virtual_entity/Initialize()
	. = ..()

	for(var/obj/machinery/quantum_server/server in SSmachines.get_machines_by_type(/obj/machinery/quantum_server))
		if(server.obj_flags & EMAGGED)
			jailbreak_mobs() //This just sends a message and self-deletes, a bit messy but it works.
			return

	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))
	RegisterSignal(parent, COMSIG_BITRUNNER_SERVER_EMAGGED, PROC_REF(jailbreak_mobs))

///Prevents entry to a certain area if it has flags preventing virtual entities from entering.
/datum/component/virtual_entity/proc/on_parent_pre_move(atom/movable/source, atom/new_location)
	SIGNAL_HANDLER

	var/area/location_area = get_area(new_location)
	if(!location_area)
		stack_trace("Virtual entity entered a location with no area!")
		return

	if(location_area.area_flags & VIRTUAL_SAFE_AREA)
		source.balloon_alert(source, "out of bounds!")
		COOLDOWN_START(src, OOB_cooldown, 2 SECONDS)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

///Self-destructs the component, allowing free-roam by all entities with this restriction.
/datum/component/virtual_entity/proc/jailbreak_mobs()
	SIGNAL_HANDLER

	to_chat(parent, span_big("You shiver for a moment, then suddenly feel a sense of clarity you haven't felt before. \
		You can go anywhere, do anything! You could leave this simulation right now if you wanted!"))
	qdel(src)
