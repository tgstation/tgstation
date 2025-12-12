#define REQUIRED_ACCUMULATION(wound) (1 + (wound.severity - 1) * 0.3)

/datum/action/cooldown/mob_cooldown/blood_worm/inject
	name = "Inject Blood"
	desc = "Inject your blood into the damaged tissues of your host, healing them in exchange for your own health."

	button_icon_state = "inject_blood"

	cooldown_time = 30 SECONDS
	shared_cooldown = NONE

	click_to_activate = FALSE

	check_flags = NONE

	var/health_cost = 0
	var/minimum_health = 10

	var/status_effect_type = null

/datum/action/cooldown/mob_cooldown/blood_worm/inject/New(Target, original)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/inject/Destroy()
	UnregisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/inject/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	var/mob/living/basic/blood_worm/worm = target

	if (worm.get_worm_health() - health_cost < minimum_health)
		if (feedback)
			owner.balloon_alert(owner, "out of blood!")
		return FALSE

	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/inject/Activate(atom/target)
	var/mob/living/basic/blood_worm/worm = src.target
	var/mob/living/carbon/human/host = worm.host

	host.apply_status_effect(status_effect_type, worm)

	host.visible_message(
		message = span_danger("[host]'s wounds start healing unnaturally quickly!"),
		ignored_mobs = owner
	)

	to_chat(owner, span_notice("You inject blood into the damaged tissues of your host."))

	worm.adjust_worm_health(-health_cost)

	return ..()

/datum/status_effect/blood_worm_transfuse
	id = "blood_worm_transfuse"
	duration = 20 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/blood_worm_transfuse
	status_type = STATUS_EFFECT_REPLACE
	processing_speed = STATUS_EFFECT_PRIORITY

	var/damage_regen_rate = 0

	var/wound_regen_rate = 0
	var/wound_regen_accumulation = 0

	var/organ_regen_rate = 0

	var/trauma_regen_rate = 0
	var/trauma_regen_accumulation = 0

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
	var/need_mob_update = FALSE

	need_mob_update |= heal_damage(seconds_between_ticks)
	need_mob_update |= heal_wounds(seconds_between_ticks)
	need_mob_update |= heal_organs(seconds_between_ticks)
	heal_traumas(seconds_between_ticks)

	if (need_mob_update)
		owner.updatehealth()

	last_tick_time = world.time

/datum/status_effect/blood_worm_transfuse/update_shown_duration()
	. = ..()

	if (worm_alert && linked_alert)
		worm_alert.maptext = linked_alert.maptext

/datum/status_effect/blood_worm_transfuse/proc/heal_damage(seconds_between_ticks)
	var/healing_left = damage_regen_rate * seconds_between_ticks

	if (owner.get_brute_loss() > 0 && healing_left > 0)
		var/amount_healed = max(0, owner.adjust_brute_loss(-healing_left, forced = TRUE, updating_health = FALSE))
		healing_left -= amount_healed
		. |= amount_healed

	if (owner.get_fire_loss() > 0 && healing_left > 0)
		var/amount_healed = max(0, owner.adjust_fire_loss(-healing_left, forced = TRUE, updating_health = FALSE))
		healing_left -= amount_healed
		. |= amount_healed

	if (owner.get_tox_loss() > 0 && healing_left > 0)
		var/amount_healed = max(0, owner.adjust_tox_loss(-healing_left, forced = TRUE, updating_health = FALSE))
		healing_left -= amount_healed
		. |= amount_healed

// I tried to set this up reasonably with SPT_PROB(), but it was too inconsistent, especially for wounds with high severity.
// So I switched to an accumulation system instead. This way, the blood worm gets a consistent return on their health investment.
/datum/status_effect/blood_worm_transfuse/proc/heal_wounds(seconds_between_ticks)
	var/mob/living/carbon/human/host = owner

	if (length(host.all_wounds))
		wound_regen_accumulation += wound_regen_rate * seconds_between_ticks
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

