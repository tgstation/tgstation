///ACTIONS
/datum/ai_behavior/stop_all_movement/start_execution()
	. = ..()
	walk_to(our_controller.controlled_mob, 0)
	finish_execution(TRUE)

/datum/ai_behavior/try_resist
	regen_plan_after_completion = TRUE

/datum/ai_behavior/try_resist/start_execution()
	. = ..()
	our_controller.controlled_mob.resist()
	addtimer(CALLBACK(src, .proc/finish_execution, TRUE), 1 SECONDS)

/datum/ai_behavior/monkey_random_wander
	requires_processing = TRUE

/datum/ai_behavior/monkey_random_wander/process(delta_time)
	. = ..()
	if(DT_PROB(25, delta_time))
		step(our_controller.controlled_mob, pick(GLOB.cardinals))

/datum/ai_behavior/monkey_random_emote
	requires_processing = TRUE

/datum/ai_behavior/monkey_random_emote/process(delta_time)
	if(DT_PROB(3, delta_time))
		our_controller.controlled_mob.emote(pick("scratch","jump","roll","tail"))

/datum/ai_behavior/battle_screech
	regen_plan_after_completion = TRUE
	var/battle_screech_cooldown = 50
	COOLDOWN_DECLARE(next_battle_screech)

/datum/ai_behavior/battle_screech/start_execution()
	. = ..()
	emote(pick("roar","screech"))
	finish_execution(TRUE)

/datum/ai_behavior/battle_screech/finish_execution()
	. = ..()
	COOLDOWN_START(our_controller, battle_screech_cooldown)


/datum/ai_behavior/monkey_try_equip_item
	var/obj/item/target_item
	var/list/blacklistItems
	var/best_force

/datum/ai_behavior/monkey_try_equip_item/set_action_state(obj/item/I)
	target_item = I

/datum/ai_behavior/try_equip_item/monkey_try_equip_item/start_execution()
	. = ..()

	if(I.loc == our_controller.controlled_mob.src)//Already holding it
		finish_execution(TRUE)

	if(I.anchored) //Can't pick it up, so stop trying.
		LAZYADD(blacklistItems, I)
		finish_execution(FALSE)

	//Sexy fashion (top priority!!)
	if(I.slot_flags)
		dropItemToGround(I, TRUE)
		update_icons()
		if(!equip_to_appropriate_slot(I))
			finish_execution(FALSE) //Already wearing something, in the future this should probably replace the current item but the code didn't actually do that, and I dont want to support it right now.
		finish_execution(TRUE)

	// Strong weapon
	else if(I.force >= best_force)
		our_controller.controlled_mob.put_in_hands(I)
		best_force = I.force
		finish_execution(TRUE)

	// EVERYTHING ELSE
	else if(!our_controller.controlled_mob.get_item_for_held_index(1) || !our_controller.controlled_mob.get_item_for_held_index(2))
		our_controller.controlled_mob.put_in_hands(I)
		finish_execution(TRUE)

	//LAZYADD(blacklistItems, I)
	finish_execution(FALSE)
