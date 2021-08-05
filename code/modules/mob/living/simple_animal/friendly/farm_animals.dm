//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays.")
	emote_see = list("shakes their head.", "stamps a foot.", "glares around.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list("neutral")
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	attack_same = 1
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 40
	maxHealth = 40
	minbodytemp = 180
	melee_damage_lower = 1
	melee_damage_upper = 2
	environment_smash = ENVIRONMENT_SMASH_NONE
	stop_automated_movement_when_pulled = 1
	blood_volume = BLOOD_VOLUME_NORMAL

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/goat/Initialize()
	AddComponent(/datum/component/udder)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && DT_PROB(0.5, delta_time))
			Retaliate()

		if(enemies.len && DT_PROB(5, delta_time))
			enemies.Cut()
			LoseTarget()
			src.visible_message(span_notice("[src] calms down."))
	if(stat != CONSCIOUS)
		return

	eat_plants()
	if(pulledby)
		return

	for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
		var/step = get_step(src, direction)
		if(step && ((locate(/obj/structure/spacevine) in step) || (locate(/obj/structure/glowshroom) in step)))
			Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message(span_danger("[src] gets an evil-looking gleam in [p_their()] eye."))

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	. = ..()
	if(!stat)
		eat_plants()

/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/eaten = FALSE
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		eaten = TRUE

	var/obj/structure/glowshroom/GS = locate(/obj/structure/glowshroom) in loc
	if(GS)
		qdel(GS)
		eaten = TRUE

	if(eaten && prob(10))
		say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.dna.species, /datum/species/pod))
			var/obj/item/bodypart/NB = pick(H.bodyparts)
			H.visible_message(span_warning("[src] takes a big chomp out of [H]!"), \
								  span_userdanger("[src] takes a big chomp out of your [NB]!"))
			NB.dismember()
//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays.")
	emote_see = list("shakes her head.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/cow/Initialize()
	AddComponent(/datum/component/udder)
	AddComponent(/datum/component/tippable, \
		tip_time = 0.5 SECONDS, \
		untip_time = 0.5 SECONDS, \
		self_right_time = rand(25 SECONDS, 50 SECONDS), \
		post_tipped_callback = CALLBACK(src, .proc/after_cow_tipped))
	AddElement(/datum/element/pet_bonus, "moos happily!")
	add_cell_sample()
	make_tameable()
	. = ..()

///wrapper for the tameable component addition so you can have non tamable cow subtypes
/mob/living/simple_animal/cow/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/grown/wheat), tame_chance = 25, bonus_tame_chance = 15, after_tame = CALLBACK(src, .proc/tamed))

/mob/living/simple_animal/cow/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_COW, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/cow/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/cow)

/*
 * Proc called via callback after the cow is tipped by the tippable component.
 * Begins a timer for us pleading for help.
 *
 * tipper - the mob who tipped us
 */
/mob/living/simple_animal/cow/proc/after_cow_tipped(mob/living/carbon/tipper)
	addtimer(CALLBACK(src, .proc/look_for_help, tipper), rand(10 SECONDS, 20 SECONDS))

/*
 * Find a mob in a short radius around us (prioritizing the person who originally tipped us)
 * and either look at them for help, or give up. No actual mechanical difference between the two.
 *
 * tipper - the mob who originally tipped us
 */
/mob/living/simple_animal/cow/proc/look_for_help(mob/living/carbon/tipper)
	// visible part of the visible message
	var/seen_message = ""
	// self part of the visible message
	var/self_message = ""
	// the mob we're looking to for aid
	var/mob/living/carbon/savior
	// look for someone in a radius around us for help. If our original tipper is in range, prioritize them
	for(var/mob/living/carbon/potential_aid in oview(3, get_turf(src)))
		if(potential_aid == tipper)
			savior = tipper
			break
		savior = potential_aid

	if(prob(75) && savior)
		var/text = pick("imploringly", "pleadingly", "with a resigned expression")
		seen_message = "[src] looks at [savior] [text]."
		self_message = "You look at [savior] [text]."
	else
		seen_message = "[src] seems resigned to its fate."
		self_message = "You resign yourself to your fate."
	visible_message(span_notice("[seen_message]"), span_notice("[self_message]"))

