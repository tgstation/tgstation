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

	var/hunger = 500
	var/thirst = 500
	var/hunger_max = 500
	var/thirst_max = 500
	var/hunger_decay = 1
	var/thirst_decay = 3
	var/hunger_threshold_hungry = 300
	var/hunger_threshold_dying = 100
	var/thirst_threshold_thirsty = 300
	var/thirst_threshold_dying = 100

	var/amount_drank = 10
	var/amount_eaten_herbivore = 1
	var/amount_eaten_carnivore = 3

	var/age = 0
	var/child = 0
	var/mob/living/simple_animal/farm/adult_version
	var/growth_age = 150

	var/walking_to_trough = FALSE
	var/eating_from_trough = FALSE

	var/mob/living/simple_animal/farm/mother = null
	var/mob/living/simple_animal/farm/father = null

	var/obj/item/weapon/reagent_containers/food/snacks/egg/egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	var/mob/living/simple_animal/farm/mob_birth_type = /mob/living/simple_animal/farm/chick

	var/datum/farm_animal_trait/default_breeding_trait = /datum/farm_animal_trait/herbivore
	var/datum/farm_animal_trait/default_food_trait = /datum/farm_animal_trait/egg_layer

	var/list/young = list()
	var/list/default_traits = list()

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
	switch(gender)
		if(FEMALE)
			user.show_message("It is female.",1)
		if(MALE)
			user.show_message("It is male.",1)
	if(dna)
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_examine(user, src)
	return
/mob/living/simple_animal/farm/New(var/new_dna = 1, var/mob/living/simple_animal/farm/mother_temp, var/mob/living/simple_animal/farm/father_temp)
	..()
	gender = pick(FEMALE, MALE)
	if(child)
		health /= 2
	if(!dna && new_dna)
		if(mother_temp && father_temp)
			dna = create_child_from_dna(mother_temp, father_temp, src)
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

	handle_age()

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
		adjustBruteLoss(1)
	if(hunger > hunger_threshold_hungry)
		adjustBruteLoss(-1)

	if(thirst <= thirst_threshold_dying)
		adjustBruteLoss(3)
	if(thirst > thirst_threshold_thirsty)
		adjustBruteLoss(-1)
	return

/mob/living/simple_animal/farm/proc/handle_age()
	if(child)
		age++
		if(age >= growth_age)
			var/mob/living/simple_animal/farm/F = new adult_version(src.loc)
			F.name = src.name
			F.dna = create_child_from_dna(src, src, F) // this technically means that at some point all babies become their own parents but ehhh, saves me the time
			F.dna.mother = mother
			F.dna.father = father
			F.mother = mother
			F.father = father
			F.gender = gender
			qdel(src)
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