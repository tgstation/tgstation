/*
 * A component given to mobs that can climb trees
 */
/datum/component/tree_climber
	///the distance to climb up and down
	var/climbing_distance = 20
	///are we on a tree
	var/climbed = FALSE

/datum/component/tree_climber/Initialize(climbing_distance = 20)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.climbing_distance = climbing_distance

/datum/component/tree_climber/RegisterWithParent()
	. = ..()
	RegisterSignals(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_CLIMB_TREE), PROC_REF(climb_tree))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/tree_climber/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_CLIMB_TREE))

/datum/component/tree_climber/proc/climb_tree(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/flora/tree))
		return

	if(!can_climb_tree(target)) //check if another animal is on the tree
		to_chat(source, span_warning("[target] is blocked!"))
		return COMPONENT_HOSTILE_NO_ATTACK

	handle_climb_tree(source)

	if(climbed)
		source.forceMove(get_turf(target))
		RegisterSignal(source, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(climber_moved))
		return COMPONENT_HOSTILE_NO_ATTACK

	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
	var/list/possible_drops = get_adjacent_open_turfs(target)
	for(var/turf/droploc as anything in possible_drops)
		if(!droploc.is_blocked_turf(exclude_mobs = TRUE))
			continue
		possible_drops -= droploc
	if(possible_drops.len)
		source.forceMove(pick(possible_drops))
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/tree_climber/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(climbed)
		examine_text += "It is clinging to a tree!"

/datum/component/tree_climber/proc/can_climb_tree(obj/structure/flora/tree/target)
	if(climbed)
		return TRUE
	var/turf/tree_turf = get_turf(target)
	if(locate(/mob/living) in tree_turf.contents)
		return FALSE
	return TRUE

/datum/component/tree_climber/proc/handle_climb_tree(mob/living/climber)
	var/offset = climbed ? -(climbing_distance) : climbing_distance
	animate(climber, pixel_y = climber.pixel_y + offset, time = 2)
	climbed = !climbed
	climber.Stun(2 SECONDS, ignore_canstun = TRUE)

/datum/component/tree_climber/proc/climber_moved(mob/living/source)
	SIGNAL_HANDLER

	handle_climb_tree(source)
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
