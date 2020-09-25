/datum/eldritch_knowledge/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the path of void to you. Allows you to transmute a knife in a sub-zero temperature into a void blade."
	gain_text = "I feel a shimmer in the air, atmosphere around me gets colder. I feel my body realizing the emptiness of existance. Something's watching me"
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/void_grasp)
	required_atoms = list(/obj/item/kitchen/knife)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/base_void/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	var/turf/open/turfie = loc
	if(turfie.GetTemperature() > T0C)
		return FALSE

/datum/eldritch_knowledge/void_grasp
	name = "Grasp of Void"
	desc = "Opens up the path of void to you. Allows you to transmute a knife in a sub-zero temperature into a broken blade."
	gain_text = "I found the cold watcher who observes me. Aristocrat leads my way."
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/void_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	var/turf/open/turfie = get_turf(carbon_target)
	turfie.TakeTemperature(-20)
	carbon_target.adjust_bodytemperature(-20)
	return TRUE

/datum/eldritch_knowledge/cold_snap
	name = "Aristocrat's Way"
	desc = "Makes you immune to cold temperatures, you can still take damage from lack of pressure."
	gain_text = "I learned how to walk like a true monarch, like a true knight, like a true Aristrocrat."
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/cold_snap/on_gain(mob/user)
	. = ..()
	ADD_TRAIT(user,TRAIT_RESISTCOLD,MAGIC_TRAIT)

/datum/eldritch_knowledge/cold_snap/on_lose(mob/user)
	. = ..()
	REMOVE_TRAIT(user,TRAIT_RESISTCOLD,MAGIC_TRAIT)

/datum/eldritch_knowledge/void_cloak
	name = "Void Cloak"
	desc = "A cloak that can become invisbile at will, hiding items you store in it."
	gain_text = "Owl is the keeper of things that quite not are in practice, but in theory they hold together."
	cost = 1
	route = PATH_VOID
