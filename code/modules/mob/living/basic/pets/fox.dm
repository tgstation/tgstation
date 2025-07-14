/* Foxes.
*
* Foxes are cowardly creatures that will hunt any small animals, but only when no one is looking.
*/

/mob/living/basic/pet/fox
	name = "fox"
	desc = "They're a fox."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak_emote = list("geckers", "barks")
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	held_state = "fox"
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	ai_controller = /datum/ai_controller/basic_controller/fox
	///list of our pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/move,
		/datum/pet_command/free,
		/datum/pet_command/follow/start_active,
		/datum/pet_command/attack,
		/datum/pet_command/perform_trick_sequence,
	)

/datum/emote/fox
	mob_type_allowed_typecache = /mob/living/basic/pet/fox
	mob_type_blacklist_typecache = list()

/datum/emote/fox/yap
	key = "yap"
	key_third_person = "yaps"
	message = "yaps happily!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/mob/living/basic/pet/fox/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddElement(/datum/element/cultist_pet)
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/pet_bonus, "yap")
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/tiny_mob_hunter, MOB_SIZE_SMALL)
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/fox
	blackboard = list(
		BB_ALWAYS_IGNORE_FACTION = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/ours_or_smaller,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/simple_find_target/not_while_observed,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/fox,
	)

// An AI controller for more docile foxes.
/datum/ai_controller/basic_controller/fox/docile
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/random_speech/fox,
	)

// The captain's fox, Renault
/mob/living/basic/pet/fox/renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox."
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

// A more docile subtype that won't attack other animals.
/mob/living/basic/pet/fox/docile
	ai_controller = /datum/ai_controller/basic_controller/fox/docile

/mob/living/basic/pet/fox/icemoon
	name = "icemoon fox"
	desc = "A fox, scraping by the icemoon hostile atmosphere."
	gold_core_spawnable = NO_SPAWN
	habitable_atmos = null
	minimum_survivable_temperature = ICEBOX_MIN_TEMPERATURE
