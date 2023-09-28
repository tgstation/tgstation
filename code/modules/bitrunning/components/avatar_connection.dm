/**
 * Essentially temporary body with a twist - the virtual domain variant uses damage connections,
 * listens for vdom relevant signals.
 */
/datum/component/avatar_connection
	/// The person in the netpod
	var/datum/weakref/old_body_ref
	/// The mind of the person in the netpod
	var/datum/weakref/old_mind_ref
	/// The server connected to the netpod
	var/datum/weakref/server_ref
	/// The netpod the avatar is in
	var/datum/weakref/netpod_ref

/datum/component/avatar_connection/Initialize(
	datum/mind/old_mind,
	mob/living/old_body,
	obj/machinery/quantum_server/server,
	obj/machinery/netpod/pod,
	help_text,
	)

	if(!isliving(parent) || !isliving(old_body) || !server.is_operational || !pod.is_operational)
		return COMPONENT_INCOMPATIBLE

	old_mind_ref = WEAKREF(old_mind)
	old_body_ref = WEAKREF(old_body)
	netpod_ref = WEAKREF(pod)
	server_ref = WEAKREF(server)

	var/mob/living/avatar = parent
	avatar.key = old_body.key
	ADD_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	ADD_TRAIT(avatar, TRAIT_TEMPORARY_BODY, REF(src))

	connect_avatar_signals(avatar)
	RegisterSignal(pod, COMSIG_BITRUNNER_CROWBAR_ALERT, PROC_REF(on_netpod_crowbar))
	RegisterSignal(pod, COMSIG_BITRUNNER_NETPOD_INTEGRITY, PROC_REF(on_netpod_damaged))
	RegisterSignal(pod, COMSIG_BITRUNNER_SEVER_AVATAR, PROC_REF(on_sever_connection))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_completed))
	RegisterSignal(server, COMSIG_BITRUNNER_SEVER_AVATAR, PROC_REF(on_sever_connection))
	RegisterSignal(server, COMSIG_BITRUNNER_SHUTDOWN_ALERT, PROC_REF(on_shutting_down))
	RegisterSignal(server, COMSIG_BITRUNNER_THREAT_CREATED, PROC_REF(on_threat_created))
#ifndef UNIT_TESTS
	RegisterSignal(avatar.mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer))
#endif

	server.avatar_connection_refs.Add(WEAKREF(src))

	if(!locate(/datum/action/avatar_domain_info) in avatar.actions)
		var/datum/avatar_help_text/help_datum = new(help_text)
		var/datum/action/avatar_domain_info/action = new(help_datum)
		action.Grant(avatar)

	avatar.playsound_local(avatar, "sound/magic/blink.ogg", 25, TRUE)
	avatar.set_static_vision(2 SECONDS)
	avatar.set_temp_blindness(1 SECONDS)

/datum/component/avatar_connection/PostTransfer()
	var/obj/machinery/netpod/pod = netpod_ref?.resolve()
	if(isnull(pod))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/avatar = parent
	if(!isliving(avatar))
		return COMPONENT_INCOMPATIBLE

/// One hop of avatar connection - needs called any time the pilot swaps avatars
/datum/component/avatar_connection/proc/connect_avatar_signals(mob/living/target)
	var/obj/machinery/netpod/pod = netpod_ref?.resolve()

	if(parent != target)
		target.TakeComponent(src)

	var/mob/living/avatar = parent
	if(isnull(pod))
		avatar.dust()
		return

	pod.avatar_ref = WEAKREF(target)
	RegisterSignal(avatar, COMSIG_BITRUNNER_SAFE_DISCONNECT, PROC_REF(on_safe_disconnect))
	RegisterSignal(avatar, COMSIG_LIVING_DEATH, PROC_REF(on_sever_connection), override = TRUE)
	RegisterSignal(avatar, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_linked_damage))

/// Disconnects the old body's signals and actions
/datum/component/avatar_connection/proc/disconnect_avatar_signals()
	var/mob/living/avatar = parent
	var/datum/action/avatar_domain_info/action = locate() in avatar.actions
	if(action)
		action.Remove(avatar)

	UnregisterSignal(avatar, COMSIG_BITRUNNER_SAFE_DISCONNECT)
	UnregisterSignal(avatar, COMSIG_LIVING_DEATH)
	UnregisterSignal(avatar, COMSIG_MOB_APPLY_DAMAGE)

/// Disconnects the avatar and returns the mind to the old_body.
/datum/component/avatar_connection/proc/full_avatar_disconnect(forced = FALSE, obj/machinery/netpod/broken_netpod)
	var/mob/living/old_body = old_body_ref?.resolve()
	if(isnull(old_body))
		return

	var/mob/living/avatar = parent

	disconnect_avatar_signals()
	UnregisterSignal(avatar, COMSIG_BITRUNNER_SAFE_DISCONNECT)
#ifndef UNIT_TESTS
	UnregisterSignal(avatar.mind, COMSIG_MIND_TRANSFERRED)
