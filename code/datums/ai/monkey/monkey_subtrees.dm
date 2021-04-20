///a monkey in a tree, how fitting. Currently hardcoded to monkey controllers, should become as modular as possible in the future.
/datum/ai_planning_subtree/monkey_tree/SelectBehaviors(datum/ai_controller/monkey/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn

	if(SHOULD_RESIST(living_pawn) && DT_PROB(MONKEY_RESIST_PROB, delta_time))
		controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return SUBTREE_RETURN_FINISH_PLANNING //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

	var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]

	if(!HAS_TRAIT(controller.pawn, TRAIT_PACIFISM) && (length(enemies) || controller.blackboard[BB_MONKEY_AGRESSIVE])) //We have enemies or are pissed

		var/mob/living/selected_enemy

		for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, living_pawn))
			if(possible_enemy == living_pawn || (!enemies[possible_enemy] && (!controller.blackboard[BB_MONKEY_AGRESSIVE] || HAS_AI_CONTROLLER_TYPE(possible_enemy, /datum/ai_controller/monkey)))) //Are they an enemy? (And do we even care?)
				continue

			selected_enemy = possible_enemy
			break
		if(selected_enemy)
			if(!selected_enemy.stat) //He's up, get him!
				if(living_pawn.health < MONKEY_FLEE_HEALTH) //Time to skeddadle
					controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_flee)
					return //I'm running fuck you guys

				if(controller.TryFindWeapon()) //Getting a weapon is higher priority if im not fleeing.
					return SUBTREE_RETURN_FINISH_PLANNING

				controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
				controller.current_movement_target = selected_enemy
				if(controller.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] < world.time)
					controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/recruit_monkeys)
				controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/battle_screech/monkey)
				controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_attack_mob)
				return SUBTREE_RETURN_FINISH_PLANNING

			else //He's down, can we disposal him?
				var/obj/machinery/disposal/bodyDisposal = locate(/obj/machinery/disposal/) in view(MONKEY_ENEMY_VISION, living_pawn)
				if(bodyDisposal)
					controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					controller.blackboard[BB_MONKEY_TARGET_DISPOSAL] = bodyDisposal
					controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/disposal_mob)
					return SUBTREE_RETURN_FINISH_PLANNING

			return SUBTREE_RETURN_FINISH_PLANNING //Too busy fighting to steal atm.

	else if(DT_PROB(MONKEY_SHENANIGAN_PROB, delta_time))
		if(controller.TryFindWeapon()) //Found a better weapon, let's grab it first.
			return SUBTREE_RETURN_FINISH_PLANNING
