/mob/living/simple_animal/pet/bumbles
	name = "Bumbles"
	desc = "Bumbles, the very humble bumblebee."
	icon = 'modular_skyrat/master_files/icons/mob/pets.dmi'
	icon_state = "bumbles"
	icon_living = "bumbles"
	icon_dead = "bumbles_dead"
	maxHealth = 15
	health = 15
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "brushes aside"
	response_help_simple = "brush aside"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"
	speak_emote = list("buzzes")
	friendly_verb_continuous = "bzzs"
	friendly_verb_simple = "bzz"
	butcher_results = list(/obj/item/reagent_containers/honeycomb = 2)
	density = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "buzzs"
	verb_ask = "buzzes inquisitively"
	verb_exclaim = "buzzes intensely"
	verb_yell = "buzzes intensely"
	emote_see = list("buzzes.", "makes a loud buzz.", "rolls several times.", "buzzes happily.")
	speak_chance = 1
	unique_name = TRUE

/mob/living/simple_animal/pet/bumbles/Initialize()
	. = ..()
	AddElement(/datum/element/simple_flying)
	add_verb(src, /mob/living/proc/toggle_resting)

/mob/living/simple_animal/pet/bumbles/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]_rest"
	else
		icon_state = "[icon_living]"
	regenerate_icons()

/mob/living/simple_animal/pet/bumbles/bee_friendly()
	return TRUE //treaty signed at the Beeneeva convention

/mob/living/simple_animal/pet/bumbles/Life(delta_time = SSMOBS_DT, times_fired)
	if(buckled || client || !DT_PROB(0.5, delta_time))
		return ..()
	if(resting)
		manual_emote(pick("curls up on the surface below.", "is looking very sleepy.", "buzzes happily.", "looks around for a flower nap."))
		REMOVE_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
		set_resting(TRUE)
		return ..()
	manual_emote(pick("wakes up with a smiling buzz.", "rolls upside down before waking up.", "stops resting."))
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
	set_resting(FALSE)
	return ..()