#endif
	UnregisterSignal(old_body, COMSIG_LIVING_DEATH)
	UnregisterSignal(old_body, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(old_body, COMSIG_MOVABLE_MOVED)

	var/obj/machinery/netpod/hosting_netpod = netpod_ref?.resolve() || broken_netpod
	if(isnull(hosting_netpod))
		return

	UnregisterSignal(hosting_netpod, COMSIG_BITRUNNER_CROWBAR_ALERT)
	UnregisterSignal(hosting_netpod, COMSIG_BITRUNNER_NETPOD_INTEGRITY)
	UnregisterSignal(hosting_netpod, COMSIG_BITRUNNER_SEVER_AVATAR)

	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		server.avatar_connection_refs.Remove(WEAKREF(src))
		UnregisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE)
		UnregisterSignal(server, COMSIG_BITRUNNER_SEVER_AVATAR)
		UnregisterSignal(server, COMSIG_BITRUNNER_SHUTDOWN_ALERT)
		UnregisterSignal(server, COMSIG_BITRUNNER_THREAT_CREATED)

	return_to_old_body()

	hosting_netpod.disconnect_occupant(forced)
	qdel(src)

/// Triggers whenever the server gets a loot crate pushed to send area
/datum/component/avatar_connection/proc/on_domain_completed(datum/source, atom/entered)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_success.ogg', 50, TRUE)
	avatar.throw_alert(
		ALERT_BITRUNNER_COMPLETED,
		/atom/movable/screen/alert/bitrunning/qserver_domain_complete,
		new_master = entered
	)

/// Transfers damage from the avatar to the old_body
/datum/component/avatar_connection/proc/on_linked_damage(datum/source, damage, damage_type, def_zone, blocked, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/old_body = old_body_ref?.resolve()

	if(isnull(old_body) || damage_type == STAMINA || damage_type == OXYLOSS)
		return

	if(damage >= (old_body.health + MAX_LIVING_HEALTH))
		full_avatar_disconnect(forced = TRUE)
		return

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(old_body, TYPE_PROC_REF(/mob/living, emote), "scream")

	old_body.apply_damage(damage, damage_type, def_zone, blocked, forced, wound_bonus = CANT_WOUND)

	if(old_body.stat > SOFT_CRIT) // KO!
		full_avatar_disconnect(forced = TRUE)

/// Handles minds being swapped around in subsequent avatars
/datum/component/avatar_connection/proc/on_mind_transfer(datum/mind/source, mob/living/previous_body)
	SIGNAL_HANDLER

	var/datum/action/avatar_domain_info/action = locate() in previous_body.actions
	if(action)
		action.Grant(source.current)
		action.Remove(previous_body)

	disconnect_avatar_signals()
	connect_avatar_signals(source.current)

/// Triggers when someone starts prying open our netpod
/datum/component/avatar_connection/proc/on_netpod_crowbar(datum/source, mob/living/intruder)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	avatar.throw_alert(
		ALERT_BITRUNNER_CROWBAR,
		/atom/movable/screen/alert/bitrunning/netpod_crowbar,
		new_master = intruder
	)

/// Triggers when the netpod is taking damage and is under 50%
/datum/component/avatar_connection/proc/on_netpod_damaged(datum/source)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.throw_alert(
		ALERT_BITRUNNER_INTEGRITY,
		/atom/movable/screen/alert/bitrunning/netpod_damaged,
		new_master = source
	)

/// Safely exits without forced variables, etc
/datum/component/avatar_connection/proc/on_safe_disconnect(datum/source)
	SIGNAL_HANDLER

	full_avatar_disconnect()

/// Helper for calling sever with forced variables
/datum/component/avatar_connection/proc/on_sever_connection(datum/source, obj/machinery/netpod/broken_netpod)
	SIGNAL_HANDLER

	full_avatar_disconnect(forced = TRUE, broken_netpod = broken_netpod)

/// Triggers when the server is shutting down
/datum/component/avatar_connection/proc/on_shutting_down(datum/source, mob/living/hackerman)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	avatar.throw_alert(
		ALERT_BITRUNNER_SHUTDOWN,
		/atom/movable/screen/alert/bitrunning/qserver_shutting_down,
		new_master = hackerman,
	)

/// Server has spawned a ghost role threat
/datum/component/avatar_connection/proc/on_threat_created(datum/source)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.throw_alert(
		ALERT_BITRUNNER_THREAT,
		/atom/movable/screen/alert/bitrunning/qserver_threat_spawned,
		new_master = source,
	)

/// Returns the mind to the old body
/datum/component/avatar_connection/proc/return_to_old_body()
	var/datum/mind/old_mind = old_mind_ref?.resolve()
	var/mob/living/old_body = old_body_ref?.resolve()

	if(!old_mind || !old_body)
		return

	var/mob/living/avatar = parent

#ifdef UNIT_TESTS
	// no minds during test so let's just yeet
	return
#endif

	var/mob/dead/observer/ghost = avatar.ghostize()
	if(!ghost)
		ghost = avatar.get_ghost()

	if(!ghost)
		CRASH("[src] belonging to [parent] was completely unable to find a ghost to put back into a body!")

	ghost.mind = old_mind
	if(old_body.stat != DEAD)
		old_mind.transfer_to(old_body, force_key_move = TRUE)
	else
		old_mind.set_current(old_body)

	REMOVE_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	REMOVE_TRAIT(avatar, TRAIT_TEMPORARY_BODY, REF(src))

	old_mind = null
	old_body = null
