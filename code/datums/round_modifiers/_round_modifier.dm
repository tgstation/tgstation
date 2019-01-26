/datum/round_modifier
	var/name = null
	var/permament = FALSE

/datum/round_modifier/proc/on_apply()
	return

/datum/round_modifier/proc/on_remove()
	return

/datum/round_modifier/proc/announce_enabling()
	priority_announce("A bug has occured with the universe. Please notify a Centcom employee immediately.")

/datum/round_modifier/proc/announce_disabling()
	priority_announce("The universe was bugged, but now it is less bugged than before.")

/datum/round_modifier/proc/on_player_spawn(mob/living/L)
	return

/datum/round_modifier/proc/on_tick()
	return

// Specialised subtypes
/datum/round_modifier/trait
	var/list/modifier_traits

	var/apply_to_mob = FALSE
	var/apply_to_mind = FALSE

/datum/round_modifier/trait/proc/is_eligible(mob/M)
	return FALSE

/datum/round_modifier/trait/proc/apply(mob/M)
	for(var/t in modifier_traits)
		if(apply_to_mind && M.mind)
			M.mind.add_trait(t, ROUND_MODIFIER_TRAIT)
		if(apply_to_mob)
			M.add_trait(t, ROUND_MODIFIER_TRAIT)

/datum/round_modifier/trait/proc/remove(mob/M)
	for(var/t in modifier_traits)
		if(apply_to_mind && M.mind)
			M.mind.remove_trait(t, ROUND_MODIFIER_TRAIT)
		if(apply_to_mob)
			M.remove_trait(t, ROUND_MODIFIER_TRAIT)

// Overide this proc to give a subset of mobs
/datum/round_modifier/trait/proc/get_mob_list()
	return GLOB.player_list

/datum/round_modifier/trait/on_player_spawn(mob/living/L)
	if(is_eligible(L))
		apply(L)

/datum/round_modifier/trait/on_apply()
	for(var/mob/M in get_mob_list())
		if(is_eligible(M))
			apply(M)

/datum/round_modifier/trait/on_remove()
	for(var/mob/M in get_mob_list())
		remove(M)

/datum/round_modifier/trait/on_tick()
	on_apply()
