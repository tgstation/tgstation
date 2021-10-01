/**
 * Item Ghost Resist Subtree
 *
 * Requires at least an item. Hooks into equip and listens for being picked up.
 * Saves people who pick up the item as targets, and plans resisting if they are
 * held. Ghost themed, yay!
 *
 * relevant blackboards:
 * * BB_LIKES_EQUIPPER - set by this subtree, makes the subtree not plan to resist if `TRUE`
 * * BB_ITEM_AGGRO_LIST - set by this subtree, assoc list of targets this behavior populates
 */
/datum/ai_planning_subtree/item_ghost_resist

/datum/ai_planning_subtree/item_ghost_resist/SetupSubtree(datum/ai_controller/controller)
	RegisterSignal(controller.pawn, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	controller.blackboard[BB_LIKES_EQUIPPER] = FALSE
	controller.blackboard[BB_ITEM_AGGRO_LIST] = list()

/datum/ai_planning_subtree/item_ghost_resist/ForgetSubtree(datum/ai_controller/controller)
	UnregisterSignal(controller.pawn, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

///Signal response for when the item is picked up; stops listening for follow up equips, just waits for a drop.
/datum/ai_planning_subtree/item_ghost_resist/proc/on_equip(obj/item/pawn, mob/equipper, slot)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = pawn.ai_controller

	UnregisterSignal(pawn, COMSIG_ITEM_EQUIPPED)
	var/should_haunt_equipper = TRUE
	if(isliving(equipper))
		var/mob/living/possibly_cool = equipper
		if(possibly_cool.mob_biotypes & MOB_UNDEAD)
			should_haunt_equipper = FALSE
	if(!should_haunt_equipper)
		controller.blackboard[BB_LIKES_EQUIPPER] = TRUE
	else
		var/list/hauntee_list = controller.blackboard[BB_ITEM_AGGRO_LIST]
		hauntee_list[equipper] = hauntee_list[equipper] + controller.blackboard[BB_ITEM_AGGRO_ADDITION] //You have now become one of the victims of the HAAAAUNTTIIIINNGGG OOOOOO~~~
	RegisterSignal(pawn, COMSIG_ITEM_DROPPED, .proc/on_dropped)

///Flip it so we listen for equip again but not for drop.
/datum/ai_planning_subtree/item_ghost_resist/proc/on_dropped(obj/item/pawn, mob/dropper)
	SIGNAL_HANDLER

	var/datum/ai_controller/controller = pawn.ai_controller

	RegisterSignal(pawn, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	controller.blackboard[BB_LIKES_EQUIPPER] = FALSE
	UnregisterSignal(pawn, COMSIG_ITEM_DROPPED)

/datum/ai_planning_subtree/item_ghost_resist/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn

	if(ismob(item_pawn.loc)) //We're being held, maybe escape?
		. = SUBTREE_RETURN_FINISH_PLANNING //no matter what, we can't really act further from this position
		if(controller.blackboard[BB_LIKES_EQUIPPER])//don't unequip from people it's okay with
			return
		if(DT_PROB(HAUNTED_ITEM_ESCAPE_GRASP_CHANCE, delta_time))
			controller.queue_behavior(/datum/ai_behavior/item_escape_grasp)

/**
 * Item Target From Aggro List Subtree
 *
 * Requires at least an item, and another subtree to assign aggro to the `BB_ITEM_AGGRO_LIST`.
 *
 * relevant blackboards:
 * * BB_ITEM_AGGRO_LIST - not set by this subtree, assoc list of targets
 * * BB_ITEM_TARGET - set by this subtree, target mob we're attacking
 */
/datum/ai_planning_subtree/item_target_from_aggro_list
	var/list/aggro_list = controller.blackboard[BB_ITEM_AGGRO_LIST]

	for(var/mob/potential_target as anything in aggro_list)
		if(aggro_list[potential_target] <= 0)
			continue
		if(get_dist(potential_target, item_pawn) <= ITEM_AGGRO_VIEW_RANGE)
			controller.blackboard[BB_ITEM_TARGET] = potential_target

/**
 * Item Throw Attack Subtree
 *
 * Requires at least an item, and another subtree to assign a target
 * Attacks
 *
 * relevant blackboards:
 * * BB_ITEM_AGGRO_LIST - not set by this subtree, assoc list of targets
 * * BB_ITEM_TARGET - not set by this subtree, target mob we're attacking
 */
/datum/ai_planning_subtree/item_throw_attack

/datum/ai_planning_subtree/item_throw_attack/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn

	if(!controller.blackboard[BB_ITEM_TARGET] || !DT_PROB(ITEM_AGGRO_ATTACK_CHANCE, delta_time))
		return //no target, or didn't aggro

	controller.queue_behavior(controller.blackboard[BB_ITEM_MOVE_AND_ATTACK_TYPE], BB_ITEM_TARGET, BB_ITEM_THROW_ATTEMPT_COUNT)
	return SUBTREE_RETURN_FINISH_PLANNING
