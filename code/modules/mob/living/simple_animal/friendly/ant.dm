/mob/living/simple_animal/ant
	name = "giant ant"
	desc = "A writhing mass of ants, glued together to make an adorable pet!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "ant"
	icon_living = "ant"
	icon_dead = "ant_dead"
	speak = list("BZZZZT!", "CHTCHTCHT!", "Bzzz", "ChtChtCht")
	speak_emote = list("buzzes", "chitters")
	emote_hear = list("buzzes.", "clacks.")
	emote_see = list("shakes its head.", "twitches its antennae.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	pass_flags = PASSTABLE
	atom_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	minbodytemp = 200
	maxbodytemp = 400
	unsuitable_atmos_damage = 1
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/effect/decal/cleanable/ants = 1) //It's just a bunch of ants glued together into a larger ant
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = FALSE
	footstep_type = FOOTSTEP_MOB_CLAW
	health = 75
	maxHealth = 75
	// randomizes hunting intervals, minimum 5 turns
	var/time_to_hunt = 5

/mob/living/simple_animal/ant/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	time_to_hunt = rand(5,10)

/mob/living/simple_animal/ant/Life(delta_time = SSMOBS_DT, times_fired) // In this larger state, the ants have become the predators.
	. = ..()
	turns_since_scan++
	if(turns_since_scan > time_to_hunt)
		turns_since_scan = 0
		var/list/target_types = list(/mob/living/basic/cockroach)
		for(var/mob/living/simple_animal/hostile/potential_target in view(2, get_turf(src)))
			if(potential_target.type in target_types)
				hunt(potential_target)
				return
