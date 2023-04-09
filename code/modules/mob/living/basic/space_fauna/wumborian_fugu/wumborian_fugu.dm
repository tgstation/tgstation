/**
 * # Wumborian Fugu
 *
 * A strange alien creature capable of increasing its mass when threatened, when not inflated it is virtually defenceless.
 * Mostly only appears from xenobiology, or the occasional wizard.
 * On death, the "fugu gland" is dropped, which can be used on mobs to increase their size, health, strength, and lets them smash walls.
 */
/mob/living/basic/wumborian_fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/simple/lavaland/64x64megafauna.dmi'
	icon_state = "Fugu0"
	icon_living = "Fugu0"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	health_doll_icon = "Fugu0"
	pixel_x = -16
	base_pixel_x = -16
	status_flags = NONE
	gold_core_spawnable = HOSTILE_SPAWN
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_SMALL
	speed = 0
	maxHealth = 50
	health = 50
	combat_mode = TRUE
	obj_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	friendly_verb_continuous = "floats near"
	friendly_verb_simple = "float near"
	speak_emote = list("puffs")
	faction = list(FACTION_MINING)
	see_in_dark = 8
	// Nice and dark purple, to match le vibes
	lighting_cutoff_red = 20
	lighting_cutoff_green = 10
	lighting_cutoff_blue = 40
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	ai_controller = /datum/ai_controller/basic_controller/wumborian_fugu
	/// Ability used by the mob to become large, dangerous, and invulnerable
	var/datum/action/cooldown/fugu_expand/expand

/mob/living/basic/wumborian_fugu/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, loot = list(/obj/item/fugu_gland))
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, ROUNDSTART_TRAIT)
	expand = new(src)
	expand.Grant(src)
	ai_controller.blackboard[BB_FUGU_INFLATE] = WEAKREF(expand)

/mob/living/basic/wumborian_fugu/Destroy()
	QDEL_NULL(expand)
	return ..()
