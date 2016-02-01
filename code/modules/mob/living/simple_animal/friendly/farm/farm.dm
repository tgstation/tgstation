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

	var/amount_drank = 25
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
	var/datum/farm_animal_trait/default_retaliate_trait = /datum/farm_animal_trait/coward

	var/next_riding_move = 0 //used for move delays
	var/riding_move_delay = 1 //tick delay between movements, lower = faster, higher = slower
	var/pixel_x_offset = 0
	var/pixel_y_offset = 4
	var/auto_door_open = TRUE

	var/list/young = list()
	var/list/default_traits = list()
	gender = NEUTER

/mob/living/simple_animal/farm/examine(mob/user)
	..()
	switch(hunger)
		if(-INFINITY to hunger_threshold_dying)
			user.show_message("<span class ='danger'>It looks like its dying of hunger!</span>",1)
		if(hunger_threshold_dying to hunger_threshold_hungry)
			user.show_message("It looks hungry.",1)
	switch(thirst)
		if(-INFINITY to thirst_threshold_dying)
			user.show_message("<span class ='danger'>It looks like its dying of thirst!</span>",1)
		if(thirst_threshold_dying to thirst_threshold_thirsty)
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
	create_reagents(1000)
	if(gender == NEUTER)
		gender = pick(FEMALE, MALE)
	if(child)
		health /= 2
	if(!dna && new_dna)
		if(mother_temp && father_temp)
			dna = create_child_from_dna(mother_temp, father_temp, src)
		else
			dna = create_child_from_scratch(src)
	dna.owner = src
	handle_riding_layer()
/mob/living/simple_animal/farm/Life()
	set background = BACKGROUND_ENABLED
	. =..()
	if(!.)
		return

	handle_priority_traits()

	handle_needs()

	handle_age()

	handle_traits()

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

	if(thirst <= thirst_threshold_thirsty)
		if(prob(10))
			emote("coughs.")
	if(hunger <= hunger_threshold_hungry)
		if(prob(10))
			emote("whines.")
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

/mob/living/simple_animal/farm/proc/handle_riding_layer()
	if(dir != NORTH)
		layer = MOB_LAYER+0.1
		if(buckled_mob)
			buckled_mob.layer = MOB_LAYER
	else
		if(buckled_mob)
			buckled_mob.layer = MOB_LAYER
		layer = 5

/mob/living/simple_animal/farm/proc/handle_riding_offsets()
	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.pixel_x = pixel_x_offset
		buckled_mob.pixel_y = pixel_y_offset
		switch(buckled_mob.dir)
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -4
				buckled_mob.pixel_y = 7
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 4
				buckled_mob.pixel_y = 7

/mob/living/simple_animal/farm/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(dna)
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_hear(message, speaker, message_langs, raw_message, radio_freq, spans)
	..()


/mob/living/simple_animal/farm/attack_hand(mob/living/carbon/human/M)
	..()
	switch(M.a_intent)
		if("harm", "disarm")
			for(var/datum/farm_animal_trait/T in dna.traits)
				T.on_attacked(src, M)

/mob/living/simple_animal/farm/attack_paw(mob/living/carbon/monkey/M)
	if(..()) //successful monkey bite.
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_attacked(src, M)
	return

/mob/living/simple_animal/farm/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_attacked(src, M)
		return 1

/mob/living/simple_animal/farm/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_attacked(src, L)
		return 1

/mob/living/simple_animal/farm/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_attacked(src, M)
		return 1

/mob/living/simple_animal/farm/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "The animal has the following traits:"
		for(var/datum/farm_animal_trait/T in dna.traits)
			user << "[T.name]"
			user << "[T.description]"
			user << "-----------------------------------------------"
		user << "Hunger: [hunger]"
		user << "Thirst: [thirst]"
	for(var/datum/farm_animal_trait/T in dna.traits)
		T.on_attack_by(src, O, user, params)
	..()
/mob/living/simple_animal/farm/attack_animal(mob/living/simple_animal/M)
	if(..())
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_attacked(M)
		return 1

/mob/living/simple_animal/farm/harvest(mob/living/user)
	if(qdeleted(src))
		return
	if(butcher_results && dna)
		for(var/path in butcher_results)
			for(var/i = 1; i <= round(butcher_results[path] + (dna.yield / 2));i++)
				new path(src.loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
	visible_message("<span class='notice'>[user] butchers [src].</span>")
	gib()

/mob/living/simple_animal/farm/death()
	..()
	if(src)
		for(var/datum/farm_animal_trait/T in dna.traits)
			T.on_death(src)
		if(buckled_mob)
			unbuckle_mob()
		if(icon_living == icon_dead) // no icon for death? gib he
			gib()

/mob/living/simple_animal/farm/Move()
	..()
	handle_riding_layer()
	handle_riding_offsets()
	for(var/datum/farm_animal_trait/T in dna.traits)
		T.on_move(src)

/mob/living/simple_animal/farm/unbuckle_mob(force = 0)
	if(buckled_mob)
		animate(buckled_mob, pixel_x = 0, time = 5)
		animate(buckled_mob, pixel_y = 0, time = 5)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	. = ..()

/mob/living/simple_animal/farm/relaymove(mob/user, direction)
	if(stat)
		unbuckle_mob()
	if(user.incapacitated())
		unbuckle_mob()

	if(!Process_Spacemove(direction) || !has_gravity(src.loc) || world.time < next_riding_move || !isturf(loc))
		return
	next_riding_move = world.time + riding_move_delay

	step(src, direction)

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	handle_riding_layer()
	handle_riding_offsets()

/mob/living/simple_animal/farm/user_buckle_mob(mob/living/M, mob/user)
	if(user.incapacitated())
		return
	if(stat)
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.loc = get_turf(src)
	..()
	handle_riding_offsets()

/mob/living/simple_animal/farm/Bump(atom/movable/M)
	. = ..()
	if(auto_door_open)
		if(istype(M, /obj/machinery/door) && buckled_mob)
			M.Bumped(buckled_mob)