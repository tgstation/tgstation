#define BB_TRESSPASSER_TARGET "tresspasser_target"
#define BB_HOSTILE_MEOWS "hostile_meows"
#define BB_MOUSE_TARGET "mouse_target"

/datum/ai_controller/basic_controller/cat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_HOSTILE_MEOWS = list("Mawwww", "Mrewwww", "mhhhhng..."),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/pet/cat/kitten),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_target/from_flee_key/cat_struggle,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/territorial_struggle,
	)

/datum/ai_planning_subtree/flee_target/from_flee_key/cat_struggle
	flee_behaviour = /datum/ai_behavior/run_away_from_target/cat_struggle

/datum/ai_behavior/run_away_from_target/cat_struggle
	clear_failed_targets = TRUE

/datum/ai_planning_subtree/territorial_struggle
	///chance we become hostile to another cat
	var/hostility_chance = 5

/datum/ai_planning_subtree/territorial_struggle/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.gender != MALE || !SPT_PROB(hostility_chance, seconds_per_tick))
		return
	if(controller.blackboard_key_exists(BB_TRESSPASSER_TARGET))
		controller.queue_behavior(/datum/ai_behavior/territorial_struggle, BB_TRESSPASSER_TARGET, BB_HOSTILE_MEOWS)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/cat_tresspasser, BB_TRESSPASSER_TARGET, /mob/living/basic/pet/cat)

/datum/ai_behavior/find_and_set/cat_tresspasser/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/ignore_types = controller.blackboard[BB_BABIES_CHILD_TYPES]
	for(var/mob/living/basic/pet/cat/potential_enemy in oview(search_range, controller.pawn))
		if(potential_enemy.gender != MALE)
			continue
		if(is_type_in_list(potential_enemy, ignore_types))
			continue
		if(isnull(potential_enemy.ai_controller))
			continue
		//theyre already engaged in a battle, leave them alone!
		if(potential_enemy.ai_controller.blackboard_key_exists(BB_TRESSPASSER_TARGET))
			continue
		//u choose me and i choose u
		potential_enemy.ai_controller.set_blackboard_key(BB_TRESSPASSER_TARGET, controller.pawn)
		return potential_enemy
	return null

/datum/ai_behavior/territorial_struggle
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 5 SECONDS
	///chance the battle ends!
	var/end_battle_chance = 25

/datum/ai_behavior/territorial_struggle/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(target.ai_controller?.blackboard[target_key] != living_pawn)
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/territorial_struggle/perform(seconds_per_tick, datum/ai_controller/controller, target_key, cries_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, TRUE, target_key)
		return

	var/mob/living/living_pawn = controller.pawn
	var/list/threaten_list = controller.blackboard[cries_key]
	if(length(threaten_list))
		living_pawn.say(pick(threaten_list), forced = "ai_controller")

	if(!prob(end_battle_chance))
		return

	//50 50 chance we lose
	var/datum/ai_controller/loser_controller = prob(50) ? controller : target.ai_controller

	loser_controller.set_blackboard_key(BB_BASIC_MOB_FLEE_TARGET, target)
	target.ai_controller.clear_blackboard_key(BB_TRESSPASSER_TARGET)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/territorial_struggle/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice
	target_key = BB_MOUSE_TARGET
	hunting_behavior = /datum/ai_behavior/play_with_mouse
	finding_behavior = /datum/ai_behavior/find_hunt_target/hunt_mice
	hunt_targets = list(/mob/living/basic/mouse)
	hunt_chance = 75
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/hunt_mice/valid_dinner(mob/living/source, mob/living/mouse, radius)
	if(mouse.stat == DEAD || mouse.mind)
		return FALSE
	return can_see(source, mouse, radius)

//play as in kill
/datum/ai_behavior/play_with_mouse
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 10 SECONDS
	///chance we hunt the mouse!
	var/consume_chance = 70

/datum/ai_behavior/play_with_mouse/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/play_with_mouse/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/mouse/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, TRUE, target_key)
		return

	consume_chance = istype(target, /mob/living/basic/mouse/brown/tom) ? 5 : initial(consume_chance)
	if(prob(consume_chance))
		target.splat()
		finish_action(controller, TRUE, target_key)
		return
	finish_action(controller, FALSE, target_key)

/datum/ai_behavior/play_with_mouse/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	controller.clear_blackboard_key(target_key)
	if(isnull(target))
		return
	var/manual_emote = "attempts to hunt [target]..."
	var/end_result = success ? "and succeeds!" : "but fails!"
	manual_emote += end_result
	living_pawn.manual_emote(manual_emote)
