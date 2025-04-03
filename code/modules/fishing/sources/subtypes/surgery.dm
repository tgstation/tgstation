//Quirky fish source for surgery, an overcomplicated joke.

/datum/fish_source/surgery
	catalog_description = "Surgery"
	radial_state = "innards"
	overlay_state = "portal_syndicate" //Didn't feel like spriting a new overlay. It's just all red anyway.
	background = "background_lavaland" //Kinda red.
	fish_table = list(FISHING_RANDOM_ORGAN = 10)
	//This should get you below zero difficulty and skip the minigame phase, unless you're wearing something that counteracts this.
	fishing_difficulty = -10
	//The range for waiting is also a bit narrower, so it cannot take as few as 3 seconds or as many as 25 to snatch an organ.
	wait_time_range = list(6 SECONDS, 12 SECONDS)

/datum/fish_source/surgery/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot, obj/item/fishing_rod/used_rod)
	if(istype(fishing_spot, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = fishing_spot
		fishing_spot = portal.current_linked_atom
	if(!iscarbon(fishing_spot))
		var/random_type = pick(subtypesof(/obj/item/organ) - GLOB.prototype_organs)
		return new random_type(spawn_location)

	var/mob/living/carbon/carbon = fishing_spot
	var/list/possible_organs = list()
	for(var/datum/surgery/organ_manipulation/operation in carbon.surgeries)
		var/datum/surgery_step/manipulate_organs/manip_step = GLOB.surgery_steps[operation.steps[operation.status]]
		if(!istype(manip_step))
			continue
		for(var/obj/item/organ/organ in operation.operated_bodypart)
			if(organ.organ_flags & ORGAN_UNREMOVABLE || !manip_step.can_use_organ(organ))
				continue
			possible_organs |= organ

	if(!length(possible_organs))
		return null
	var/obj/item/organ/chosen = pick(possible_organs)
	chosen.Remove(chosen.owner)
	chosen.forceMove(spawn_location)
	return chosen

/datum/fish_source/surgery/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Organs",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "A random organ from an ongoing organ manipulation surgery.",
	))

	return data
