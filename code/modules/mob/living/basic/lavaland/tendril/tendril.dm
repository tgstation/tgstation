#define HEARTBEAT_NORMAL (1.2 SECONDS)
#define HEARTBEAT_FAST (0.8 SECONDS)
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
	maxHealth = 600
	health = 600

	friendly_verb_continuous = "flails at"
	friendly_verb_simple = "flail at"
	speak_emote = list("resonates")
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
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

/mob/living/basic/mining/tendril/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/gps, "Eerie Signal")
	add_traits(list(TRAIT_BACKSTAB_IMMUNE, TRAIT_IMMOBILIZED), INNATE_TRAIT)

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
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "spike_small"
	duration = 0.4 SECONDS

#undef HEARTBEAT_NORMAL
#undef HEARTBEAT_FAST
#undef HEARTBEAT_FRANTIC
