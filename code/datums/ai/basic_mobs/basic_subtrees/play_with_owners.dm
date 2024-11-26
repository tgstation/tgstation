/datum/ai_planning_subtree/find_and_hunt_target/play_with_owner
	target_key = BB_OWNER_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/play_with_owner
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_owner
	hunt_targets = list(/mob/living)
	hunt_chance = 80
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/find_owner
	action_cooldown = 1 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_hunt_target/find_owner/valid_dinner(mob/living/source, atom/friend, radius, datum/ai_controller/controller, seconds_per_tick)
	return (friend != source) && (source.faction.Find(REF(friend))) && can_see(source, friend, radius)

/datum/ai_behavior/hunt_target/play_with_owner

/datum/ai_behavior/hunt_target/play_with_owner/target_caught(mob/living/hunter, atom/hunted)
	var/list/interactions_list = hunter.ai_controller.blackboard[BB_INTERACTIONS_WITH_OWNER]
	var/interaction_message = length(interactions_list) ? pick(interactions_list) : "Plays with"
	hunter.manual_emote("[interaction_message] [hunted]!")
