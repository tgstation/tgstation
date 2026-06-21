// Behavior tree behaviors, subtrees and decorators for the cat AI family.

/// Passes when the cat is currently carrying a piece of huntable food.
/datum/bt_node/decorator/cat_holding_food

/datum/bt_node/decorator/cat_holding_food/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/pet/cat/cat = controller.pawn
	return istype(cat) && !isnull(cat.held_food)

/// Pounces on a mouse, occasionally killing it. Movement is handled externally.
/datum/bt_node/ai_behavior/play_with_mouse
	time_between_perform = 10 SECONDS
	/// Blackboard key holding the mouse we are hunting.
	var/target_key
	/// Chance we actually splat the mouse.
	var/consume_chance = 70

/datum/bt_node/ai_behavior/play_with_mouse/setup(datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/play_with_mouse/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/mouse/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	var/chance = istype(target, /mob/living/basic/mouse/brown/tom) ? 5 : consume_chance
	if(prob(chance))
		target.splat()
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/play_with_mouse/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	controller.clear_blackboard_key(target_key)
	if(isnull(target) || QDELETED(living_pawn))
		return
	var/manual_emote = "attempts to hunt [target]..."
	manual_emote += succeeded ? "and succeeds!" : "but fails!"
	living_pawn.manual_emote(manual_emote)

/// Drops a piece of carried food at a kitten's feet. Movement is handled externally.
/datum/bt_node/ai_behavior/deliver_food_to_kitten
	time_between_perform = 5 SECONDS
	/// Blackboard key holding the kitten to feed.
	var/target_key
	/// Blackboard key holding the food we are carrying.
	var/food_key

/datum/bt_node/ai_behavior/deliver_food_to_kitten/setup(datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/deliver_food_to_kitten/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	var/atom/movable/food = controller.blackboard[food_key]
	if(isnull(food) || !(food in living_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	food.forceMove(get_turf(living_pawn))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/deliver_food_to_kitten/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(food_key)

/// Engages a rival tom in a territorial yowling contest until one of them backs down. Movement is handled externally.
/datum/bt_node/ai_behavior/territorial_struggle
	time_between_perform = 5 SECONDS
	/// Blackboard key holding our rival.
	var/target_key
	/// Blackboard key holding the list of threatening cries.
	var/cries_key
	/// Chance the battle ends on each perform.
	var/end_battle_chance = 25

/datum/bt_node/ai_behavior/territorial_struggle/setup(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	// Only fight if our rival is still locked onto us.
	if(target.ai_controller?.blackboard[target_key] != living_pawn)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/territorial_struggle/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/mob/living/living_pawn = controller.pawn
	var/list/threaten_list = controller.blackboard[cries_key]
	if(length(threaten_list))
		living_pawn.say(pick(threaten_list), forced = "ai_controller")

	if(!prob(end_battle_chance))
		return AI_BEHAVIOR_DELAY

	// 50/50 chance we lose.
	var/datum/ai_controller/loser_controller = prob(50) ? controller : target.ai_controller
	loser_controller.set_blackboard_key(BB_BASIC_MOB_FLEE_TARGET, target)
	target.ai_controller?.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/territorial_struggle/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Finds a rival tom to fight, marking ourselves as their target too so the fight is mutual.
/datum/bt_node/ai_behavior/find_cat_tresspasser
	time_between_perform = 5 SECONDS
	/// Blackboard key to store the rival in.
	var/target_key
	/// How far to look for a rival.
	var/search_range = 9

/datum/bt_node/ai_behavior/find_cat_tresspasser/setup(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	return living_pawn.gender == MALE

/datum/bt_node/ai_behavior/find_cat_tresspasser/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/ignore_types = controller.blackboard[BB_BABIES_CHILD_TYPES]
	for(var/mob/living/basic/pet/cat/potential_enemy in oview(search_range, living_pawn))
		if(potential_enemy.gender != MALE)
			continue
		if(is_type_in_list(potential_enemy, ignore_types))
			continue
		var/datum/ai_controller/enemy_controller = potential_enemy.ai_controller
		if(isnull(enemy_controller))
			continue
		// They're already engaged in a battle, leave them alone!
		if(enemy_controller.blackboard_key_exists(BB_TRESSPASSER_TARGET))
			continue
		// You choose me and I choose you.
		enemy_controller.set_blackboard_key(BB_TRESSPASSER_TARGET, living_pawn)
		controller.set_blackboard_key(target_key, potential_enemy)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Points at a target and meows for food. Used to beg humans and call kittens to dinner.
/datum/bt_node/ai_behavior/beacon_for_food
	time_between_perform = 5 SECONDS
	/// Blackboard key holding the atom we are pointing at.
	var/target_key
	/// Blackboard key holding the list of hungry meows.
	var/meows_key

/datum/bt_node/ai_behavior/beacon_for_food/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/beacon_for_food/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	var/list/meowing_list = controller.blackboard[meows_key]
	if(length(meowing_list))
		living_pawn.say(pick(meowing_list), forced = "ai_controller")
	living_pawn._pointed(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/beacon_for_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Finds a conscious human carrying food worth begging for.
/datum/bt_node/ai_behavior/find_human_to_beg
	/// Blackboard key to store the human in.
	var/target_key
	/// How far to look for a human.
	var/search_range = 9

/datum/bt_node/ai_behavior/find_human_to_beg/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/locate_items = controller.blackboard[BB_HUNTABLE_PREY]
	for(var/mob/living/carbon/human/human_target in oview(search_range, living_pawn))
		if(human_target.stat != CONSCIOUS || isnull(human_target.mind))
			continue
		for(var/obj/item/held_item in human_target.held_items)
			if(is_type_in_typecache(held_item, locate_items))
				controller.set_blackboard_key(target_key, human_target)
				return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Leaves the cat house we are currently residing in, occasionally.
/datum/bt_node/ai_behavior/leave_cat_home
	/// Chance per attempt that we decide to leave.
	var/leave_home_chance = 15

/datum/bt_node/ai_behavior/leave_cat_home/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/structure/cat_house/home = controller.pawn.loc
	if(!istype(home))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!prob(leave_home_chance))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), home, FALSE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Celebrates around a decorated donut with a spin.
/datum/bt_node/ai_behavior/hunt_target/decorate_donuts
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/decorate_donuts/target_caught(mob/living/hunter, atom/hunted)
	hunter.spin(spintime = 4, speed = 1)

/// Enters (or exits if already resident) a cat house keyed in target_key.
/datum/bt_node/ai_behavior/enter_cat_home
	var/target_key

/datum/bt_node/ai_behavior/enter_cat_home/setup(datum/ai_controller/controller)
	var/obj/structure/cat_house/home = controller.blackboard[target_key]
	return !QDELETED(home)

/datum/bt_node/ai_behavior/enter_cat_home/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/structure/cat_house/home = controller.blackboard[target_key]
	if(QDELETED(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/basic/pet/cat/living_pawn = controller.pawn
	if(living_pawn == home.resident_cat || isnull(home.resident_cat))
		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), home, FALSE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/enter_cat_home/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

// Subtree types — the trees themselves live in the matching .bt.json files.

/// Block other behaviors while residing in a cat house; occasionally leave.
/datum/bt_node/subtree/cat_reside_in_home
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_reside_in_home.bt.json"

/// Find a mouse and pounce on it.
/datum/bt_node/subtree/cat_hunt_mice
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_hunt_mice.bt.json"

/// Find dropped food on the ground and eat it.
/datum/bt_node/subtree/cat_find_food
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_find_food.bt.json"

/// Carry food we are holding to a hungry kitten.
/datum/bt_node/subtree/cat_haul_food
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_haul_food.bt.json"

/// Turn off a finished oven.
/datum/bt_node/subtree/cat_turn_off_stove
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_turn_off_stove.bt.json"

/// Spin to decorate nearby donuts.
/datum/bt_node/subtree/cat_decorate_donuts
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_decorate_donuts.bt.json"
