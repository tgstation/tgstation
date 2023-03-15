/datum/ai_behavior/revolution

/datum/ai_behavior/revolution/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	var/list/viable_conversions = list()
	for(var/mob/living/simple_animal/chicken/found_chicken in view(4, living_pawn.loc))
		if(!istype(found_chicken, /mob/living/simple_animal/chicken/rev_raptor) || !istype(found_chicken, /mob/living/simple_animal/chicken/raptor))
			viable_conversions |= found_chicken
	var/mob/living/simple_animal/chicken/conversion_target = pick(viable_conversions)

	SSmove_manager.hostile_jps_move(living_pawn, conversion_target, 2, minimum_distance = 1)

	if(living_pawn.CanReach(conversion_target))
		new /mob/living/simple_animal/chicken/raptor(conversion_target.loc)
		qdel(conversion_target)
		living_pawn.say("VIVA, BAWK!")
		controller.blackboard[BB_CHICKEN_ABILITY_COOLDOWN] = world.time + 10 SECONDS
		SSmove_manager.stop_looping(living_pawn) // since we added gotta also remove
		finish_action(controller, TRUE)

/datum/ai_behavior/chicken_honk_target

/datum/ai_behavior/chicken_honk_target/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(controller.blackboard[BB_CHICKEN_HONKS_SORROW])
		var/list/clucking_mad = list()
		for(var/mob/living/carbon/human/unlucky in GLOB.player_list)
			clucking_mad |= unlucky
		controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET] = pick(clucking_mad)
		clucking_mad = null
	else
		var/list/pick_me = list()
		for(var/mob/living/carbon/human/target in view(living_pawn, CHICKEN_ENEMY_VISION))
			pick_me |= target
		if(pick_me.len)
			controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET] = pick(pick_me)
	finish_action(controller, TRUE)

/datum/ai_behavior/chicken_honk_target/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if(controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET])
		controller.queue_behavior(/datum/ai_behavior/chicken_honk)

/datum/ai_behavior/chicken_honk

/datum/ai_behavior/chicken_honk/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/chicken/living_pawn = controller.pawn
	controller.blackboard[BB_CHICKEN_ABILITY_COOLDOWN] = world.time + living_pawn.cooldown_time
	var/mob/living/target = controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET]

	if(living_pawn.next_move > world.time)
		return

	if(DT_PROB(10, delta_time) && controller.blackboard[BB_CHICKEN_HONKS_SORROW])
		living_pawn.apply_status_effect(ANGRY_HONK_SPEED)

	living_pawn.changeNext_move(CLICK_CD_MELEE) //We play fair

	living_pawn.face_atom(target)

	// forcing the move here because we aren't in hostile mode so we don't manually trigger hostile_jps
	SSmove_manager.hostile_jps_move(living_pawn, target, 2, minimum_distance = 1)

	living_pawn.a_intent = INTENT_HARM // not really lol but i wanna attach a slip to it

	// honk the bastard
	if(living_pawn.CanReach(target))
		living_pawn.UnarmedAttack(target)
		target.slip(5 SECONDS, FALSE)

		if(controller.blackboard[BB_CHICKEN_HONKS_SORROW])
			living_pawn.emote("cries")

		living_pawn.a_intent = INTENT_HELP

		SSmove_manager.stop_looping(living_pawn) // since we added gotta also remove

		if(!controller.blackboard[BB_CHICKEN_HONKS_SORROW]) // these fucks don't forget
			controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET] = null

		controller.queue_behavior(/datum/ai_behavior/chicken_flee)
		finish_action(controller, TRUE)

/datum/ai_behavior/sugar_rush

/datum/ai_behavior/sugar_rush/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/simple_animal/chicken/living_pawn = controller.pawn
	living_pawn.apply_status_effect(HEN_RUSH)
	controller.blackboard[BB_CHICKEN_ABILITY_COOLDOWN] = world.time + living_pawn.cooldown_time
	finish_action(controller, TRUE)
