/mob/living/basic/construct/artificer
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar'Sie's armies."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm_continuous = "viciously beats"
	response_harm_simple = "viciously beat"
	obj_damage = 60
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "rams"
	attack_verb_simple = "ram"
	attack_sound = 'sound/items/weapons/punch2.ogg'
	construct_spells = list(
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone,
		/datum/action/innate/cult/create_rune/revive,
	)
	playstyle_string = "<b>You are an Artificer. You are incredibly weak and fragile, \
		but you are able to construct fortifications, use magic missile, and repair allied constructs, shades, \
		and yourself (by clicking on them). Additionally, <i>and most important of all,</i> you can create new constructs \
		by producing soulstones to capture souls, and shells to place those soulstones into.</b>"

	can_repair = TRUE
	can_repair_self = TRUE
	smashes_walls = TRUE

/mob/living/basic/construct/artificer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	ADD_TRAIT(src, TRAIT_MEDICAL_HUD, INNATE_TRAIT)

/// Hostile NPC version. Heals nearby constructs and cult structures, avoids targets that aren't extremely hurt.
/mob/living/basic/construct/artificer/hostile
	ai_controller = /datum/ai_controller/basic_controller/artificer
	smashes_walls = FALSE
	melee_attack_cooldown = 2 SECONDS

// Alternate artificer themes
/mob/living/basic/construct/artificer/angelic
	desc = "A bulbous construct dedicated to building and maintaining holy armies."
	faction = list(FACTION_HOLY)
	theme = THEME_HOLY
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/soulstone/purified,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)

/mob/living/basic/construct/artificer/angelic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANGELIC, INNATE_TRAIT)

/mob/living/basic/construct/artificer/mystic
	faction = list(ROLE_WIZARD)
	theme = THEME_WIZARD
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone/mystic,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)

/mob/living/basic/construct/artificer/noncult
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone/noncult,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)
