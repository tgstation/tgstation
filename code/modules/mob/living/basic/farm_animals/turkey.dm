/* ## Turkeys
*
* Large, mostly flightless birds that gobble. Butcher one for a whole raw turkey to roast in an oven.
*/
/mob/living/basic/turkey
	name = "turkey"
	desc = "A big, proud bird."
	icon = 'icons/mob/simple/turkey.dmi'
	icon_state = "turkey_male"
	icon_living = "turkey_male"
	icon_dead = "turkey_m_dead"
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("gobbles", "clucks")
	butcher_results = list(/obj/item/food/raw_turkey = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	friendly_verb_continuous = "headbutts"
	friendly_verb_simple = "headbutt"
	melee_damage_lower = 1
	melee_damage_upper = 3
	health = 30
	maxHealth = 30
	gold_core_spawnable = FRIENDLY_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/turkey

/datum/emote/turkey
	abstract_type = /datum/emote/turkey
	mob_type_allowed_typecache = /mob/living/basic/turkey
	mob_type_blacklist_typecache = list()

/datum/emote/turkey/gobble
	key = "gobble"
	key_third_person = "gobbles"
	message = "gobbles!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	/// The words the turkey can say
	var/list/gobble_messages = list("gobbles!", "gobble gobbles!", "GOBBLES!")

/datum/emote/turkey/gobble/select_message_type(mob/user, message, intentional)
	. = ..()
	return pick(gobble_messages)

/mob/living/basic/turkey/Initialize(mapload)
	. = ..()
	if(gender == FEMALE)
		icon_state = "turkey_female"
		icon_living = "turkey_female"
		icon_dead = "turkey_f_dead"
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/pet_bonus, "gobble")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/datum/ai_controller/basic_controller/turkey
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/turkey.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Gobble!", "Gobble gobble!", "Gobble?", "GOBBLE GOBBLE GOBBLE"),
			BB_EMOTE_HEAR = list("gobbles.", "clucks."),
			BB_EMOTE_SEE = list("fans out its tail feathers.", "pecks at the ground."),
			BB_SPEAK_CHANCE = 3,
		),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
