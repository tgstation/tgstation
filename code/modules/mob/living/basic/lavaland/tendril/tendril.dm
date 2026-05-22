#define HEARTBEAT_NORMAL (1.8 SECONDS)
#define HEARTBEAT_FAST (1 SECONDS)
#define HEARTBEAT_FRANTIC (0.4 SECONDS)

/mob/living/basic/mining/tendril
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground."
	icon = 'icons/mob/simple/lavaland/tendril.dmi'
	icon_state = "tendril"
	icon_living = "tendril"
	pixel_w = -8
	base_pixel_w = -8
	status_flags = NONE
	mob_biotypes = MOB_ORGANIC | MOB_SKELETAL | MOB_MINING
	basic_mob_flags = DEL_ON_DEATH | IMMUNE_TO_FISTS
	mob_size = MOB_SIZE_HUGE
	maxHealth = 1200
	health = 1200

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

	ai_controller = /datum/ai_controller/basic_controller/tendril

	/// Looping heartbeat sound
	var/datum/looping_sound/heartbeat/soundloop
	var/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_lash/tendril_lash
	var/datum/action/cooldown/mob_cooldown/tendril_chaser/tendril_chaser
	var/datum/action/cooldown/mob_cooldown/tendril_cross_spikes/cross_spikes
	var/datum/action/cooldown/mob_cooldown/projectile_attack/tendril_melee/tendril_melee

/mob/living/basic/mining/tendril/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/gps, "Eerie Signal")
	AddComponent(/datum/component/basic_mob_attack_telegraph, display_telegraph_overlay = FALSE, telegraph_duration = 0.2 SECONDS)
	add_traits(list(TRAIT_BACKSTAB_IMMUNE, TRAIT_IMMOBILIZED), INNATE_TRAIT)

	tendril_lash = new(src)
	tendril_lash.Grant(src)
	tendril_chaser = new(src)
	tendril_chaser.Grant(src)
	cross_spikes = new(src)
	cross_spikes.Grant(src)
	tendril_melee = new(src)
	tendril_melee.Grant(src)

	ai_controller.set_blackboard_key(BB_TENDRIL_LASH, tendril_lash)
	ai_controller.set_blackboard_key(BB_TENDRIL_CHASER, tendril_chaser)
	ai_controller.set_blackboard_key(BB_TENDRIL_SPIKES, cross_spikes)

	AddComponent(/datum/component/revenge_ability, tendril_melee, targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY]), max_range = 2, target_self = TRUE)

	soundloop = new(src, start_immediately = FALSE)
	soundloop.mid_length = HEARTBEAT_NORMAL
	soundloop.pressure_affected = FALSE
	soundloop.start()
	update_appearance(UPDATE_OVERLAYS)

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
	var/beat_rate = HEARTBEAT_NORMAL
	if (ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET] || length(ai_controller?.blackboard[BB_BASIC_MOB_SECONDARY_TARGET_LIST]))
		beat_rate = round(HEARTBEAT_FRANTIC + health / maxHealth * (HEARTBEAT_FAST - HEARTBEAT_FRANTIC), 0.05 SECONDS)

	if (beat_rate != soundloop.mid_length)
		soundloop.set_mid_length(beat_rate)

/// Ignores melee cooldowns by default, handled on AI side unless we have a client
/mob/living/basic/mining/tendril/melee_attack(atom/target, list/modifiers, ignore_cooldown = null)
	return ..(target, modifiers, isnull(ignore_cooldown) ? isnull(client) : ignore_cooldown)

// Don't animate the tendril itself
/mob/living/basic/mining/tendril/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect, fov_effect = TRUE, item_animation_override = null)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(attacked_atom, visual_effect_icon, used_item, animation_type = item_animation_override)

/mob/living/basic/mining/tendril/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	// Stabby visuals
	var/obj/effect/temp_visual/spike_stab/stab = new(get_turf(src))
	var/target_dir = get_dir(src, target)
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
		tendril_melee.Activate()

#undef HEARTBEAT_NORMAL
#undef HEARTBEAT_FAST
#undef HEARTBEAT_FRANTIC
