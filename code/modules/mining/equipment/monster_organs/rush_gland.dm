/// Health under which implanted gland will automatically activate
#define HEALTH_DANGER_ZONE 30

/**
 * On use in hand, makes you run really fast for 5 seconds and ignore injury movement decrease.
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

/obj/item/organ/monster_core/rush_gland/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_GOLIATH_TENTACLED_GRABBED)

/obj/item/organ/monster_core/rush_gland/on_triggered_internal()
	owner.apply_status_effect(/datum/status_effect/lobster_rush/extended)

/obj/item/organ/monster_core/rush_gland/proc/trigger_organ_action_on_sig(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(trigger_organ_action))

/**
 * Status effect: Makes you run really fast and ignore speed penalties for a short duration.
 * If you run into a wall indoors you will fall over and lose the buff.
 * If you run into someone you both fall over.
 */
/datum/status_effect/lobster_rush
	id = "lobster_rush"
	duration = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/lobster_rush
	show_duration = TRUE
	var/spawned_last_move = FALSE

/atom/movable/screen/alert/status_effect/lobster_rush
	name = "Lobster Rush"
	desc = "Adrenaline is surging through you!"
	icon_state = "lobster"

/datum/status_effect/lobster_rush/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	owner.add_traits(list(TRAIT_IGNORESLOWDOWN, TRAIT_TENTACLE_IMMUNE), TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/lobster_rush)
	to_chat(owner, span_notice("You feel your blood pumping!"))

/datum/status_effect/lobster_rush/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_BUMP))
	owner.remove_traits(list(TRAIT_IGNORESLOWDOWN, TRAIT_TENTACLE_IMMUNE), TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/lobster_rush)
	to_chat(owner, span_notice("Your pulse returns to normal."))

/// Spawn an afterimage every other step, because every step was too many
/datum/status_effect/lobster_rush/proc/on_move()
	SIGNAL_HANDLER
	if (!spawned_last_move)
		new /obj/effect/temp_visual/decoy/fading(owner.loc, owner)
	spawned_last_move = !spawned_last_move

/datum/status_effect/lobster_rush/proc/on_bump(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if (!target.density)
		return
	if (isliving(target))
		source.visible_message(span_warning("[source] crashes into [target]!"))
		smack_into(source)
		smack_into(target)
		qdel(src)
		return
	if (lavaland_equipment_pressure_check(get_turf(source)))
		return
	smack_into(source)
	source.visible_message(span_warning("[source] crashes into [target]!"))
	qdel(src)

/datum/status_effect/lobster_rush/proc/smack_into(mob/living/target)
	target.Knockdown(5 SECONDS)
	target.apply_damage(40, STAMINA)
	target.apply_damage(20, BRUTE, spread_damage = TRUE)

/// You get a longer buff if you take the time to implant it in yourself
/datum/status_effect/lobster_rush/extended
	duration = 5 SECONDS

/// Action used by the rush gland
/datum/action/cooldown/monster_core_action/adrenal_boost
	name = "Adrenal Boost"
	desc = "Pump your rush gland to give yourself a boost of speed. \
		Impacts with objects can be dangerous under atmospheric pressure."
	button_icon_state = "lobster_gland_stable"
	cooldown_time = 90 SECONDS

#undef HEALTH_DANGER_ZONE
