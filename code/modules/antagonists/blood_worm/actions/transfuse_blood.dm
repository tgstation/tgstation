#define REQUIRED_ACCUMULATION(wound) (1 + (wound.severity - 1) * 0.3)

/datum/action/cooldown/mob_cooldown/blood_worm_transfuse
	name = "Transfuse Blood"
	desc = "Transfuse blood into your host, healing them in exchange for your own health."

	cooldown_time = 30 SECONDS
	shared_cooldown = NONE

	click_to_activate = FALSE

	check_flags = NONE

	var/health_cost = 0
	var/minimum_health = 20

	var/status_effect_type = null

/datum/action/cooldown/mob_cooldown/blood_worm_transfuse/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm_transfuse/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm_transfuse/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

	if (worm.health - health_cost < minimum_health)
		if (feedback)
			owner.balloon_alert(owner, "out of blood!")
		return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm_transfuse/Activate(atom/target)
	var/mob/living/basic/blood_worm/worm = src.target
	var/mob/living/carbon/human/host = worm.host

	host.apply_status_effect(status_effect_type, worm)

	host.visible_message(
		message = span_danger("[host]'s wounds start healing unnaturally quickly!"),
		ignored_mobs = owner
	)

	to_chat(owner, span_danger("You transfuse blood into your host."))

	host.blood_volume -= health_cost * BLOOD_WORM_HEALTH_TO_BLOOD

	return ..()

/datum/status_effect/blood_worm_transfuse
	id = "blood_worm_transfuse"
	duration = 20 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/blood_worm_transfuse
	status_type = STATUS_EFFECT_REPLACE

	var/damage_regen_rate = 0
	var/wound_regen_rate = 0
	var/wound_regen_accumulation = 0

	var/atom/movable/screen/alert/status_effect/worm_alert = null
	var/mob/living/basic/blood_worm/worm = null

	var/last_tick_time = 0

/datum/status_effect/blood_worm_transfuse/on_creation(mob/living/new_owner, mob/living/basic/blood_worm/new_worm)
	. = ..()
	if (!.)
		return

	attach_to_worm(new_worm)
	last_tick_time = world.time

/datum/status_effect/blood_worm_transfuse/Destroy()
	detach_from_worm()
	return ..()

/datum/status_effect/blood_worm_transfuse/tick(seconds_between_ticks)
	// Calculate how much time has passed since our last tick, clamped to the remaining duration plus one second to account for the initial tick.
	// Assuming no inaccuracy shenanigans, this makes it so the total amount healed is exactly [duration * 0.1 * damage_regen_rate]
	// Somebody should really fix the fact that I have to go through all these hoops just to get accurate delta time.
	var/delta_time = max(0, min((world.time - last_tick_time) * 0.1, (duration - world.time) * 0.1 + 1))
	var/need_mob_update = FALSE

	need_mob_update |= heal_damage(delta_time)
	need_mob_update |= heal_wounds(delta_time)

	if (need_mob_update)
		owner.updatehealth()

	last_tick_time = world.time

/datum/status_effect/blood_worm_transfuse/update_shown_duration()
	. = ..()

	if (worm_alert && linked_alert)
		worm_alert.maptext = linked_alert.maptext

/datum/status_effect/blood_worm_transfuse/proc/heal_damage(delta_time)
	var/healing_left = damage_regen_rate * delta_time

	if (owner.getBruteLoss() > 0 && healing_left > 0)
		var/amount_healed = max(0, owner.adjustBruteLoss(-healing_left, forced = TRUE, updating_health = FALSE))
		healing_left -= amount_healed
		. |= amount_healed

	if (owner.getFireLoss() > 0 && healing_left > 0)
		var/amount_healed = max(0, owner.adjustFireLoss(-healing_left, forced = TRUE, updating_health = FALSE))
		healing_left -= amount_healed
		. |= amount_healed

	if (owner.getToxLoss() > 0 && healing_left > 0)
		var/amount_healed = max(0, owner.adjustToxLoss(-healing_left, forced = TRUE, updating_health = FALSE))
		healing_left -= amount_healed
		. |= amount_healed

// I tried to set this up reasonably with SPT_PROB(), but it was too inconsistent, especially for wounds with high severity.
// So I switched to an accumulation system instead. This way, the blood worm gets a consistent return on their health investment.
/datum/status_effect/blood_worm_transfuse/proc/heal_wounds(delta_time)
	var/mob/living/carbon/human/host = owner

	if (length(host.all_wounds))
		wound_regen_accumulation += wound_regen_rate * delta_time
	else
		wound_regen_accumulation = 0
		return

	while (wound_regen_accumulation >= 1 && length(host.all_wounds))
		var/list/candidates = list()

		for (var/datum/wound/wound in host.all_wounds)
			if (wound_regen_accumulation >= REQUIRED_ACCUMULATION(wound))
				candidates += wound

		if (!length(candidates))
			return

		var/datum/wound/wound_to_heal = pick(candidates)
		wound_regen_accumulation = max(0, wound_regen_accumulation - REQUIRED_ACCUMULATION(wound_to_heal))
		wound_to_heal.remove_wound()
		. = TRUE

/datum/status_effect/blood_worm_transfuse/proc/attach_to_worm(mob/living/basic/blood_worm/new_worm)
	worm = new_worm

	if (!worm || !alert_type)
		return

	RegisterSignal(worm, COMSIG_QDELETING, PROC_REF(detach_from_worm))

	worm_alert = worm.throw_alert(id, alert_type)
	worm_alert.attached_effect = src
	update_shown_duration()

/datum/status_effect/blood_worm_transfuse/proc/detach_from_worm(datum/source, force)
	SIGNAL_HANDLER

	UnregisterSignal(worm, COMSIG_QDELETING)

	worm_alert = null
	worm.clear_alert(id)

	worm = null

/atom/movable/screen/alert/status_effect/blood_worm_transfuse
	name = "Blood Transfusion"
	desc = "The transfused blood is rapidly healing your host."

/datum/action/cooldown/mob_cooldown/blood_worm_transfuse/hatchling
	health_cost = 20 // One use, with 10s after the 40s cooldown to get another use, assuming no other health loss.
	status_effect_type = /datum/status_effect/blood_worm_transfuse/hatchling

/datum/status_effect/blood_worm_transfuse/hatchling
	damage_regen_rate = 6
	wound_regen_rate = 1 / 6 // One wound every 6 seconds, +30% per wound severity level.

#undef REQUIRED_ACCUMULATION
