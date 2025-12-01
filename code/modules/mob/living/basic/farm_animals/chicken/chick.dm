/**
 * ## Chicks
 *
 * Baby birds that grow into big chickens.
 */
/mob/living/basic/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("cheeps")
	density = FALSE
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
	ai_controller = /datum/ai_controller/basic_controller/chick

	/// What we grow into.
	var/grow_as = /mob/living/basic/chicken

/datum/emote/chick
	mob_type_allowed_typecache = /mob/living/basic/chick
	mob_type_blacklist_typecache = list()

/datum/emote/chick/chirp
	key = "chirp"
	key_third_person = "chirps"
	message = "chirps!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/chicken/chick_peep.ogg'

/mob/living/basic/chick/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	AddElement(/datum/element/pet_bonus, "chirp")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

	if(!isnull(grow_as)) // we don't have a set time to grow up beyond whatever RNG dictates, and if we somehow get a client, all growth halts.
		AddComponent(\
			/datum/component/growth_and_differentiation,\
			growth_time = null,\
			growth_path = grow_as,\
			growth_probability = 100,\
			lower_growth_value = 0.5,\
			upper_growth_value = 1,\
			signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
			optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		)

/// We don't grow into a chicken if we're not conscious.
/mob/living/basic/chick/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/// Variant of chick that just spawns in the holodeck so you can pet it. Doesn't grow up.
/mob/living/basic/chick/permanent
	grow_as = null

/datum/ai_controller/basic_controller/chick
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/chicken),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/look_for_adult,
	)
