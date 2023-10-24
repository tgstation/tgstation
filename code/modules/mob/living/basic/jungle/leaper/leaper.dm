/mob/living/basic/leaper
	name = "leaper"
	desc = "Commonly referred to as 'leapers', the Geron Toad is a massive beast that spits out highly pressurized bubbles containing a unique toxin, knocking down its prey and then crushing it with its girth."
	icon = 'icons/mob/simple/jungle/leaper.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_dead = "leaper_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 500
	health = 500
	speed = 10

	pixel_x = -16
	base_pixel_x = -16

	faction = list(FACTION_JUNGLE)
	obj_damage = 30

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY

	status_flags = NONE
	lighting_cutoff_red = 5
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 25
	mob_size = MOB_SIZE_LARGE
	///appearance when we dead
	var/mutable_appearance/dead_overlay
	///appearance when we are alive
	var/mutable_appearance/living_overlay


/mob/living/basic/leaper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/wall_smasher)
	AddElement(/datum/element/ridable, /datum/component/riding/creature/leaper)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_HEAVY)
	var/datum/action/cooldown/mob_cooldown/blood_rain/volley = new(src)
	volley.Grant(src)
	var/datum/action/cooldown/mob_cooldown/belly_flop/flop = new(src)
	flop.Grant(src)
	var/datum/action/cooldown/mob_cooldown/projectile_attack/leaper_bubble/bubble = new(src)
	bubble.Grant(src)
	var/datum/action/cooldown/spell/conjure/limit_summons/create_suicide_toads/toads = new(src)
	toads.Grant(src)


/mob/living/basic/leaper/proc/set_color_overlay(toad_color)
	dead_overlay = mutable_appearance(icon, "[icon_state]_dead_overlay")
	dead_overlay.color = toad_color

	living_overlay = mutable_appearance(icon, "[icon_state]_overlay")
	living_overlay.color = toad_color
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/leaper/update_overlays()
	. = ..()
	if(stat == DEAD && dead_overlay)
		. += dead_overlay
		return

	if(living_overlay)
		. += living_overlay

/mob/living/basic/leaper/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, LEAPING_TRAIT)
	return ..()

/mob/living/basic/leaper/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LEAPING_TRAIT)
