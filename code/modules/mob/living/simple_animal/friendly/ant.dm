/mob/living/simple_animal/ant
	name = "giant ant"
	desc = "Ain't it just the cutest thing?"
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
	mob_size = MOB_SIZE_SMALL
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

/mob/living/simple_animal/ant/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/ant/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_COCKROACH, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 7) //They're both insects, might as well make it do SOMETHING

/mob/living/simple_animal/ant/Life(delta_time = SSMOBS_DT, times_fired) //Payback time bitch
	hunt_target(/mob/living/simple_animal/hostile/cockroach)
