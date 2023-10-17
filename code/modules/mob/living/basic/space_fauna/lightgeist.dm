/**
 * ## Lightgeists
 *
 * Small critters meant to heal other living mobs and unable to interact with almost everything else.
 *
 */
/mob/living/basic/lightgeist
	name = "lightgeist"
	desc = "This small floating creature is a completely unknown form of life... being near it fills you with a sense of tranquility."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	response_help_continuous = "waves away"
	response_help_simple = "wave away"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brush aside"
	response_harm_continuous = "disrupts"
	response_harm_simple = "disrupt"
	speak_emote = list("oscillates")
	maxHealth = 2
	health = 2
	melee_damage_lower = 5
	melee_damage_upper = 5
	melee_attack_cooldown = 5 SECONDS
	friendly_verb_continuous = "taps"
	friendly_verb_simple = "tap"
	density = FALSE
	basic_mob_flags = DEL_ON_DEATH
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "warps"
	verb_ask = "floats inquisitively"
	verb_exclaim = "zaps"
	verb_yell = "bangs"
	initial_language_holder = /datum/language_holder/lightbringer
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	light_range = 4
	faction = list(FACTION_NEUTRAL)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

	ai_controller = /datum/ai_controller/basic_controller/lightgeist

/mob/living/basic/lightgeist/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	remove_verb(src, /mob/living/verb/pulled)
	remove_verb(src, /mob/verb/me_verb)

	var/datum/atom_hud/medical_sensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medical_sensor.show_to(src)

	AddElement(/datum/element/simple_flying)
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage_upper,\
		heal_burn = melee_damage_upper,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living)),\
		action_text = "%SOURCE% begins mending the wounds of %TARGET%",\
		complete_text = "%TARGET%'s wounds mend together.",\
	)

/mob/living/basic/lightgeist/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if (. && isliving(target))
		faction |= REF(target) // Anyone we heal will treat us as a friend

/mob/living/basic/lightgeist/ghost()
	. = ..()
	if(.)
		death()

/datum/ai_controller/basic_controller/lightgeist
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/lightgeist,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree, // We heal things by attacking them
	)

/// Attack only mobs who have damage that we can heal, I think this is specific enough not to be a generic type
/datum/targetting_datum/lightgeist
	/// Types of mobs we can heal, not in a blackboard key because there is no point changing this at runtime because the component will already exist
	var/heal_biotypes = MOB_ORGANIC | MOB_MINERAL
	/// Type of limb we can heal
	var/required_bodytype = BODYTYPE_ORGANIC

/datum/targetting_datum/lightgeist/can_attack(mob/living/living_mob, mob/living/target, vision_range)
	if (!isliving(target) || target.stat == DEAD)
		return FALSE
	if (!(heal_biotypes & target.mob_biotypes))
		return FALSE
	if (!iscarbon(target))
		return target.getBruteLoss() > 0 || target.getFireLoss() > 0
	var/mob/living/carbon/carbon_target = target
	for (var/obj/item/bodypart/part in carbon_target.bodyparts)
		if (!part.brute_dam && !part.burn_dam)
			continue
		if (!(part.bodytype & required_bodytype))
			continue
		return TRUE
	return FALSE
