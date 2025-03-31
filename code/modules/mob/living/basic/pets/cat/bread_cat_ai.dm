/datum/ai_controller/basic_controller/cat/bread
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/turn_off_stove,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice,
		/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food,
		/datum/ai_planning_subtree/haul_food_to_young,
		/datum/ai_planning_subtree/random_speech/cats,
	)

/datum/ai_planning_subtree/find_and_hunt_target/turn_off_stove
	target_key = BB_STOVE_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/stove_target
	finding_behavior = /datum/ai_behavior/find_hunt_target/stove
	hunt_targets = list(/obj/machinery/oven/range)
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/stove

/datum/ai_behavior/find_hunt_target/stove/valid_dinner(mob/living/source, obj/machinery/oven/range/stove, radius)
	if(!length(stove.used_tray?.contents) || stove.open)
		return FALSE
	//something in there is still baking...
	for(var/atom/baking in stove.used_tray)
		if(HAS_TRAIT(baking, TRAIT_BAKEABLE))
			return FALSE
	return TRUE

/datum/ai_behavior/hunt_target/interact_with_target/stove_target
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/interact_with_target/stove_target/target_caught(mob/living/hunter, obj/machinery/oven/range/stove)
	if(stove.open)
		return
	return ..()

/datum/ai_controller/basic_controller/cat/cake
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/turn_off_stove,
		/datum/ai_planning_subtree/find_and_hunt_target/decorate_donuts,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice,
		/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food,
		/datum/ai_planning_subtree/haul_food_to_young,
		/datum/ai_planning_subtree/random_speech/cats,
	)

/datum/ai_planning_subtree/find_and_hunt_target/decorate_donuts
	target_key = BB_DONUT_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/decorate_donuts
	finding_behavior = /datum/ai_behavior/find_hunt_target/decorate_donuts
	hunt_targets = list(/obj/item/food/donut)
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/decorate_donuts/valid_dinner(mob/living/source, obj/item/food/donut/target, radius)
	if(!target.is_decorated)
		return FALSE
	return can_see(source, target, radius)

/datum/ai_behavior/hunt_target/decorate_donuts
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/decorate_donuts/target_caught(mob/living/hunter, atom/target)
	hunter.spin(spintime = 4, speed = 1)
