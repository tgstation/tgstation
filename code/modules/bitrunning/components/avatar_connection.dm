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

	var/mob/living/avatar = parent

	netpod_ref = WEAKREF(pod)
	old_body_ref = WEAKREF(old_body)
	old_mind_ref = WEAKREF(old_mind)
	pod.avatar_ref = WEAKREF(avatar)
	server_ref = WEAKREF(server)
	server.avatar_connection_refs.Add(WEAKREF(src))

	avatar.key = old_body.key
	ADD_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))

	RegisterSignals(old_body, list(COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_STATUS_UNCONSCIOUS), PROC_REF(on_sever_connection))
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

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	pod.avatar_ref = WEAKREF(parent)

/datum/component/avatar_connection/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	RegisterSignal(parent, COMSIG_BITRUNNER_SAFE_DISCONNECT, PROC_REF(on_safe_disconnect))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_sever_connection))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_linked_damage))

/datum/component/avatar_connection/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	UnregisterSignal(parent, COMSIG_BITRUNNER_SAFE_DISCONNECT)
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)

/// Disconnects the avatar and returns the mind to the old_body.
/datum/component/avatar_connection/proc/full_avatar_disconnect(forced = FALSE, datum/source)
#ifndef UNIT_TESTS
	return_to_old_body()
#endif

	var/obj/machinery/netpod/hosting_netpod = netpod_ref?.resolve()
	if(isnull(hosting_netpod) && istype(source, /obj/machinery/netpod))
		hosting_netpod = source

	hosting_netpod?.disconnect_occupant(forced)

	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	server?.avatar_connection_refs.Remove(WEAKREF(src))

	qdel(src)

/// Triggers whenever the server gets a loot crate pushed to goal area
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

	source.current.TakeComponent(src)

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
/datum/component/avatar_connection/proc/on_sever_connection(datum/source)
	SIGNAL_HANDLER

	full_avatar_disconnect(forced = TRUE, source = source)

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
	var/mob/living/avatar = parent

	var/mob/dead/observer/ghost = avatar.ghostize()
	if(isnull(ghost))
		ghost = avatar.get_ghost()

	if(isnull(ghost))
		CRASH("[src] belonging to [parent] was completely unable to find a ghost to put back into a body!")

	if(isnull(old_mind) || isnull(old_body))
		return

	ghost.mind = old_mind
	if(old_body.stat != DEAD)
		old_mind.transfer_to(old_body, force_key_move = TRUE)
	else
		old_mind.set_current(old_body)

	REMOVE_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
