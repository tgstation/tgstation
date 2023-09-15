/datum/ai_behavior/basic_melee_attack/bear
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_hunt_target/find_hive

/datum/ai_behavior/find_hunt_target/find_hive/valid_dinner(mob/living/source, obj/structure/beebox/hive, radius)
	if(!length(hive.honeycombs))
		return FALSE
	return can_see(source, hive, radius)

/datum/ai_behavior/hunt_target/find_hive
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/find_hive/target_caught(mob/living/hunter, obj/structure/beebox/hive_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/bear, extract_combs), hive_target)
	callback.Invoke()

/datum/ai_behavior/find_hunt_target/find_honeycomb

/datum/ai_behavior/find_hunt_target/find_honeycomb/setup(datum/ai_controller/controller, ability_key, target_key)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.pulling) //we already pulling a honey
		return FALSE
	return TRUE

/datum/ai_behavior/hunt_target/find_honeycomb
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/find_honeycomb/target_caught(mob/living/hunter, obj/item/food/honeycomb/food_target)
	hunter.start_pulling(food_target)
