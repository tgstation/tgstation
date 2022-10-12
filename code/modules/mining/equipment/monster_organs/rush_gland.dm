/**
 * On use in hand, makes you run really fast for 5 seconds and ignore injury movement decrease.
 * On use when implanted, run for longer and ignore all negative movement. Automatically triggers if health is low (to escape).
 */
/obj/item/organ/internal/monster_core/reusable/rush_gland
	name = "rush gland"
	desc = "A lobstrosity's engorged adrenal gland. You can squeeze it to get a rush of energy on demand."
	desc_preserved = "A lobstrosity's engorged adrenal gland. It is preserved, allowing you to use it for a burst of speed whenever you need it."
	desc_inert = "A lobstrosity's adrenal gland. It is all shrivelled up."
	user_status = /datum/status_effect/lobster_rush
	internal_use_cooldown = 3 MINUTES

#define HEALTH_DANGER_ZONE 30

/obj/item/organ/internal/monster_core/reusable/rush_gland/on_life(delta_time, times_fired)
	. = ..()
	if (owner.health <= HEALTH_DANGER_ZONE)
		use_internal.Trigger()

#undef HEALTH_DANGER_ZONE

/obj/item/organ/internal/monster_core/reusable/rush_gland/activate_implanted()
	owner.apply_status_effect(/datum/status_effect/lobster_rush/extended)

/**
 * Status effect: Makes you run really fast and ignore injury speed penalty for a short duration.
 * If you run into a wall indoors you will fall over and lose the buff.
 * If you run into someone you both fall over.
 */
/datum/status_effect/lobster_rush
	id = "lobster_rush"
	duration = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/lobster_rush
	var/spawned_last_move = FALSE

/atom/movable/screen/alert/status_effect/lobster_rush
	name = "Lobster Rush"
	desc = "Adrenaline is surging through you!"
	icon_state = "antalert"

/// Returns a string used to identify this status effect for trait application
/datum/status_effect/lobster_rush/proc/get_trait_id()
	return "[STATUS_EFFECT_TRAIT]_[id]"

/datum/status_effect/lobster_rush/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/on_move)
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, .proc/on_bump)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, get_trait_id())
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/lobster_rush)
	to_chat(owner, span_notice("You feel your blood pumping!"))

/datum/status_effect/lobster_rush/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_BUMP))
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, get_trait_id())
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/lobster_rush)
	to_chat(owner, span_notice("Your pulse returns to normal."))

/// Spawn an afterimage every other step, because every step was too many
/datum/status_effect/lobster_rush/proc/on_move()
	if (!spawned_last_move)
		new /obj/effect/temp_visual/decoy/fading(owner.loc, owner)
	spawned_last_move = !spawned_last_move

/datum/status_effect/lobster_rush/proc/on_bump(mob/living/source, atom/target)
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
	target.adjustStaminaLoss(40)
	target.adjustBruteLoss(20)

/// You get a longer buff if you take the time to implant it in yourself, and you ignore all slowdown
/datum/status_effect/lobster_rush/extended
	duration = 5 SECONDS

/datum/status_effect/lobster_rush/extended/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, get_trait_id())
	return ..()

/datum/status_effect/lobster_rush/extended/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, get_trait_id())
	return ..()
