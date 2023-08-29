/datum/ai_behavior/chicken_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/chicken_attack_mob/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()

	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/living_pawn = controller.pawn

	if(!target || target.stat != CONSCIOUS)
		finish_action(controller, TRUE) //we don't want chickens to kill or maybe we do this can be adjusted

	if(isturf(target.loc) && !IS_DEAD_OR_INCAP(living_pawn)) // Check if they're a valid target
		chicken_attack(controller, target, seconds_per_tick, FALSE)

/datum/ai_behavior/chicken_attack_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	SSmove_manager.stop_looping(living_pawn)
	controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null

/// attack using a projectile otherwise unarmed the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/chicken_attack_mob/proc/shoot(atom/targeted_atom, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/atom/target_from = living_pawn
	if(QDELETED(targeted_atom) || targeted_atom == target_from.loc || targeted_atom == target_from )
		return
	var/turf/startloc = get_turf(target_from)
	if(controller.blackboard[BB_CHICKEN_PROJECTILE])
		var/projectile_type = controller.blackboard[BB_CHICKEN_PROJECTILE]
		var/obj/projectile/used_projectile = new projectile_type(startloc)
		used_projectile.starting = startloc
		used_projectile.firer = living_pawn
		used_projectile.fired_from = living_pawn
		used_projectile.yo = targeted_atom.y - startloc.y
		used_projectile.xo = targeted_atom.x - startloc.x
		used_projectile.original = targeted_atom
		used_projectile.preparePixelProjectile(targeted_atom, living_pawn)
		used_projectile.fire()
		return used_projectile

/datum/ai_behavior/chicken_attack_mob/proc/chicken_attack(datum/ai_controller/controller, mob/living/target, seconds_per_tick, disarm)
	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return

	living_pawn.changeNext_move(CLICK_CD_MELEE) //We play fair

	living_pawn.face_atom(target)

	// check for projectile and roll a dice, than fire that bad boy
	if(controller.blackboard[BB_CHICKEN_PROJECTILE] && SPT_PROB(5, seconds_per_tick))
		shoot(target, controller)

	// attack with weapon if we have one (we don't as of now as sword chickens are frauds)
	if(living_pawn.CanReach(target))
		living_pawn.UnarmedAttack(target)

	// no de-aggro
	if(controller.blackboard[BB_CHICKEN_AGGRESSIVE])
		return

	// reduce aggro
	if(SPT_PROB(CHICKEN_HATRED_REDUCTION_PROB, seconds_per_tick))
		controller.blackboard[BB_CHICKEN_SHITLIST][target]--

	// if we are not angry at our target, go back to idle
	if(controller.blackboard[BB_CHICKEN_SHITLIST][target] <= 0)
		var/list/enemies = controller.blackboard[BB_CHICKEN_SHITLIST]
		enemies.Remove(target)
		if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == target)
			finish_action(controller, TRUE)

/datum/ai_behavior/recruit_chickens/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	controller.blackboard[BB_CHICKEN_RECRUIT_COOLDOWN] = world.time + CHICKEN_RECRUIT_COOLDOWN
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/living_viewers in view(living_pawn, CHICKEN_ENEMY_VISION))
		if(!HAS_AI_CONTROLLER_TYPE(living_viewers, /datum/ai_controller/chicken))
			continue

		if(!SPT_PROB(CHICKEN_RECRUIT_PROB, seconds_per_tick))
			continue

		var/datum/ai_controller/chicken/chicken_ai = living_viewers.ai_controller

		var/atom/your_enemy = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
		var/list/enemies = living_viewers.ai_controller.blackboard[BB_CHICKEN_SHITLIST]
		enemies[your_enemy] = CHICKEN_RECRUIT_HATED_AMOUNT
		chicken_ai.blackboard[BB_CHICKEN_RECRUIT_COOLDOWN] = world.time + CHICKEN_RECRUIT_COOLDOWN
	finish_action(controller, TRUE)

/datum/ai_behavior/chicken_flee

/datum/ai_behavior/chicken_flee/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()

	var/mob/living/living_pawn = controller.pawn

	var/mob/living/target = null

	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/viewed_living in view(living_pawn, CHICKEN_FLEE_VISION))
		if(controller.blackboard[BB_CHICKEN_SHITLIST][viewed_living] && viewed_living.stat == CONSCIOUS)
			target = viewed_living
			break

	if(target)
		SSmove_manager.move_away(living_pawn, target, max_dist = CHICKEN_ENEMY_VISION, delay = 5)
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/follow_leader

/datum/ai_behavior/follow_leader/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[BB_CHICKEN_CURRENT_LEADER]

	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]) // they care more about attacking right now
		finish_action(controller, TRUE)
	if(target)
		step_to(living_pawn, target,1)
	else
		finish_action(controller, TRUE)
