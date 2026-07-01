/// Raids a beehive once in range, extracting its honeycombs.
/datum/bt_node/ai_behavior/hunt_target/find_hive
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/find_hive/target_caught(mob/living/hunter, obj/structure/beebox/hive_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/bear, extract_combs), hive_target)
	callback.Invoke()
