/// Find and attack corpses
/datum/ai_planning_subtree/find_and_hunt_target/corpses
	finding_behavior = /datum/ai_behavior/find_hunt_target/corpses
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target
	hunt_targets = list(/mob/living)

/// Find nearby dead mobs
/datum/ai_behavior/find_hunt_target/corpses

/datum/ai_behavior/find_hunt_target/corpses/valid_dinner(mob/living/source, mob/living/dinner, radius)
	if (!isliving(dinner) || dinner.stat != DEAD)
		return FALSE
	return can_see(source, dinner, radius)

/// Find and attack specifically human corpses
/datum/ai_planning_subtree/find_and_hunt_target/corpses/human
	hunt_targets = list(/mob/living/carbon/human)
