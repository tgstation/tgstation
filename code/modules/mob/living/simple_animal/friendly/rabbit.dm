/**
 * # Rabbit
 *
 * A creature that hops around with small tails and long ears.
 *
 * This contains the code for both your standard rabbit as well as the subtypes commonly found during Easter.
 *
 */
/mob/living/simple_animal/rabbit
	name = "\improper rabbit"
	desc = "The hippiest hop around."
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	health = 15
	maxHealth = 15
	icon = 'icons/mob/rabbit.dmi'
	icon_state = "rabbit_white"
	icon_living = "rabbit_white"
	icon_dead = "rabbit_white_dead"
	speak_emote = list("sniffles","twitches")
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	can_be_held = TRUE
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	//passed to animal_varity as the prefix icon.
	var/icon_prefix = "rabbit"

/mob/living/simple_animal/rabbit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "hops around happily!")
	AddElement(/datum/element/animal_variety, icon_prefix, pick("brown","black","white"), TRUE)

/mob/living/simple_animal/rabbit/easter
	icon_state = "e_rabbit_white"
	icon_living = "e_rabbit_white"
	icon_dead = "e_rabbit_white_dead"
	icon_prefix = "e_rabbit"
	speak = list(
		"Hop into Easter!",
		"Come get your eggs!",
		"Prizes for everyone!",
	)
	icon_prefix = "e_rabbit"
	///passed to the egg_layer component as how many eggs it starts out as able to lay.
	var/initial_egg_amount = 10
	///passed to the egg_layer component as how many eggs it's allowed to hold at most.
	var/max_eggs_held = 8

/mob/living/simple_animal/rabbit/easter/space
	icon_state = "s_rabbit_white"
	icon_living = "s_rabbit_white"
	icon_dead = "s_rabbit_white_dead"
	icon_prefix = "s_rabbit"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/rabbit/easter/Initialize(mapload)
	. = ..()
	//passed to the egg_layer component as how many eggs it gets when it eats something.
	var/eggs_added_from_eating = rand(1, 4)
	var/list/feed_messages = list("[p_they()] nibbles happily.", "[p_they()] noms happily.")
	AddElement(/datum/element/animal_variety, icon_prefix, pick("brown","black","white"), TRUE)
	AddComponent(/datum/component/egg_layer,\
		/obj/item/surprise_egg,\
		list(/obj/item/food/grown/carrot),\
		feed_messages,\
		list("hides an egg.","scampers around suspiciously.","begins making a huge racket.","begins shuffling."),\
		initial_egg_amount,\
		eggs_added_from_eating,\
		max_eggs_held,\
	)
