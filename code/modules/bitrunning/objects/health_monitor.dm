/obj/item/bitrunner_health_monitor
	name = "host monitor"

	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2)
	desc = "A complex medical device that, when attached to an avatar's data stream, can detect and alert the user of their host's health."
	flags_1 = CONDUCT_1
	icon = 'icons/obj/device.dmi'
	icon_state = "gps-b"
	inhand_icon_state = "electronic"
	item_flags = NOBLUDGEON
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	throw_range = 7
	throw_speed = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "electronic"
	/// The mind that signals severance
	var/datum/weakref/pilot_mind_ref
	/// The ref of the pilot we're currently tracking
	var/datum/weakref/pilot_ref
	/// The length of time between alerts
	var/health_alert_cooldown = 10 SECONDS
	/// Cooldown between alerts
	COOLDOWN_DECLARE(health_alert)

/obj/item/bitrunner_health_monitor/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_BITRUNNER_MONITOR_ON, PROC_REF(on_attached), override = TRUE)

/obj/item/bitrunner_health_monitor/attack_self(mob/user, modifiers)
	. = ..()

	if(!COOLDOWN_FINISHED(src, health_alert))
		return

	var/datum/mind/our_mind = user.mind
	var/mob/living/pilot = our_mind.pilot_ref?.resolve()
	if(isnull(pilot))
		balloon_alert(user, "data not recognized")
		return

	to_chat(user, span_notice("Current host health: [pilot.health / pilot.maxHealth * 100]%"))
	COOLDOWN_START(src, health_alert, health_alert_cooldown)

/// Called when the monitor is attached to an avatar
/obj/item/bitrunner_health_monitor/proc/on_attached(datum/source, mob/living/pilot, datum/mind/host_mind)
	SIGNAL_HANDLER

	pilot_ref = WEAKREF(pilot)
	pilot_mind_ref = WEAKREF(host_mind)

	RegisterSignal(pilot, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_change), override = TRUE)
	RegisterSignals(host_mind, list(COMSIG_BITRUNNER_SAFE_DISCONNECT, COMSIG_BITRUNNER_SEVER_AVATAR), PROC_REF(on_detached), override = TRUE)

/// Called when the monitor is detached from an avatar
/obj/item/bitrunner_health_monitor/proc/on_detached(datum/source)
	SIGNAL_HANDLER

	var/mob/living/pilot = pilot_ref?.resolve()
	if(QDELETED(pilot))
		return

	pilot_ref = null
	UnregisterSignal(pilot, COMSIG_LIVING_HEALTH_UPDATE)

	var/datum/mind/our_mind = pilot_mind_ref?.resolve()
	if(QDELETED(our_mind))
		return

	pilot_mind_ref = null
	UnregisterSignal(our_mind, COMSIG_BITRUNNER_SAFE_DISCONNECT)
	UnregisterSignal(our_mind, COMSIG_BITRUNNER_SEVER_AVATAR)

/// Called when the host's health changes
/obj/item/bitrunner_health_monitor/proc/on_health_change(mob/living/source)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, health_alert))
		return

	var/health = source.health / source.maxHealth * 100

	if(health >= 50)
		return

	say("alert: host is in [health > 25 ? "poor" : "critical"] condition.")
	COOLDOWN_START(src, health_alert, health_alert_cooldown)