///Wisdom cow, gives XP to a random skill and speaks wisdoms
/mob/living/simple_animal/cow/wisdom
	name = "wisdom cow"
	desc = "Known for its wisdom, shares it with all"
	gold_core_spawnable = FALSE
	speak_chance = 15

/mob/living/simple_animal/cow/wisdom/Initialize()
	. = ..()
	speak = GLOB.wisdoms //Done here so it's setup properly

/mob/living/simple_animal/cow/wisdom/make_tameable()
	return //cannot tame

///Give intense wisdom to the attacker if they're being friendly about it
/mob/living/simple_animal/cow/wisdom/attack_hand(mob/living/carbon/user, list/modifiers)
	if(!stat && !user.combat_mode)
		to_chat(user, span_nicegreen("[src] whispers you some intense wisdoms and then disappears!"))
		user.mind?.adjust_experience(pick(GLOB.skill_types), 500)
		do_smoke(1, get_turf(src))
		qdel(src)
		return
	return ..()


/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground.","flaps her tiny wings.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	health = 3
	maxHealth = 3
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/chick/Initialize()
	. = ..()
	AddElement(/datum/element/pet_bonus, "chirps!")
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	add_cell_sample()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/chick/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/chick/Life(delta_time = SSMOBS_DT, times_fired)
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(0.5 * delta_time, 1 * delta_time)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)

/mob/living/simple_animal/chick/holo/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	amount_grown = 0


/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks.")
	emote_see = list("pecks at the ground.","flaps her wings viciously.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	health = 15
	maxHealth = 15
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	///counter for how many chickens are in existence to stop too many chickens from lagging shit up
	var/static/chicken_count = 0
	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/process_eggs = TRUE

/mob/living/simple_animal/chicken/Initialize()
	. = ..()
	chicken_count++
	add_cell_sample()
	AddElement(/datum/element/animal_variety, "chicken", pick("brown","black","white"), TRUE)
	AddComponent(/datum/component/egg_layer,\
		/obj/item/food/egg,\
		list(/obj/item/food/grown/wheat),\
		feed_messages = list("She clucks happily."),\
		lay_messages = EGG_LAYING_MESSAGES,\
		eggs_left = 0,\
		eggs_added_from_eating = rand(1, 4),\
		max_eggs_held = 8,\
		egg_laid_callback = CALLBACK(src, .proc/egg_laid)\
	)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/chicken/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/chicken/Destroy()
	chicken_count--
	return ..()

/mob/living/simple_animal/chicken/proc/egg_laid(obj/item/egg)
	if(chicken_count <= MAX_CHICKENS && process_eggs && prob(25))
		START_PROCESSING(SSobj, egg)

/obj/item/food/egg/var/amount_grown = 0

/obj/item/food/egg/process(delta_time)
	if(isturf(loc))
		amount_grown += rand(1,2) * delta_time
		if(amount_grown >= 200)
			visible_message(span_notice("[src] hatches with a quiet cracking sound."))
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/simple_animal/deer
	name = "doe"
	desc = "A gentle, peaceful forest animal. How did this get into space?"
	icon_state = "deer-doe"
	icon_living = "deer-doe"
	icon_dead = "deer-doe-dead"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak = list("Weeeeeeee?","Weeee","WEOOOOOOOOOO")
	speak_emote = list("grunts","grunts lowly")
	emote_hear = list("brays.")
	emote_see = list("shakes her head.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently nudges"
	response_disarm_simple = "gently nudges aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "bucks"
	attack_verb_simple = "buck"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 75
	maxHealth = 75
	blood_volume = BLOOD_VOLUME_NORMAL
	footstep_type = FOOTSTEP_MOB_SHOE
