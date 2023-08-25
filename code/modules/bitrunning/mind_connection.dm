/// Sets the pilot to the occupant in the chair, linking damage. Represents the start of the avatar process
/datum/mind/proc/initial_avatar_connection(
	mob/living/carbon/human/avatar,
	obj/machinery/netpod/hosting_netpod,
	obj/machinery/quantum_server/server,
	help_text,
)
	var/mob/living/carbon/human/pilot_mob = current

	if(!locate(/datum/action/avatar_domain_info) in avatar.actions)
		var/datum/avatar_help_text/help_datum = new(help_text)
		var/datum/action/avatar_domain_info/action = new(help_datum)
		action.Grant(avatar)

	pilot_ref = WEAKREF(pilot_mob)
	netpod_ref = WEAKREF(hosting_netpod)

	// Begin the swap - use a fake mind so it isn't cata
	var/datum/mind/fake_mind = new(key + " (pilot)")
	transfer_to(avatar)
	fake_mind.active = TRUE
	fake_mind.transfer_to(pilot_mob)

	avatar.playsound_local(avatar, "sound/magic/blink.ogg", 25, TRUE)
	avatar.set_static_vision(2 SECONDS)
	avatar.set_temp_blindness(1 SECONDS)

	connect_avatar_signals(avatar)
	RegisterSignal(hosting_netpod, COMSIG_BITRUNNER_CROWBAR_ALERT, PROC_REF(on_netpod_crowbar))
	RegisterSignal(hosting_netpod, COMSIG_BITRUNNER_NETPOD_INTEGRITY, PROC_REF(on_netpod_damaged))
	RegisterSignal(hosting_netpod, COMSIG_BITRUNNER_SEVER_AVATAR, PROC_REF(on_sever_connection))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_completed))
	RegisterSignal(server, COMSIG_BITRUNNER_SEVER_AVATAR, PROC_REF(on_sever_connection))
	RegisterSignal(server, COMSIG_BITRUNNER_SHUTDOWN_ALERT, PROC_REF(on_shutting_down))
	RegisterSignal(server, COMSIG_BITRUNNER_THREAT_CREATED, PROC_REF(on_threat_created))
	RegisterSignal(src, COMSIG_BITRUNNER_SAFE_DISCONNECT, PROC_REF(on_safe_disconnect))
	RegisterSignal(src, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer))

/// Links mob damage & death as long as the netpod is there
/datum/mind/proc/connect_avatar_signals(mob/living/target)
	var/obj/machinery/netpod/netpod = netpod_ref?.resolve()
	if(isnull(netpod))
		current.dust()
		return

	netpod.avatar_ref = WEAKREF(target) // we need to set this just in case there's a subsequent hop

	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_linked_damage))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_sever_connection), override = TRUE)

/// Unregisters damage & death signals
/datum/mind/proc/disconnect_avatar_signals()
	var/datum/action/avatar_domain_info/action = locate() in current.actions
	if(action)
		action.Remove(current)

	UnregisterSignal(current, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(current, COMSIG_LIVING_DEATH)

/// Disconnects the avatar and returns the mind to the pilot.
/datum/mind/proc/full_avatar_disconnect(forced = FALSE, obj/machinery/netpod/broken_netpod)
	var/mob/living/pilot = pilot_ref?.resolve()
	var/obj/machinery/netpod/hosting_netpod = netpod_ref?.resolve() || broken_netpod
	if(isnull(pilot) || isnull(hosting_netpod))
		return

	disconnect_avatar_signals()
	UnregisterSignal(src, COMSIG_BITRUNNER_SAFE_DISCONNECT)
	UnregisterSignal(src, COMSIG_MIND_TRANSFERRED)
	UnregisterSignal(pilot, COMSIG_LIVING_DEATH)
	UnregisterSignal(pilot, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(pilot, COMSIG_MOVABLE_MOVED)

	netpod_ref = null
	pilot_ref = null

	hosting_netpod.disconnect_occupant(src, forced)

/// Triggers whenever the server gets a loot crate pushed to send area
/datum/mind/proc/on_domain_completed(datum/source, atom/entered)
	SIGNAL_HANDLER

	current.playsound_local(current, 'sound/machines/terminal_success.ogg', 50, TRUE)
	current.throw_alert(
		ALERT_BITRUNNER_COMPLETED,
		/atom/movable/screen/alert/bitrunning/qserver_domain_complete,
		new_master = entered
	)

/// Transfers damage from the avatar to the pilot
/datum/mind/proc/on_linked_damage(datum/source, damage, damage_type, def_zone, blocked, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/pilot = pilot_ref?.resolve()

	if(isnull(pilot) || damage_type == STAMINA || damage_type == OXYLOSS)
		return

	if(damage >= (pilot.health + MAX_LIVING_HEALTH))
		full_avatar_disconnect(forced = TRUE)
		return

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(pilot, TYPE_PROC_REF(/mob/living, emote), "scream")

	pilot.apply_damage(damage, damage_type, def_zone, blocked, forced, wound_bonus = CANT_WOUND)

	if(pilot.stat > SOFT_CRIT) // KO!
		full_avatar_disconnect(forced = TRUE)

/// Handles minds being swapped around in subsequent avatars
/datum/mind/proc/on_mind_transfer(datum/mind/source, mob/living/previous_body)
	SIGNAL_HANDLER

	var/datum/action/avatar_domain_info/action = locate() in previous_body.actions
	if(action)
		action.Grant(current)
		action.Remove(previous_body)

	disconnect_avatar_signals(previous_body)
	connect_avatar_signals(current)

/// Triggers when someone starts prying open our netpod
/datum/mind/proc/on_netpod_crowbar(datum/source, mob/living/intruder)
	SIGNAL_HANDLER

	current.playsound_local(current, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	current.throw_alert(
		ALERT_BITRUNNER_CROWBAR,
		/atom/movable/screen/alert/bitrunning/netpod_crowbar,
		new_master = intruder
	)

/// Triggers when the netpod is taking damage and is under 50%
/datum/mind/proc/on_netpod_damaged(datum/source)
	SIGNAL_HANDLER

	current.throw_alert(
		ALERT_BITRUNNER_INTEGRITY,
		/atom/movable/screen/alert/bitrunning/netpod_damaged,
		new_master = source
	)

/// Safely exits without forced variables, etc
/datum/mind/proc/on_safe_disconnect(datum/source)
	SIGNAL_HANDLER

	full_avatar_disconnect()

/// Helper for calling sever with forced variables
/datum/mind/proc/on_sever_connection(datum/source, obj/machinery/netpod/broken_netpod)
	SIGNAL_HANDLER

	full_avatar_disconnect(forced = TRUE, broken_netpod = broken_netpod)

/// Triggers when the server is shutting down
/datum/mind/proc/on_shutting_down(datum/source, mob/living/hackerman)
	SIGNAL_HANDLER

	current.playsound_local(current, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	current.throw_alert(
		ALERT_BITRUNNER_SHUTDOWN,
		/atom/movable/screen/alert/bitrunning/qserver_shutting_down,
		new_master = hackerman,
	)

/// Server has spawned a ghost role threat
/datum/mind/proc/on_threat_created(datum/source)
	SIGNAL_HANDLER

	current.throw_alert(
		ALERT_BITRUNNER_THREAT,
		/atom/movable/screen/alert/bitrunning/qserver_threat_spawned,
		new_master = source,
	)
