

/datum/ai_behavior/resist/perform_action(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.resist()
	return TRUE

/datum/ai_behavior/battle_screech
	var/battle_screech_cooldown = 50

/datum/ai_behavior/battle_screech/perform_action(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.emote(pick("roar","screech"))
	return TRUE

/datum/ai_behavior/monkey_equip
	required_distance = 1
	var/target_item_key = BB_MONKEY_PICKUPTARGET
	var/blacklistItems_key = BB_MONKEY_BLACKLISTITEMS
	var/best_force_key = BB_MONKEY_BEST_FORCE_FOUND

/datum/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn

	var/obj/item/target = controller.blackboard[target_item_key]
	var/list/item_blacklist = controller.blackboard[blacklistItems_key]
	var/best_force = controller.blackboard[best_force_key]

	if(!target)
		return TRUE

	if(target.anchored) //Can't pick it up, so stop trying.
		item_blacklist[target] = TRUE
		return TRUE //finish the action

	if(target.slot_flags) //Clothing == top priority
		living_pawn.dropItemToGround(target, TRUE)
		living_pawn.update_icons()
		if(!living_pawn.equip_to_appropriate_slot(target))
			item_blacklist[target] = TRUE
			return TRUE //Already wearing something, in the future this should probably replace the current item but the code didn't actually do that, and I dont want to support it right now.
		return TRUE

	// Strong weapon
	else if(target.force >= best_force)
		living_pawn.put_in_hands(target)
		controller.blackboard[best_force_key] = target.force
		controller.blackboard[target_item_key] = null
		return TRUE

	// EVERYTHING ELSE
	else if(!living_pawn.get_item_for_held_index(1) || !living_pawn.get_item_for_held_index(2))
		living_pawn.put_in_hands(target)
		controller.blackboard[target_item_key] = null
		return TRUE

	item_blacklist[target] = TRUE
	return TRUE

/datum/ai_behavior/monkey_equip/ground
	required_distance = 0

/datum/ai_behavior/monkey_equip/ground/perform_action(delta_time, datum/ai_controller/controller)
	equip_item(controller)

/datum/ai_behavior/monkey_equip/pickpocket
	var/pickpocketing_key = BB_MONKEY_PICKPOCKETING

/datum/ai_behavior/monkey_equip/pickpocket/perform_action(delta_time, datum/ai_controller/controller)

	if(controller.blackboard[pickpocketing_key]) //We are pickpocketing, don't do ANYTHING!!!!
		return FALSE
	INVOKE_ASYNC(src, .proc/attempt_pickpocket, controller)

/datum/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[target_item_key]

	var/mob/living/victim = target.loc

	var/mob/living/living_pawn = controller.pawn

	victim.visible_message("<span class='warning'>[living_pawn] starts trying to take [target] from [controller.current_movement_target]!</span>", "<span class='danger'>[living_pawn] tries to take [target]!</span>")

	controller.blackboard[pickpocketing_key] = TRUE

	if(do_mob(living_pawn, victim, MONKEY_ITEM_SNATCH_DELAY) && target)

		for(var/obj/item/I in victim.held_items)
			if(I == target)
				victim.visible_message("<span class='danger'>[living_pawn] snatches [target] from [victim].</span>", "<span class='userdanger'>[living_pawn] snatched [target]!</span>")
				if(victim.temporarilyRemoveItemFromInventory(target))
					if(!QDELETED(target) && !equip_item(controller))
						target.forceMove(living_pawn.drop_location())
				else
					victim.visible_message("<span class='danger'>[living_pawn] tried to snatch [target] from [victim], but failed!</span>", "<span class='userdanger'>[living_pawn] tried to grab [target]!</span>")

	controller.blackboard[pickpocketing_key] = FALSE
	controller.blackboard[target_item_key] = null

	finish_action(controller) //We either fucked up or got the item.

