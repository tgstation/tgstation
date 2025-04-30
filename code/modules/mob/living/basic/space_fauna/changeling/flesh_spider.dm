/**
 * Spider-esque mob summoned by changelings. Exclusively player-controlled.
 * An independent hit-and-run antagonist which can make webs and heals itself if left undamaged for a few seconds.
 * Not a spider subtype because it keeps getting hit by unrelated balance changes intended for the Giant Spiders gamemode.
 */
/mob/living/basic/flesh_spider
	name = "flesh spider"
	desc = "A odd fleshy creature in the shape of a spider. Its eyes are pitch black and soulless."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "flesh"
	icon_living = "flesh"
	icon_dead = "flesh_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	speak_emote = list("chitters")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	damage_coeff = list(BRUTE = 1, BURN = 1.25, TOX = 1, STAMINA = 1, OXY = 1)
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = NONE
	speed = -0.1
	maxHealth = 90
	health = 90
	melee_damage_lower = 15
	melee_damage_upper = 20
	obj_damage = 30
	melee_attack_cooldown = CLICK_CD_MELEE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	unsuitable_cold_damage = 4
	unsuitable_heat_damage = 4
	combat_mode = TRUE
	faction = list() // No allies but yourself
	pass_flags = PASSTABLE
	unique_name = TRUE
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	ai_controller = /datum/ai_controller/basic_controller/giant_spider
	max_stamina = 200
	stamina_crit_threshold = BASIC_MOB_NO_STAMCRIT
	stamina_recovery = 5
	max_stamina_slowdown = 12

/mob/living/basic/flesh_spider/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEB_SURFER, INNATE_TRAIT)
	AddElement(/datum/element/cliff_walking)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/venomous, /datum/reagent/toxin/hunterspider, 5, injection_flags = INJECT_CHECK_PENETRATE_THICK)
	AddElement(/datum/element/web_walker, /datum/movespeed_modifier/fast_web)
	AddElement(/datum/element/nerfed_pulling, GLOB.typecache_general_bad_things_to_easily_move)
	AddElement(/datum/element/prevent_attacking_of_types, GLOB.typecache_general_bad_hostile_attack_targets, "this tastes awful!")
	AddComponent(\
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood/bubblegum,\
		blood_spawn_chance = 5,\
	)
	AddComponent(\
		/datum/component/regenerator,\
		regeneration_delay = 4 SECONDS,\
		brute_per_second = maxHealth / 6,\
		outline_colour = COLOR_PINK,\
	)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/lay_web = BB_SPIDER_WEB_ACTION,
		/datum/action/cooldown/mob_cooldown/lay_web/sticky_web = null,
		/datum/action/cooldown/mob_cooldown/lay_web/web_spikes = null,
	)
	grant_actions_by_list(innate_actions)

/datum/action/cooldown/mob_cooldown/lay_web/flesh
	webbing_time = 3 SECONDS
