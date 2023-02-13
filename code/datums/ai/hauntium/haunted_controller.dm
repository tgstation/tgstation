
/datum/ai_controller/haunted
	movement_delay = 0.4 SECONDS
	blackboard = list(
		BB_TO_HAUNT_LIST = list(),
		BB_LIKES_EQUIPPER = FALSE,
		BB_HAUNT_TARGET,
		BB_HAUNTED_THROW_ATTEMPT_COUNT,
	)
	planning_subtrees = list(/datum/ai_planning_subtree/haunted)
	idle_behavior = /datum/idle_behavior/idle_ghost_item

/datum/ai_controller/haunted/TryPossessPawn(atom/new_pawn)
	if(!isitem(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	return ..() //Run parent at end

/datum/ai_controller/haunted/UnpossessPawn()
	UnregisterSignal(pawn, COMSIG_ITEM_EQUIPPED)
	return ..() //Run parent at end

///Signal response for when the item is picked up; stops listening for follow up equips, just waits for a drop.
/datum/ai_controller/haunted/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	UnregisterSignal(pawn, COMSIG_ITEM_EQUIPPED)
	var/haunt_equipper = TRUE
	if(isliving(equipper))
		var/mob/living/possibly_cool = equipper
		if(possibly_cool.mob_biotypes & MOB_UNDEAD)
			haunt_equipper = FALSE
	if(haunt_equipper)
		//You have now become one of the victims of the HAAAAUNTTIIIINNGGG OOOOOO~~~
		blackboard[BB_TO_HAUNT_LIST][WEAKREF(equipper)] += HAUNTED_ITEM_AGGRO_ADDITION
	else
		blackboard[BB_LIKES_EQUIPPER] = TRUE

	RegisterSignal(pawn, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

///Flip it so we listen for equip again but not for drop.
/datum/ai_controller/haunted/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER

	RegisterSignal(pawn, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	blackboard[BB_LIKES_EQUIPPER] = FALSE
	UnregisterSignal(pawn, COMSIG_ITEM_DROPPED)
