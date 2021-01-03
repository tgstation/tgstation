

///snakes will retreat after biting someone as much as they deserve, since they're not trying to kill you.
/datum/ai_behavior/snake_flee

/datum/ai_behavior/snake_flee/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[BB_SNAKE_CURRENT_RETREAT_TARGET]

	if(!target)
		finish_action(controller, TRUE)
	var/nearby = FALSE
	for(var/mob/living/L in view(living_pawn, 7))
		if(L == target)
			nearby = TRUE

	if(nearby)
		walk_away(living_pawn, target, 7, 8)// we're gonna run from someone we've bitten to satisfaction
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/snake_flee/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	walk(living_pawn, 0)
	controller.blackboard[BB_SNAKE_CURRENT_RETREAT_TARGET] = null

/datum/ai_behavior/snake_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/snake_attack_mob/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/target = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]
	var/mob/living/living_pawn = controller.pawn

	if(!target)
		finish_action(controller, TRUE) // oh well

	if(living_pawn.Adjacent(target) && isturf(target.loc) && !living_pawn.stat)	// if right next to perp

		// revenge bite inc
		snake_bite(controller, target, delta_time)


/datum/ai_behavior/snake_attack_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	walk(living_pawn, 0)
	controller.blackboard[BB_SNAKE_CURRENT_ATTACK_TARGET] = null

/// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/snake_attack_mob/proc/snake_bite(datum/ai_controller/controller, mob/living/target, delta_time)

	var/mob/living/simple_animal/hostile/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return
	living_pawn.changeNext_move(CLICK_CD_MELEE) //We play fair
	living_pawn.face_atom(target)
	living_pawn.AttackingTarget(target)

	//they've taken one bite, so we remove one bite from how many they deserve
	controller.blackboard[BB_SNAKE_ENEMIES][target]--

	// if we think they've gotten the message
	if(controller.blackboard[BB_SNAKE_ENEMIES][target] <= 0)
		var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]
		enemies.Remove(target)
		controller.blackboard[BB_SNAKE_CURRENT_RETREAT_TARGET] = target //lets back away
		if(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] == target)
			finish_action(controller, TRUE)

/datum/ai_behavior/snake_boot
	required_distance = 0

/datum/ai_behavior/snake_boot/perform(delta_time, datum/ai_controller/controller)

	var/mob/living/living_pawn = controller.pawn
	var/obj/item/clothing/shoes/cowboy/target = controller.blackboard[BB_SNAKE_BOOT]

	if(!target)
		finish_action(controller, FALSE)
		return
	if(target.occupants.len > 0)
		finish_action(controller, FALSE)
		return

	living_pawn.visible_message("<span class='warning'>[living_pawn] slithers into [target].")
	living_pawn.forceMove(target)
	target.occupants += living_pawn

	finish_action(controller, TRUE)

//so the snake forgets the boot when it leaves
/datum/ai_behavior/snake_boot/finish_action(datum/ai_controller/snake/controller, success)
	. = ..()
	if(success)
		controller.went_in_boot()
