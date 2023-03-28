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
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list(FACTION_NEUTRAL)
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

/mob/living/simple_animal/hostile/retaliate/goat/Initialize(mapload)
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
		var/turf/step = get_step(src, direction)

		if(!istype(step))
			return

		var/vine = locate(/obj/structure/spacevine) in step
		var/mushroom = locate(/obj/structure/glowshroom) in step
		var/flower = locate(/obj/structure/alien/resin/flower_bud) in step

		if(vine || mushroom || flower)
			Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message(span_danger("[src] gets an evil-looking gleam in [p_their()] eye."))

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	. = ..()
	if(!stat)
		eat_plants()

/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/obj/structure/spacevine/vine = locate(/obj/structure/spacevine) in loc
	if(vine)
		vine.eat(src)

	var/obj/structure/alien/resin/flower_bud/flower = locate(/obj/structure/alien/resin/flower_bud) in loc
	if(flower)
		flower.take_damage(rand(30, 50), BRUTE, 0)

	var/obj/structure/glowshroom/mushroom = locate(/obj/structure/glowshroom) in loc
	if(mushroom)
		qdel(mushroom)

	if((vine || flower || mushroom) && prob(10))
		say("Nom") // bon appetit
		playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)

/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()

	if(!. || !isliving(target))
		return

	var/mob/living/plant_target = target
	if(!(plant_target.mob_biotypes & MOB_PLANT))
		return

	plant_target.adjustBruteLoss(20)
	playsound(src, 'sound/items/eatfood.ogg', rand(30, 50), TRUE)
	var/obj/item/bodypart/edible_bodypart

	if(ishuman(plant_target))
		var/mob/living/carbon/human/plant_man = target
		edible_bodypart = pick(plant_man.bodyparts)
		edible_bodypart.dismember()

	plant_target.visible_message(span_warning("[src] takes a big chomp out of [plant_target]!"), \
							span_userdanger("[src] takes a big chomp out of your [edible_bodypart || "body"]!"))


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

/mob/living/simple_animal/chick/Initialize(mapload)
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

/// Counter for number of chicken mobs in the universe. Chickens will not lay fertile eggs if it exceeds the MAX_CHICKENS define.
GLOBAL_VAR_INIT(chicken_count, 0)

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
	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/fertile = TRUE

/mob/living/simple_animal/chicken/Initialize(mapload)
	. = ..()
	GLOB.chicken_count++
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
		egg_laid_callback = CALLBACK(src, PROC_REF(egg_laid))\
	)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/chicken/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/chicken/Destroy()
	GLOB.chicken_count--
	return ..()

/mob/living/simple_animal/chicken/proc/egg_laid(obj/item/egg)
	if(GLOB.chicken_count <= MAX_CHICKENS && fertile && prob(25))
		egg.AddComponent(/datum/component/fertile_egg,\
			embryo_type = /mob/living/simple_animal/chick,\
			minimum_growth_rate = 1,\
			maximum_growth_rate = 2,\
			total_growth_required = 200,\
			current_growth = 0,\
			location_allowlist = typecacheof(list(/turf)),\
			spoilable = TRUE,\
		)

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
