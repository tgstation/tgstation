/datum/ai_planning_subtree/monkey_tree/SelectBehaviors(datum/ai_controller/monkey/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && DT_PROB(MONKEY_RESIST_PROB, delta_time))
		controller.queue_behavior(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

	var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]

	if(HAS_TRAIT(controller.pawn, TRAIT_PACIFISM)) //Not a pacifist? lets try some combat behavior.
		return

	var/mob/living/selected_enemy
	if(length(enemies) || controller.blackboard[BB_MONKEY_AGGRESSIVE]) //We have enemies or are pissed
		var/list/valids = list()
		for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, living_pawn))
			if(possible_enemy == living_pawn || (!enemies[possible_enemy] && (!controller.blackboard[BB_MONKEY_AGGRESSIVE] || HAS_AI_CONTROLLER_TYPE(possible_enemy, /datum/ai_controller/monkey)))) //Are they an enemy? (And do we even care?)
				continue
			// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
			valids[possible_enemy] = CEILING(100 / (get_dist(living_pawn, possible_enemy) || 1), 1)

		selected_enemy = pickweight(valids)

		if(selected_enemy)
			if(!selected_enemy.stat) //He's up, get him!
				if(living_pawn.health < MONKEY_FLEE_HEALTH) //Time to skeddadle
					controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					controller.queue_behavior(/datum/ai_behavior/monkey_flee)
					return //I'm running fuck you guys

				if(controller.TryFindWeapon()) //Getting a weapon is higher priority if im not fleeing.
					return SUBTREE_RETURN_FINISH_PLANNING

				controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
				controller.current_movement_target = selected_enemy
				if(controller.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] < world.time)
					controller.queue_behavior(/datum/ai_behavior/recruit_monkeys)
				controller.queue_behavior(/datum/ai_behavior/battle_screech/monkey)
				controller.queue_behavior(/datum/ai_behavior/monkey_attack_mob)
				return SUBTREE_RETURN_FINISH_PLANNING //Focus on this

			else //He's down, can we disposal him?
				var/obj/machinery/disposal/bodyDisposal = locate(/obj/machinery/disposal/) in view(MONKEY_ENEMY_VISION, living_pawn)
				if(bodyDisposal)
					controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					controller.blackboard[BB_MONKEY_TARGET_DISPOSAL] = bodyDisposal
					controller.queue_behavior(/datum/ai_behavior/disposal_mob, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_TARGET_DISPOSAL)
					return SUBTREE_RETURN_FINISH_PLANNING

	if(prob(5))
		controller.queue_behavior(/datum/ai_behavior/use_in_hand)

	if(selected_enemy || !DT_PROB(MONKEY_SHENANIGAN_PROB, delta_time))
		return

	if(world.time >= controller.blackboard[BB_MONKEY_NEXT_HUNGRY])
		var/list/food_candidates = list()
		for(var/obj/item as anything in living_pawn.held_items)
			if(!item || !controller.IsEdible(item))
				continue
			food_candidates += item

		for(var/obj/item/candidate in oview(2, living_pawn))
			if(!controller.IsEdible(candidate))
				continue
			food_candidates += candidate

		if(length(food_candidates))
			var/obj/item/best_held = controller.GetBestWeapon(null, living_pawn.held_items)
			for(var/obj/item/held as anything in living_pawn.held_items)
				if(!held || held == best_held)
					continue
				living_pawn.dropItemToGround(held)

			controller.queue_behavior(/datum/ai_behavior/consume, pick(food_candidates))
			return

	if(prob(50))
		var/list/possible_targets = list()
		for(var/atom/thing in view(2, living_pawn))
			if(!thing.mouse_opacity)
				continue
			if(thing.IsObscured())
				continue
			possible_targets += thing
		var/atom/target = pick(possible_targets)
		if(target)
			controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET] = target
			controller.queue_behavior(/datum/ai_behavior/use_on_object, BB_MONKEY_CURRENT_PRESS_TARGET)
			return

	if(prob(5) && (locate(/obj/item) in living_pawn.held_items))
		var/list/possible_receivers = list()
		for(var/mob/living/candidate in oview(2, controller.pawn))
			possible_receivers += candidate

		if(length(possible_receivers))
			controller.blackboard[BB_MONKEY_CURRENT_GIVE_TARGET] = pick(possible_receivers)
			controller.queue_behavior(/datum/ai_behavior/give, BB_MONKEY_CURRENT_GIVE_TARGET)
			return

	controller.TryFindWeapon()
