/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/light_fixtures
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/light_fixtures
	hunt_targets = list(/obj/machinery/light)
	hunt_range = 7

/datum/ai_behavior/hunt_target/unarmed_attack_target/light_fixtures
	hunt_cooldown = 10 SECONDS
	always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/light_fixtures

/datum/ai_behavior/find_hunt_target/light_fixtures/valid_dinner(mob/living/source, obj/machinery/light/dinner, radius)
	if(dinner.status == LIGHT_BROKEN) //light is already broken
		return FALSE

	return can_see(source, dinner, radius)
