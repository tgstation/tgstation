//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Geckers","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls.","barks.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	held_state = "fox"

	footstep_type = FOOTSTEP_MOB_CLAW

//Captain fox
/mob/living/simple_animal/pet/fox/renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox."
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/fox/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)

/mob/living/simple_animal/pet/fox/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD)
				new /obj/effect/temp_visual/heart(loc)
				emote("me", 1, "yaps happily!")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("me", 1, "howls!")
