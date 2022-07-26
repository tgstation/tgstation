/mob/living/simple_animal/mothroach
	name = "mothroach"
	desc = "An ancient ancestor of the moth that surprisingly looks like the crossbreed of a moth and a cockroach."
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	held_state = "mothroach"
	held_lh = 'icons/mob/animal_item_lh.dmi'
	held_rh = 'icons/mob/animal_item_rh.dmi'
	head_icon = 'icons/mob/animal_item_head.dmi'
	butcher_results = list(/obj/item/food/meat/slab/mothroach = 3, /obj/item/stack/sheet/animalhide/mothroach = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	density = TRUE
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	mob_size = MOB_SIZE_SMALL
	health = 25
	maxHealth = 25
	speed = 1.25
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD

	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters loudly"
	verb_yell = "flutters loudly"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "hits"
	response_harm_simple = "hit"
	response_help_continuous = "pats"
	response_help_simple = "pat"
	speak_emote = list("flutters")
	attacked_sound = 'sound/voice/moth/scream_moth.ogg'

	faction = list("neutral")

	ai_controller = /datum/ai_controller/basic_controller/cockroach

/mob/living/simple_animal/mothroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/basic_body_temp_sensitive, 250, INFINITY)
	add_verb(src, /mob/living/proc/toggle_resting)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/mothroach/toggle_resting()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]_rest"
	else
		icon_state = "[icon_living]"
	regenerate_icons()

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech,
		/datum/ai_planning_subtree/find_and_hunt_target
)
