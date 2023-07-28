/*
 * An element given to mobs that can climb trees
 */
/datum/element/tree_climber
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///the distance to climb up and down
	var/climbing_distance = 20
	///are we on a tree
	var/climbed = FALSE

/datum/element/tree_climber/Attach(datum/target, climbing_distance = 20)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_CLIMB_TREE), PROC_REF(climb_tree))
	src.climbing_distance = climbing_distance

/datum/element/tree_climber/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_CLIMB_TREE))

/// Generates the tree climbing pixel movement effect
/datum/element/tree_climber/proc/climb_tree(mob/living/climber, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/flora/tree))
		return

	if(!can_climb_tree(target)) //check if another animal is on the tree
		to_chat(climber, span_warning("[target] is blocked!"))
		return COMPONENT_HOSTILE_NO_ATTACK

	handle_climb_tree(climber)

	if(climbed)
		climber.forceMove(get_turf(target))
		RegisterSignal(climber, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(climber_moved))
		return COMPONENT_HOSTILE_NO_ATTACK

	UnregisterSignal(climber, COMSIG_MOVABLE_PRE_MOVE)
	var/list/possible_drops = get_adjacent_open_turfs(target)
	for(var/turf/droploc as anything in possible_drops)
		if(!droploc.is_blocked_turf(exclude_mobs = TRUE))
			continue
		possible_drops -= droploc
	if(possible_drops.len)
		climber.forceMove(pick(possible_drops))
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/element/tree_climber/proc/can_climb_tree(obj/structure/flora/tree/target)
	var/turf/tree_turf = get_turf(target)
	if(locate(/mob/living) in tree_turf.contents)
		return FALSE
	return TRUE


/datum/element/tree_climber/proc/handle_climb_tree(mob/living/climber)
	var/offset = climbed ? -(climbing_distance) : climbing_distance
	animate(climber, pixel_y = climber.pixel_y + offset, time = 2)
	climbed = !climbed
	climber.Stun(2 SECONDS, ignore_canstun = TRUE)

/datum/element/tree_climber/proc/climber_moved(mob/source)
	SIGNAL_HANDLER

	handle_climb_tree(source)
	UnregisterSignal(source, COMSIG_MOVABLE_PRE_MOVE)
