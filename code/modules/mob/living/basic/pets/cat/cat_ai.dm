/datum/ai_controller/basic_controller/cat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_HOSTILE_MEOWS = list("Mawwww", "Mrewwww", "mhhhhng..."),
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/pet/cat),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/pet/cat/kitten),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/reside_in_home,
		/datum/ai_planning_subtree/flee_target/from_flee_key/cat_struggle,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice,
		/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/haul_food_to_young,
		/datum/ai_planning_subtree/territorial_struggle,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/random_speech/cats,
	)

/datum/ai_planning_subtree/reside_in_home
	///chance we enter our home
	var/reside_chance = 5
	///chance we leave our home
	var/leave_home_chance = 15

/datum/ai_planning_subtree/reside_in_home/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(controller.blackboard_key_exists(BB_CAT_HOME))
		controller.queue_behavior(/datum/ai_behavior/enter_cat_home, BB_CAT_HOME)
		return

	if(istype(living_pawn.loc, /obj/structure/cat_house))
		if(SPT_PROB(leave_home_chance, seconds_per_tick))
			controller.set_blackboard_key(BB_CAT_HOME, living_pawn.loc)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(SPT_PROB(reside_chance, seconds_per_tick))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_home, BB_CAT_HOME, /obj/structure/cat_house)

/datum/ai_behavior/find_and_set/valid_home/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/obj/structure/cat_house/home in oview(search_range, controller.pawn))
		if(home.resident_cat)
			continue
		return home

	return null

/datum/ai_behavior/enter_cat_home
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/enter_cat_home/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/enter_cat_home/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/obj/structure/cat_house/home = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	if(living_pawn == home.resident_cat || isnull(home.resident_cat))
		controller.ai_interact(target = home)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/enter_cat_home/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

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
		var/datum/ai_controller/basic_controller/enemy_controller = potential_enemy.ai_controller
		if(isnull(enemy_controller))
			continue
		//theyre already engaged in a battle, leave them alone!
		if(enemy_controller.blackboard_key_exists(BB_TRESSPASSER_TARGET))
			continue
		//u choose me and i choose u
		enemy_controller.set_blackboard_key(BB_TRESSPASSER_TARGET, controller.pawn)
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
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

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
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

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

/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/list/items_we_carry = typecache_filter_list(living_pawn, controller.blackboard[BB_HUNTABLE_PREY])
	if(length(items_we_carry))
		return
	return ..()


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
	var/mob/living/basic/mouse/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	consume_chance = istype(target, /mob/living/basic/mouse/brown/tom) ? 5 : initial(consume_chance)
	if(prob(consume_chance))
		target.splat()
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/play_with_mouse/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	controller.clear_blackboard_key(target_key)
	if(isnull(target) || QDELETED(living_pawn))
		return
	var/manual_emote = "attempts to hunt [target]..."
	var/end_result = success ? "and succeeds!" : "but fails!"
	manual_emote += end_result
	living_pawn.manual_emote(manual_emote)

/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food
	target_key = BB_CAT_FOOD_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/find_cat_food
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_cat_food
	hunt_targets = list(/obj/item/fish, /obj/item/food/deadmouse, /obj/item/food/fishmeat)
	hunt_chance = 75
	hunt_range = 9

/datum/ai_behavior/hunt_target/interact_with_target/find_cat_food
	always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/find_cat_food/valid_dinner(mob/living/source, atom/dinner, radius)
	//this food is already near a kitten, let the kitten eat it
	var/mob/living/nearby_kitten = locate(/mob/living/basic/pet/cat/kitten) in oview(2, dinner)
	if(nearby_kitten && nearby_kitten != source)
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_planning_subtree/haul_food_to_young/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_FOOD_TO_DELIVER))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_hands/given_list, BB_FOOD_TO_DELIVER, controller.blackboard[BB_HUNTABLE_PREY])
		return
	if(!controller.blackboard_key_exists(BB_KITTEN_TO_FEED))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_kitten, BB_KITTEN_TO_FEED, /mob/living/basic/pet/cat/kitten)
		return

	controller.queue_behavior(/datum/ai_behavior/deliver_food_to_kitten, BB_KITTEN_TO_FEED, BB_FOOD_TO_DELIVER)

/datum/ai_behavior/find_and_set/valid_kitten

/datum/ai_behavior/find_and_set/valid_kitten/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/kitten = locate(locate_path) in oview(search_range, controller.pawn)
	//kitten already has food near it, go feed another hungry kitten

	if(isnull(kitten))
		return null

	var/list/nearby_food = typecache_filter_list(oview(2, kitten), controller.blackboard[BB_HUNTABLE_PREY])
	if(kitten.stat != DEAD && !length(nearby_food))
		return kitten
	return null

/datum/ai_behavior/deliver_food_to_kitten
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 5 SECONDS

/datum/ai_behavior/deliver_food_to_kitten/setup(datum/ai_controller/controller, target_key, food_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/deliver_food_to_kitten/perform(seconds_per_tick, datum/ai_controller/controller, target_key, food_key)
	var/mob/living/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_pawn = controller.pawn
	var/atom/movable/food = controller.blackboard[food_key]

	if(isnull(food) || !(food in living_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	food.forceMove(get_turf(living_pawn))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/deliver_food_to_kitten/finish_action(datum/ai_controller/controller, success, target_key, food_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(food_key)




