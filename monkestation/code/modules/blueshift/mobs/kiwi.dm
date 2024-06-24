/mob/living/basic/kiwi
	name = "kiwi"
	desc = "It's a kiwi!"
	icon = 'monkestation/code/modules/blueshift/icons/mob/newmobs.dmi'
	icon_state = "kiwi"
	icon_living = "kiwi"
	icon_dead = "kiwi_dead"
	maxHealth = 15
	health = 15
	density = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "moves aside"
	response_disarm_simple = "move aside"
	response_harm_continuous = "smacks"
	response_harm_simple = "smack"
	friendly_verb_continuous = "boops"
	friendly_verb_simple = "boop"
	verb_say = "cheep"
	verb_ask = "cheeps inquisitively"
	verb_exclaim = "cheeps loudly"
	verb_yell = "screeches"

	ai_controller = /datum/ai_controller/basic_controller/kiwi

/mob/living/basic/kiwi/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "cheeps happily!")

/datum/ai_controller/basic_controller/kiwi
	blackboard = list()

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/kiwi,
	)

/datum/ai_planning_subtree/random_speech/kiwi
	speech_chance = 5
	emote_hear = list("makes a loud cheep.", "cheeps happily.")
	emote_see = list("runs around.")
	speak = list("cheep", "cheep cheep!")
