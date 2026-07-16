#define HEARTBEAT_NORMAL (1.8 SECONDS)
#define HEARTBEAT_FAST (1 SECONDS)
#define HEARTBEAT_FRANTIC (0.4 SECONDS)

GLOBAL_LIST_INIT(tendrils, list())

/mob/living/basic/mining/tendril
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground."
	icon = 'icons/mob/simple/lavaland/tendril.dmi'
	icon_state = "tendril"
	icon_living = "tendril"
	pixel_w = -8
	base_pixel_w = -8
	status_flags = NONE
	mob_biotypes = MOB_ORGANIC | MOB_SKELETAL | MOB_MINING | MOB_SPECIAL
	basic_mob_flags = DEL_ON_DEATH | IMMUNE_TO_FISTS
	mob_size = MOB_SIZE_HUGE
	maxHealth = 800
	health = 800

	friendly_verb_continuous = "flails at"
	friendly_verb_simple = "flail at"
	speak_emote = list("resonates")
	obj_damage = 100
	melee_damage_lower = 20
	melee_damage_upper = 20
	sharpness = SHARP_POINTY
	wound_bonus = CANT_WOUND
	attack_sound = 'sound/items/weapons/pierce.ogg'
	attack_verb_continuous = "pierces through"
	attack_verb_simple = "pierce through"
	throw_blocked_message = "does nothing to the thick shell of"
	move_resist = INFINITY

	light_range = 3
	light_power = 2
	light_color = LIGHT_COLOR_LAVA

	ai_controller = /datum/ai_controller/basic_controller/tendril

	/// Looping heartbeat sound
	var/datum/looping_sound/heartbeat/soundloop
	/// Melee attack ability to used in retaliation to melee strikes and whenever it manages to grab someone
	var/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_melee/tendril_melee
	/// List of all necropolis turfs we've generated -> their original types for cleanup once we are killed
	var/list/infected_turfs = list()

/mob/living/basic/mining/tendril/Initialize(mapload)
	. = ..()
	GLOB.tendrils += src
	AddElement(/datum/element/death_drops, /obj/structure/closet/crate/necropolis/tendril)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/gps, "Eerie Signal")
	AddComponent(/datum/component/basic_mob_attack_telegraph, display_telegraph_overlay = FALSE, telegraph_duration = 0.4 SECONDS)
	AddComponent(/datum/component/regenerator, regeneration_delay = 30 SECONDS, brute_per_second = 20, outline_colour = COLOR_CULT_RED)
	add_traits(list(TRAIT_BACKSTAB_IMMUNE, TRAIT_IMMOBILIZED), INNATE_TRAIT)

	var/static/list/abilities = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_lash = BB_TENDRIL_LASH,
		/datum/action/cooldown/mob_cooldown/tendril_chaser = BB_TENDRIL_CHASER,
		/datum/action/cooldown/mob_cooldown/tendril_cross_spikes = BB_TENDRIL_SPIKES,
	)
	grant_actions_by_list(abilities)

	tendril_melee = new(src)
	tendril_melee.Grant(src)
	AddComponent(/datum/component/revenge_ability, tendril_melee, targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY]), max_range = 2, target_self = TRUE)

	soundloop = new(src, start_immediately = FALSE)
	soundloop.mid_length = HEARTBEAT_NORMAL
	soundloop.pressure_affected = FALSE
	soundloop.start()
	update_appearance(UPDATE_OVERLAYS)

	var/turf/our_turf = get_turf(src)
	for (var/turf/rock in range(4, src))
		var/dist = get_dist_euclidean(rock, our_turf)
		if (dist > 4.5)
			continue

		if (ismineralturf(rock))
			rock.ScrapeAway(null, CHANGETURF_IGNORE_AIR)

		if (istype(rock, /turf/open/misc/asteroid) && prob(100 / sqrt(max(1, dist))))
			infected_turfs[rock] = rock.type
			rock.ChangeTurf(/turf/open/indestructible/necropolis, null, CHANGETURF_IGNORE_AIR)

/mob/living/basic/mining/tendril/Destroy()
	GLOB.tendrils -= src
	QDEL_NULL(soundloop)
	infected_turfs.Cut()

	if(!SSachievements.achievements_enabled || (flags_1 & ADMIN_SPAWNED_1))
		return ..()

	for(var/mob/living/killer in view(7, src))
		if(killer.stat || !killer.client)
			continue
		killer.client.give_award(/datum/award/score/tendril_score, killer)
		if (!length(GLOB.tendrils))
			killer.client.give_award(/datum/award/achievement/boss/tendril_exterminator, killer)

	return ..()

/mob/living/basic/mining/tendril/death(gibbed)
	var/turf/our_turf = get_turf(src)
	playsound(our_turf, 'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	// Change our infected turfs back into regular ones, but only if they haven't been already altered
	for (var/turf/open/indestructible/necropolis/infected_turf in infected_turfs)
		var/dist = get_dist_euclidean(our_turf, infected_turf)
		if (dist > 4.5) // We got moved?
			continue
		addtimer(CALLBACK(infected_turf, TYPE_PROC_REF(/turf, ChangeTurf), infected_turfs[infected_turf], null, CHANGETURF_IGNORE_AIR), round(5 - dist, 0.5) * 1 SECONDS)
	return ..()

/mob/living/basic/mining/tendril/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src, effect_type = EMISSIVE_NO_BLOOM)
	. += emissive_appearance(icon, "[icon_state]_e_bloom", src, effect_type = EMISSIVE_BLOOM)

/mob/living/basic/mining/tendril/Life(seconds_per_tick)
	. = ..()
	update_heartbeat() // Just a single math op unless we need updating so its fine to put it here

/mob/living/basic/mining/tendril/updatehealth()
	. = ..()
	update_heartbeat()

/mob/living/basic/mining/tendril/proc/update_heartbeat()
	if (!soundloop)
		return

	var/beat_rate = HEARTBEAT_NORMAL
	if (ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		beat_rate = round(HEARTBEAT_FRANTIC + health / maxHealth * (HEARTBEAT_FAST - HEARTBEAT_FRANTIC), 0.05 SECONDS)

	if (beat_rate != soundloop.mid_length)
		soundloop.set_mid_length(beat_rate)

/mob/living/basic/mining/tendril/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect, fov_effect = TRUE, item_animation_override = null)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(attacked_atom, visual_effect_icon, used_item, animation_type = item_animation_override)

	// Stabby visuals
	var/obj/effect/temp_visual/spike_stab/stab = new(get_turf(src))
	var/target_dir = get_dir(src, attacked_atom)
	stab.transform = matrix().Turn(dir2angle(target_dir) + rand(-7, 7))
	if (target_dir & NORTH)
		stab.pixel_z = 24
	else if (target_dir & SOUTH)
		stab.pixel_z = -24
	if (target_dir & EAST)
		stab.pixel_w = 24
	else if (target_dir & WEST)
		stab.pixel_w = -24

/obj/effect/temp_visual/spike_stab
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "spike_small"
	duration = 0.4 SECONDS

/mob/living/basic/mining/tendril/proc/snatch_react()
	if (tendril_melee.IsAvailable())
		tendril_melee.Activate(warning = FALSE)

#undef HEARTBEAT_NORMAL
#undef HEARTBEAT_FAST
#undef HEARTBEAT_FRANTIC
