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

	// player controlled only, so no AI. can probably be changed in the future if you so desire.

/mob/living/basic/lightgeist/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	remove_verb(src, /mob/living/verb/pulled)
	remove_verb(src, /mob/verb/me_verb)

	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.show_to(src)

	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ladder_climber)
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage_upper,\
		heal_burn = melee_damage_upper,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living)),\
		action_text = "%SOURCE% begins mending the wounds of %TARGET%",\
		complete_text = "%TARGET%'s wounds mend together.",\
	)


/mob/living/basic/lightgeist/ghost()
	. = ..()
	if(.)
		death()

