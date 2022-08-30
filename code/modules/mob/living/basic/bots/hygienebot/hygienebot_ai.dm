/datum/ai_controller/basic_controller/bot/hygiene
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/hygienebot(),
		BB_HYGIENE_BOT_TARGET = null,
		BB_HYGIENE_BOT_ANGRY = FALSE,
		BB_HYGIENE_BOT_PATIENCE = 0,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/chase_filthy_person,
		/datum/ai_planning_subtree/core_bot_behavior/watch_for_filthy_person,
		/datum/ai_planning_subtree/watch_for_filthy_person_idle,
		)


///Also look for filthy people while patrolling!
/datum/ai_planning_subtree/core_bot_behaviors/watch_for_filthy_person/PatrolBehavior(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/move_to_next_patrol_point)
	controller.queue_behavior(/datum/ai_behavior/find_filthy_person)

///If we're not patrolling still keep an eye out!
/datum/ai_planning_subtree/watch_for_filthy_person_idle/SelectBehaviors(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/find_filthy_person/idle)

///Patrol and look for dirty people in the meantime
/datum/ai_behavior/find_filthy_person
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM
	action_cooldown = 1 SECONDS

/datum/ai_behavior/find_filthy_person/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	var/mob/living/basic/bot/basic_bot = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	for(var/mob/living/carbon/human/nearby_human in view(7,src)) //Find potential filthy people
		if(targetting_datum.can_attack(basic_bot, nearby_human)) //They're a valid target for us
			controller.blackboard[target_key] = nearby_human
			basic_bot.speak("Unhygienic client found. Please stand still so I can clean you.")
			visible_message("<b>[basic_bot]</b> points at [nearby_human.name]!")
			break

	///Gets cancelled if patrol is cancelled

///Stupid override, this one does need to finish properly
/datum/ai_behavior/find_filthy_person/idle

/datum/ai_behavior/find_filthy_person/idle/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	finish_action(controller, TRUE)


///Actually chase the person we spotted!
/datum/ai_planning_subtree/core_bot_behaviors/chase_filthy_person


/datum/ai_planning_subtree/core_bot_behaviors/chase_filthy_person/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(!controller.blackboard[BB_HYGIENE_BOT_TARGET]) //No target yet!
		return
	var/mob/living/basic/bot/controlled_bot = controller.pawn
	if(controlled_bot.bot_cover_flags & BOT_COVER_EMAGGED)
		controller.blackboard[BB_HYGIENE_BOT_ANGRY] = TRUE ///Always angry if emagged!

	if(controller.blackboard[BB_HYGIENE_BOT_ANGRY])
		controller.queue_behavior(/datum/ai_behavior/chase_filthy_person/angry)
	else
		controller.queue_behavior(/datum/ai_behavior/chase_filthy_person)

/datum/ai_behavior/chase_filthy_person
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0
	action_cooldown = 1 SECONDS
	///How long before hygiene bot gives up, -1 for infinite
	var/starting_patience = 8
	///Speed at which to chase player at, overriden by emag
	var/chase_speed = 1
	///List of lines to say when finished
	var/list/finished_lines = list("Enjoy your clean and tidy day!")
	///List of random lines to say when chasing
	var/list/chase_lines = list()
	///Chance of chase line every second
	var/chase_line_prob = 15

/datum/ai_behavior/chase_filthy_person/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	if(starting_patience > 0)
		controller.blackboard[BB_HYGIENE_BOT_PATIENCE] = starting_patience
	else
		controller.blackboard[BB_HYGIENE_BOT_PATIENCE] = INFINITY
	var/mob/living/basic/bot/hygiene/hygiene_bot = controller.pawn
	hygiene_bot.start_washing()

	if(!(hygiene_bot.bot_cover_flags & BOT_COVER_EMAGGED)) ///If we're emagged dont set speed here
		hygiene_bot.set_mob_speed(chase_speed)

/datum/ai_behavior/chase_filthy_person/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	var/mob/living/basic/bot/basic_bot = controller.pawn
	var/mob/mob_target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum.can_attack(basic_bot, mob_target))
		finish_action(controller, TRUE) //They're either clean or invisible, either way no longer our problem

	if(chase_lines.len && DT_PROB_RATE(chase_line_prob, delta_time))
		basic_bot.speak(pick(chase_lines))

	controller.blackboard[BB_HYGIENE_BOT_PATIENCE] = controller.blackboard[BB_HYGIENE_BOT_PATIENCE] - delta_time

	if(controller.blackboard[BB_HYGIENE_BOT_PATIENCE] < 0)
		finish_action(controller, FALSE)


/datum/ai_behavior/chase_filthy_person/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key)
	. = ..()

	var/mob/living/basic/bot/hygiene/hygiene_bot = controller.pawn

	if(succeeded)
		controller.blackboard[target_key] = null ///Reset target
		hygiene_bot.stop_washing
		if(finished_lines.len)
			hygiene_bot.speak(pick(finished_lines))
	else
		controller.blackboard[BB_HYGIENE_BOT_ANGRY] = TRUE
		basic_bot.speak("Okay now I'm pissed!")


/datum/ai_behavior/chase_filthy_person/angry
	starting_patience = -1
	chase_speed = 0.75
	finished_lines = list("Well about fucking time you degenerate.", "Fucking finally.", "Thank god, you finally stopped.")
	chase_lines = list("Get back here you foul smelling fucker.", "STOP RUNNING OR I WILL CUT YOUR ARTERIES!", "Just fucking let me clean you you arsehole!", "STOP. RUNNING.", "Either you stop running or I will fucking drag you out of an airlock.", "I just want to fucking clean you you troglodyte.", "If you don't come back here I'll put a green cloud around you cunt.")


/*
					if((get_dist(src, target)) >= olddist)
						frustration++
					else
						frustration = 0


/mob/living/simple_animal/bot/hygienebot/proc/back_to_idle()
	mode = BOT_IDLE
	SSmove_manager.stop_looping(src)
	target = null
	frustration = 0
	last_found = world.time
	stop_washing()
	INVOKE_ASYNC(src, .proc/handle_automated_action)

/mob/living/simple_animal/bot/hygienebot/proc/back_to_hunt()
	frustration = 0
	mode = BOT_HUNT
	stop_washing()
	INVOKE_ASYNC(src, .proc/handle_automated_action)


		*/


