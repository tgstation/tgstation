/// Sets the pilot to the occupant in the chair, linking damage. Represents the start of the avatar process
/datum/mind/proc/initial_avatar_connection(mob/living/carbon/human/occupant, mob/living/carbon/human/avatar, obj/structure/netchair/hosting_chair, help_text)
	var/datum/avatar_help_text/help_datum = new(help_text)
	var/datum/action/avatar_domain_info/action = new(help_datum)

	pilot_ref = WEAKREF(occupant)
	netchair_ref = WEAKREF(hosting_chair)

	connect_avatar_signals(avatar, action)
	RegisterSignals(occupant, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_UNBUCKLE,
		),
		PROC_REF(force_disconnect_avatar),
	)

	transfer_to(avatar)
	avatar.playsound_local(avatar, "sound/magic/blink.ogg", 25, TRUE)

/// Used any time we want to link the pilot body to an avatar or subsequent avatar
/datum/mind/proc/connect_avatar_signals(mob/living/target, datum/action/avatar_domain_info/action)
	var/obj/structure/netchair/hosting_chair = netchair_ref?.resolve()
	if(isnull(hosting_chair))
		disconnect_avatar(forced = TRUE)
		return

	hosting_chair.avatar_ref = WEAKREF(target) // we need to set this just in case there's a subsequent hop

	action.Grant(target)

	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_linked_damage))
	RegisterSignals(target, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_GIBBED,
		COMSIG_QSERVER_DISCONNECT,
		),
		PROC_REF(force_disconnect_avatar),
	)

/// Disconnects the avatar and returns the mind to the pilot.
/// When done smoothly, it simply unregisters signals
/datum/mind/proc/disconnect_avatar(forced = FALSE)
	SIGNAL_HANDLER

	var/mob/living/pilot = pilot_ref?.resolve()
	if(isnull(pilot))
		current.dust()

	disconnect_avatar_signals()

	UnregisterSignal(pilot, COMSIG_LIVING_DEATH)
	UnregisterSignal(pilot, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(pilot, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(pilot, COMSIG_MOVABLE_UNBUCKLE)

	var/obj/structure/netchair/hosting_chair = netchair_ref?.resolve()
	if(isnull(hosting_chair))
		current.dust()

	hosting_chair.disconnect_occupant(src, forced)

/// Simply disconnects the signals, but does not port the mind back to the pilot
/datum/mind/proc/disconnect_avatar_signals()
	var/datum/action/avatar_domain_info/action = locate(/datum/action/avatar_domain_info) in current.actions
	if(action)
		action.Remove(current)

	UnregisterSignal(current, COMSIG_LIVING_DEATH)
	UnregisterSignal(current, COMSIG_LIVING_GIBBED)
	UnregisterSignal(current, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(current, COMSIG_QSERVER_DISCONNECT)

/// Helper so that we don't have to apply args to register_signal
/datum/mind/proc/force_disconnect_avatar()
	disconnect_avatar(forced = TRUE)

/// Helper to transfer the mind to a new avatar
/datum/mind/proc/transfer_avatar_signals(mob/living/origin, mob/living/target)
	var/datum/action/avatar_domain_info/action = locate(/datum/action/avatar_domain_info) in origin.actions

	disconnect_avatar_signals(origin)
	connect_avatar_signals(target, action)

/// Transfers damage from the avatar to the pilot
/datum/mind/proc/on_linked_damage(mob/target, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	var/mob/living/carbon/pilot = pilot_ref?.resolve()
	if(!pilot || damage_type == STAMINA || damage_type == OXY)
		return

	if(damage > 15)
		pilot.do_jitter_animation(damage)

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(pilot, TYPE_PROC_REF(/mob/living, emote), "scream")

	pilot.apply_damage(damage, damage_type, def_zone, forced = TRUE)