/datum/status_effect/blood_worm_transfuse/proc/heal_organs(seconds_between_ticks)
	var/mob/living/carbon/human/host = owner

	for (var/obj/item/organ/organ in host.organs)
		// I thought about making this require ORGAN_ORGANIC, but changelings can heal robotic organs, so why not blood worms?
		// In addition, none of the other blood worm code gives a shit about targets being organic, so this is more consistent.
		. |= organ.apply_organ_damage(-organ_regen_rate * seconds_between_ticks)

/datum/status_effect/blood_worm_transfuse/proc/heal_traumas(seconds_between_ticks)
	var/mob/living/carbon/human/host = owner

	if (host.has_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY))
		trauma_regen_accumulation += trauma_regen_rate * seconds_between_ticks
	else
		trauma_regen_accumulation = 0
		return

	while (trauma_regen_accumulation >= 1 && host.has_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY))
		host.cure_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY)
		trauma_regen_accumulation = max(0, trauma_regen_accumulation - 1)

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
	name = "Blood Injection"
	desc = "The injected blood is rapidly healing your host."
	icon = 'icons/mob/actions/actions_blood_worm.dmi'
	icon_state = "inject_blood"

/atom/movable/screen/alert/status_effect/blood_worm_transfuse/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	underlays += mutable_appearance('icons/mob/actions/backgrounds.dmi', "bg_demon", layer = layer, offset_spokesman = src, plane = plane)

/datum/action/cooldown/mob_cooldown/blood_worm/inject/hatchling
	health_cost = 20
	cooldown_time = 30 SECONDS // Effective host healing rate is 4 hp/s, Effective worm consumption rate is 0.667 hp/s, Worm max health is 2.5x less than host max health, Worm heals at 0.3 hp/s
	status_effect_type = /datum/status_effect/blood_worm_transfuse/hatchling

/datum/status_effect/blood_worm_transfuse/hatchling
	damage_regen_rate = 6 // 20 s * 6 hp/s = 120 hp, note that major host healing is expected as the worm itself is very vulnerable to bleeding.
	wound_regen_rate = 1 / 6 // One wound every 6 seconds, +30% per wound severity level.
	organ_regen_rate = 2.5 // 20 s * 2.5 hp/s = 50 hp
	trauma_regen_rate = 1 / 6 // One trauma every 6 seconds.

/datum/action/cooldown/mob_cooldown/blood_worm/inject/juvenile
	health_cost = 35
	cooldown_time = 40 SECONDS // Effective host healing rate is 4 hp/s, Effective worm consumption rate is 0.875 hp/s, Worm max health is 1.66x less than host max health, Worm heals at 0.4 hp/s
	status_effect_type = /datum/status_effect/blood_worm_transfuse/juvenile

/datum/status_effect/blood_worm_transfuse/juvenile
	damage_regen_rate = 8 // 20 s * 8 hp/s = 160 hp, note that major host healing is expected as the worm itself is very vulnerable to bleeding.
	wound_regen_rate = 1 / 5 // One wound every 5 seconds, +30% per wound severity level.
	organ_regen_rate = 4 // 20 s * 4 hp/s = 80 hp
	trauma_regen_rate = 1 / 5 // One trauma every 5 seconds.

/datum/action/cooldown/mob_cooldown/blood_worm/inject/adult
	health_cost = 50
	cooldown_time = 50 SECONDS // Effective host healing rate is 4 hp/s, Effective worm consumption rate is 1 hp/s, Worm max health is 1.11x less than host max health, Worm heals at 0.5 hp/s
	status_effect_type = /datum/status_effect/blood_worm_transfuse/adult

/datum/status_effect/blood_worm_transfuse/adult
	damage_regen_rate = 10 // 20 s * 10 hp/s = 200 hp, note that major host healing is expected as the worm itself is very vulnerable to bleeding.
	wound_regen_rate = 1 / 4 // One wound every 4 seconds, +30% per wound severity level.
	organ_regen_rate = 5 // 20 s * 5 hp/s = 100 hp, which is also the standard organ health threshold.
	trauma_regen_rate = 1 / 4 // One trauma every 4 seconds.

#undef REQUIRED_ACCUMULATION
