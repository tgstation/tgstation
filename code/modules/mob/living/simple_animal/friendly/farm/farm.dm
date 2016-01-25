/mob/living/simple_animal/farm
	name = "\improper FARM ANIMAL"
	desc = "If you can see, this, shit's fucked up the ass so hard it's like a hardcore Brazzers video. Report this shit."
	density = 0
	turns_per_move = 2
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	ventcrawler = 2
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = 0


	var/datum/farm_animal_dna/dna = null

	health = 100
	maxHealth = 100

	var/hunger = 100
	var/thirst = 100
	var/hunger_max = 100
	var/thirst_max = 100
	var/hunger_decay = 1
	var/thirst_decay = 1
	var/hunger_threshold_hungry = 50
	var/hunger_threshold_dying = 5
	var/thirst_threshold_thirsty = 50
	var/thirst_threshold_dying = 5

	var/amount_drank = 10
	var/amount_eaten_herbivore = 1
	var/amount_eaten_carnivore = 3

	var/age = 0
	var/child = 0
	var/growth_age = 50
	var/age_tick = 0

	var/walking_to_trough = FALSE
	var/eating_from_trough = FALSE

	var/mob/living/simple_animal/farm/mother = null
	var/mob/living/simple_animal/farm/father = null

	var/list/young = list()

/mob/living/simple_animal/farm/examine(mob/user)
	..()
	switch(hunger)
		if(-INFINITY to hunger_threshold_dying)
			user.show_message("<span class ='danger'>It looks like its dying of hunger!</span>",1)
		if((hunger_threshold_dying + 1) to hunger_threshold_hungry)
			user.show_message("It looks hungry.",1)
	switch(thirst)
		if(-INFINITY to thirst_threshold_dying)
			user.show_message("<span class ='danger'>It looks like its dying of thirst!</span>",1)
		if((thirst_threshold_dying + 1) to thirst_threshold_thirsty)
			user.show_message("It looks thirsty.",1)
/mob/living/simple_animal/farm/New(var/mob/living/simple_animal/farm/mother, var/mob/living/simple_animal/farm/father)
	..()
	if(!dna)
		if(mother && father)
			dna = create_child_from_dna(mother, father, src)
		else
			dna = create_child_from_scratch(src)
	dna.owner = src
/mob/living/simple_animal/farm/Life()
	set background = BACKGROUND_ENABLED
	. =..()
	if(!.)
		return

	handle_priority_traits()

	handle_needs()

	handle_breeding()

	handle_traits()
	/*
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)
	*/
/mob/living/simple_animal/farm/proc/handle_needs()
	set background = BACKGROUND_ENABLED
	hunger -= hunger_decay
	thirst -= thirst_decay
	if(hunger <= hunger_threshold_dying)
		world << "DOING 1 DAMAGE, HUNGER DYING"
		adjustBruteLoss(1)
	if(hunger >= hunger_threshold_hungry)
		adjustBruteLoss(-1)

	if(thirst <= thirst_threshold_dying)
		world << "DOING 3 DAMAGE, HUNGER DYING"
		adjustBruteLoss(3)
	if(thirst >= thirst_threshold_thirsty)
		adjustBruteLoss(-1)
	return

/mob/living/simple_animal/farm/proc/handle_breeding()
	return

/mob/living/simple_animal/farm/proc/handle_traits()
	if(dna)
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_life(src)
	return

/mob/living/simple_animal/farm/proc/handle_priority_traits()
	if(dna)
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_priority_life(src)
	return

/mob/living/simple_animal/farm/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(dna)
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_hear(message, speaker, message_langs, raw_message, radio_freq, spans)
	..()


/mob/living/simple_animal/farm/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken_white"
	icon_living = "chicken_white"
	icon_dead = "chicken_white_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = 0
	speak_chance = 2
	turns_per_move = 3
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks at"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = 2