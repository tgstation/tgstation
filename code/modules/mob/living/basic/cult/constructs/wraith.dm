/mob/living/basic/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked, clawed shell constructed to assassinate enemies and sow chaos behind enemy lines."
	icon_state = "wraith"
	icon_living = "wraith"
	maxHealth = 65
	health = 65
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift,
		/datum/action/innate/cult/create_rune/tele,
	)
	playstyle_string = span_bold("You are a Wraith. Though relatively fragile, you are fast, deadly, and can phase through walls. Your attacks will lower the cooldown on phasing, moreso for fatal blows.")

/mob/living/basic/construct/wraith/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/jaunt = locate() in actions
	if(isnull(jaunt))
		return .
	AddComponent(/datum/component/recharging_attacks, recharged_action = jaunt)

/// Hostile NPC version. Attempts to kill the lowest-health mob it can see.
/mob/living/basic/construct/wraith/hostile
	ai_controller = /datum/ai_controller/basic_controller/wraith
	melee_attack_cooldown = 1.5 SECONDS

// Alternate wraith themes
/mob/living/basic/construct/wraith/angelic
	theme = THEME_HOLY
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/angelic,
		/datum/action/innate/cult/create_rune/tele,
	)

/mob/living/basic/construct/wraith/angelic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANGELIC, INNATE_TRAIT)

/mob/living/basic/construct/wraith/mystic
	theme = THEME_WIZARD
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift/mystic,
		/datum/action/innate/cult/create_rune/tele,
	)
