/mob/living/basic/bunyip
	name = "bunyip"
	desc = "Some Ionians call this thing a rare, mythical creature, but it's really just some freak ass creature who's entire self worth is dependant on how much chaos it can cause."
	icon = 'troutstation/icons/mob/simple/skitterer.dmi'
	icon_state = "bunyip"
	icon_living = "bunyip"
	icon_dead = "bunyip_dead"
	speak_emote = list("yaps","yips","chatters")
	response_harm_continuous = "thwacks"
	response_harm_simple = "thwack"
	butcher_results = list(/obj/item/food/meat/slab = 1)
	response_help_continuous = "prods"
	response_help_simple = "prod"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "thwacks"
	response_harm_simple = "thwack"
	attack_verb_continuous = "thwacks"
	attack_verb_simple = "thwack"
	speed = -0.6
	mob_biotypes = MOB_ORGANIC
	mob_size = MOB_SIZE_SMALL
	faction = list(FACTION_SKITTER)
	gold_core_spawnable = FRIENDLY_SPAWN

	health = 50
	maxHealth = 50
	melee_damage_lower = 1
	melee_damage_upper = 4
	obj_damage = 1
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES

	attack_sound = 'troutstation/sound/mobs/non-humanoids/skitterer/bunyip_attack.ogg'
	attacked_sound = 'troutstation/sound/mobs/non-humanoids/skitterer/bunyip_attack.ogg'
	ai_controller = /datum/ai_controller/basic_controller/bunyip // ?

/mob/living/basic/bunyip/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SKITTER)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/dextrous, hands_count = 2, can_throw = TRUE)
	var/static/list/display_emote = list(
		BB_EMOTE_SAY = list("Wah...","Wark!","Ehehe..."),
		BB_EMOTE_SEE = list("cheers for itself!", "looks around for something to grab.", "does a little jig!"),
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SOUND = list('troutstation/sound/mobs/non-humanoids/skitterer/bunyip.ogg'),
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)

	AddComponent(\
		/datum/component/ghost_direct_control,\
		poll_candidates = TRUE,\
		role_name = "Bunyip",\
		poll_ignore_key = POLL_IGNORE_GAY_SKITTERER,\
		assumed_control_message = "You are a bunyip. You're a bit of a mischief maker, ain't cha?",\
		poll_length = 30 SECONDS,\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
		poll_chat_border_icon = /mob/living/basic/bunyip,\
	)

/mob/living/basic/bunyip/proc/became_player_controlled()
	notify_ghosts(
		"A bunyip has gained sentience in \the [get_area(src)].",
		source = src,
		header = "Bunyip Sentience",
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
	)

/datum/ai_controller/basic_controller/bunyip
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_GUILTY_CONSCIOUS_CHANCE = 3,
		BB_STEAL_CHANCE = 15,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/more_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/steal_items,
		/datum/ai_planning_subtree/random_speech/blackboard,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
