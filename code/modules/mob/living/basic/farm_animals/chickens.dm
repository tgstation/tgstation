/mob/living/basic/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	density = FALSE
	speak_emote = list("cheeps")
	speed = 1.5
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
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

	ai_controller = /datum/ai_controller/basic_controller/chick

/mob/living/basic/chick/Initialize()
	. = ..()
	AddElement(/datum/element/pet_bonus, "chirps!")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	addtimer(CALLBACK(src, .proc/hologram_check), 1)

///waits until the next tick for this check as we won't know if we're holographic on init
/mob/living/basic/chick/proc/hologram_check()
	if(!(flags_1 & HOLOGRAM_1))
		AddComponent(/datum/component/growing_up, /mob/living/basic/chicken, 100)

/datum/ai_controller/basic_controller/chick

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

	//IMPLEMENT IDLE BEHAVIOR HERE

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/chick,
	)

//REMOVE THIS
/datum/ai_controller/basic_controller/chick/PerformIdleBehavior(delta_time)
	. = ..()
	var/mob/living/living_pawn = pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

/mob/living/basic/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	density = FALSE
	speed = 1
	speak_emote = list("clucks","croons")
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

	ai_controller = /datum/ai_controller/basic_controller/chicken

	///counter for how many chickens are in existence to stop too many chickens from lagging shit up
	var/static/chicken_count = 0
	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/process_eggs = TRUE

/mob/living/basic/chicken/Initialize()
	. = ..()
	chicken_count++
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
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

/mob/living/basic/chicken/Destroy()
	chicken_count--
	return ..()

/mob/living/basic/chicken/proc/egg_laid(obj/item/egg)
	if(chicken_count <= MAX_CHICKENS && process_eggs && prob(25))
		START_PROCESSING(SSobj, egg)

/datum/ai_controller/basic_controller/chicken

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

	//IMPLEMENT IDLE BEHAVIOR HERE

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/chicken,
	)

//REMOVE THIS
/datum/ai_controller/basic_controller/chicken/PerformIdleBehavior(delta_time)
	. = ..()
	var/mob/living/living_pawn = pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
