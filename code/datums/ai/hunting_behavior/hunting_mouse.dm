// Mouse subtree to hunt down delicious cheese.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_targets = list(/obj/item/food/cheese)
	hunt_range = 1

// Mouse subtree to hunt down ... delicious cabling?
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	finding_behavior = /datum/ai_behavior/find_hunt_target/mouse_cable
	hunt_targets = list(/obj/structure/cable)
	hunt_range = 0 // Only look below us
	hunt_chance = 1

// When looking for a cable, we can only bite things we can reach.
/datum/ai_behavior/find_hunt_target/mouse_cable

/datum/ai_behavior/find_hunt_target/mouse_cable/valid_dinner(mob/living/source, obj/structure/cable/dinner, radius)
	. = ..()
	if(!.)
		return

	var/turf/open/floor/below_the_cable = get_turf(dinner)
	if(!istype(below_the_cable))
		return FALSE

	return below_the_cable.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE

// Our hunts have a decent cooldown.
/datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_cooldown = 20 SECONDS
