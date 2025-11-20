/datum/ai_planning_subtree/monkey_shenanigans/SelectBehaviors(datum/ai_controller/monkey/controller, seconds_per_tick)

	if(prob(5))
		controller.queue_behavior(/datum/ai_behavior/use_in_hand)

	if(!SPT_PROB(MONKEY_SHENANIGAN_PROB, seconds_per_tick))
		return

	if(!controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET])
		if(controller.blackboard[BB_MONKEY_PRESS_TYPEPATH])
			controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_MONKEY_CURRENT_PRESS_TARGET, controller.blackboard[BB_MONKEY_PRESS_TYPEPATH], 2)
		else
			controller.queue_behavior(/datum/ai_behavior/find_nearby, BB_MONKEY_CURRENT_PRESS_TARGET)
	else if(prob(50))
		controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!controller.blackboard[BB_MONKEY_CURRENT_GIVE_TARGET])
		controller.queue_behavior(/datum/ai_behavior/find_and_set/pawn_must_hold_item, BB_MONKEY_CURRENT_GIVE_TARGET, /mob/living/carbon/human, 2)
	else if(prob(controller.blackboard[BB_MONKEY_GIVE_CHANCE]))
		controller.queue_behavior(/datum/ai_behavior/give, BB_MONKEY_CURRENT_GIVE_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!controller.blackboard[BB_MONKEY_TAMED])
		controller.TryFindWeapon()

///monkey combat subtree.
/datum/ai_planning_subtree/monkey_combat/SelectBehaviors(datum/ai_controller/monkey/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]

	if((HAS_TRAIT(controller.pawn, TRAIT_PACIFISM)) || (!length(enemies) && !controller.blackboard[BB_MONKEY_AGGRESSIVE])) //Pacifist, or we have no enemies and we're not pissed
		living_pawn.set_combat_mode(FALSE)
		return

	if(!controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET])
		controller.queue_behavior(/datum/ai_behavior/monkey_set_combat_target, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_ENEMIES)
		living_pawn.set_combat_mode(FALSE)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/mob/living/selected_enemy = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]

	if(QDELETED(selected_enemy))
		living_pawn.set_combat_mode(FALSE)
		return

	if(!selected_enemy.stat) //He's up, get him!
		if(living_pawn.health < MONKEY_FLEE_HEALTH) //Time to skeddadle
			controller.queue_behavior(/datum/ai_behavior/monkey_flee)
			return SUBTREE_RETURN_FINISH_PLANNING //I'm running fuck you guys

		if(controller.TryFindWeapon()) //Getting a weapon is higher priority if im not fleeing.
			return SUBTREE_RETURN_FINISH_PLANNING

		if(controller.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] < world.time)
			controller.queue_behavior(/datum/ai_behavior/recruit_monkeys, BB_MONKEY_CURRENT_ATTACK_TARGET)
			return

		if(SPT_PROB(ismonkey(living_pawn) ? 25 : 10, seconds_per_tick))
			controller.queue_behavior(/datum/ai_behavior/battle_screech/monkey)
		controller.queue_behavior(/datum/ai_behavior/monkey_attack_mob, BB_MONKEY_CURRENT_ATTACK_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	//by this point we have a target but they're down, let's try dumpstering this loser

	living_pawn.set_combat_mode(FALSE)

	if(!controller.blackboard[BB_MONKEY_TARGET_DISPOSAL])
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_MONKEY_TARGET_DISPOSAL, /obj/machinery/disposal, MONKEY_ENEMY_VISION)
		return

	controller.queue_behavior(/datum/ai_behavior/disposal_mob, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_TARGET_DISPOSAL)
	return SUBTREE_RETURN_FINISH_PLANNING

/// Finds food or drinks, picks them up, then gives them to nearby humans
/datum/ai_planning_subtree/serve_food

/datum/ai_planning_subtree/serve_food/SelectBehaviors(datum/ai_controller/monkey/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_patrons = list()
	for(var/mob/living/carbon/human/human_mob in oview(5, living_pawn))
		if(istype(human_mob.mind?.assigned_role, /datum/job/bartender))
			return //  my boss is on duty!
		if(human_mob.stat != CONSCIOUS || ismonkey(human_mob))
			continue
		if(!human_mob.get_empty_held_indexes())
			continue
		nearby_patrons += human_mob

	// Need at least 2 patrons to bother serving (bearing in mind the
	if(length(nearby_patrons) < 1)
		return

	var/obj/item/serving = controller.blackboard[BB_MONKEY_CURRENT_SERVED_ITEM]
	if(QDELETED(serving) || serving.reagents.total_volume <= 0)
		controller.queue_behavior(/datum/ai_behavior/find_and_set/food_or_drink/to_serve, BB_MONKEY_CURRENT_SERVED_ITEM, /obj/item, 2)
		return

	// we have something to serve, pick a patron and go hand it over
	if(living_pawn.is_holding(serving))
		controller.blackboard[BB_MONKEY_CURRENT_GIVE_TARGET] ||= pick(nearby_patrons)
		controller.queue_behavior(/datum/ai_behavior/give, BB_MONKEY_CURRENT_GIVE_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	// we have something to serve but aren't holding it yet
	if(isturf(serving.loc))
		// fetch the drink
		controller.queue_behavior(/datum/ai_behavior/navigate_to_and_pick_up, BB_MONKEY_CURRENT_SERVED_ITEM, TRUE)
	else
		// give up on the dream
		controller.clear_blackboard_key(BB_MONKEY_CURRENT_SERVED_ITEM)
	return SUBTREE_RETURN_FINISH_PLANNING
