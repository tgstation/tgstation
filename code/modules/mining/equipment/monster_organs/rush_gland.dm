/// Health under which implanted gland will automatically activate
#define HEALTH_DANGER_ZONE 30

/**
 * On use in hand, makes you run faster for a bit and ignore injury movement decrease.
 * On use when implanted, run for longer and ignore all negative movement. Automatically triggers if health is low (to escape).
 */
/obj/item/organ/monster_core/rush_gland
	name = "rush gland"
	icon_state = "lobster_gland"
	icon_state_preserved = "lobster_gland_stable"
	icon_state_inert = "lobster_gland_decayed"
	desc = "A lobstrosity's engorged adrenal gland. You can squeeze it to get a rush of energy on demand."
	desc_preserved = "A lobstrosity's engorged adrenal gland. It is preserved, allowing you to use it for a burst of speed whenever you need it."
	desc_inert = "A lobstrosity's adrenal gland. It is all shrivelled up."
	user_status = /datum/status_effect/lobster_rush
	actions_types = list(/datum/action/cooldown/monster_core_action/adrenal_boost)

/obj/item/organ/monster_core/rush_gland/on_life(seconds_per_tick, times_fired)
	. = ..()
	if (owner.health <= HEALTH_DANGER_ZONE)
		trigger_organ_action()

/obj/item/organ/monster_core/rush_gland/on_mob_insert(mob/living/carbon/organ_owner)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_GOLIATH_TENTACLED_GRABBED, PROC_REF(trigger_organ_action_on_sig))

/obj/item/organ/monster_core/rush_gland/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_GOLIATH_TENTACLED_GRABBED)

/obj/item/organ/monster_core/rush_gland/on_triggered_internal()
	owner.apply_status_effect(/datum/status_effect/lobster_rush/extended)

/obj/item/organ/monster_core/rush_gland/proc/trigger_organ_action_on_sig(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(trigger_organ_action))

/**
 * Status effect: Makes you run faster and ignore damage speed penalties for a short duration.
 * If you run into a wall indoors you will fall over and lose the buff.
 * If you run into someone you both fall over.
 */
/datum/status_effect/lobster_rush
	id = "lobster_rush"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/lobster_rush
	show_duration = TRUE
	var/spawned_last_move = FALSE

/atom/movable/screen/alert/status_effect/lobster_rush
	name = "Lobster Rush"
	desc = "Adrenaline is surging through you!"
	use_user_hud_icon = TRUE
	overlay_state = "lobster"

/datum/status_effect/lobster_rush/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	ADD_TRAIT(owner, TRAIT_TENTACLE_IMMUNE, TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_mod_immunities(id, /datum/movespeed_modifier/damage_slowdown)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/lobster_rush)
	to_chat(owner, span_notice("You feel your blood pumping!"))

/datum/status_effect/lobster_rush/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_BUMP))
	REMOVE_TRAIT(owner, TRAIT_TENTACLE_IMMUNE, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/lobster_rush)
	owner.remove_movespeed_mod_immunities(id, /datum/movespeed_modifier/damage_slowdown)
	to_chat(owner, span_notice("Your pulse returns to normal."))

/// Spawn an afterimage every other step, because every step was too many
/datum/status_effect/lobster_rush/proc/on_move(datum/source, atom/old_loc, dir)
	SIGNAL_HANDLER
	if (!isturf(old_loc) || !isturf(owner.loc))
		return
	if (!spawned_last_move)
		new /obj/effect/temp_visual/decoy/fading(old_loc, owner, 150)
	spawned_last_move = !spawned_last_move

/datum/status_effect/lobster_rush/proc/on_bump(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if (!target.density)
		return
	if (lavaland_equipment_pressure_check(get_turf(source)))
		return
	smack_into(source)
	source.visible_message(span_warning("[source] crashes into [target]!"))
	if (isliving(target))
		smack_into(target)
	qdel(src)

/datum/status_effect/lobster_rush/proc/smack_into(mob/living/target)
	target.Knockdown(2 SECONDS)
	target.apply_damage(30, STAMINA)
	target.apply_damage(10, BRUTE, spread_damage = TRUE)

/// You get a longer buff if you take the time to implant it in yourself
/datum/status_effect/lobster_rush/extended
	duration = 60 SECONDS

/datum/status_effect/lobster_rush/extended/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/lobster_rush/extended/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))

/// Action used by the rush gland
/datum/action/cooldown/monster_core_action/adrenal_boost
	name = "Adrenal Boost"
	desc = "Pump your rush gland to give yourself a boost of speed. \
		Impacts with objects can be dangerous under atmospheric pressure."
	button_icon_state = "lobster_gland_stable"
	cooldown_time = 180 SECONDS

#undef HEALTH_DANGER_ZONE
