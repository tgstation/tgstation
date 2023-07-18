/// Sets the pilot to the occupant in the chair, linking damage. Represents the start of the avatar process
/datum/mind/proc/initial_avatar_connection(mob/living/carbon/human/occupant, mob/living/carbon/human/avatar, obj/structure/netchair/hosting_chair, help_text)
	var/datum/avatar_help_text/help_datum = new(help_text)
	var/datum/action/avatar_domain_info/action = new(help_datum)
	var/datum/mind/fake_mind = new(key + " (pilot)")

	pilot_ref = WEAKREF(occupant)
	netchair_ref = WEAKREF(hosting_chair)

	/// Begin the swap - use a fake mind so it isn't cata
	transfer_to(avatar)
	action.Grant(avatar)
	fake_mind.active = TRUE
	fake_mind.transfer_to(occupant)

	avatar.playsound_local(avatar, "sound/magic/blink.ogg", 25, TRUE)

	connect_avatar_signals(avatar)
	RegisterSignals(occupant, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_UNBUCKLE,
		),
		PROC_REF(on_sever_connection),
		override = TRUE,
	)

/// Used any time we want to link the pilot body to an avatar or subsequent avatar
/datum/mind/proc/connect_avatar_signals(mob/living/target, datum/action/avatar_domain_info/action)
	var/obj/structure/netchair/hosting_chair = netchair_ref?.resolve()
	if(isnull(hosting_chair))
		disconnect_avatar(forced = TRUE)
		return

	hosting_chair.avatar_ref = WEAKREF(target) // we need to set this just in case there's a subsequent hop

	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_linked_damage))
	RegisterSignals(target, list(
		COMSIG_QSERVER_DISCONNECT,
		COMSIG_LIVING_GIBBED
		),
		PROC_REF(on_sever_connection),
	)
	RegisterSignal(src, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer), override = TRUE)

/// Disconnects the avatar and returns the mind to the pilot.
/// When done smoothly, it simply unregisters signals
/datum/mind/proc/disconnect_avatar(forced = FALSE)
	var/mob/living/pilot = pilot_ref?.resolve()
	if(isnull(pilot))
		current.dust()

	disconnect_avatar_signals()

	UnregisterSignal(pilot, COMSIG_LIVING_DEATH)
	RegisterSignal(pilot, COMSIG_LIVING_DEATH, PROC_REF(set_death_time))

	UnregisterSignal(pilot, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(pilot, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(pilot, COMSIG_MOVABLE_UNBUCKLE)

	var/obj/structure/netchair/hosting_chair = netchair_ref?.resolve()
	if(isnull(hosting_chair))
		current.dust()

	hosting_chair.disconnect_occupant(src, forced)

/// Simply disconnects the signals, but does not port the mind back to the pilot
/datum/mind/proc/disconnect_avatar_signals()
	UnregisterSignal(src, COMSIG_MIND_TRANSFERRED)
	if(isnull(current)) // sometimes this is called after the mind has been destroyed
		return
	UnregisterSignal(current, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(current, COMSIG_QSERVER_DISCONNECT)

/// Transfers damage from the avatar to the pilot
/datum/mind/proc/on_linked_damage(mob/target, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	if(!isliving(target))
		return

	var/mob/living/avatar = target
	var/mob/living/carbon/pilot = pilot_ref?.resolve()

	if(!pilot || damage_type == STAMINA || damage_type == OXY)
		return

	if(damage > 15)
		pilot.do_jitter_animation(damage)

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(pilot, TYPE_PROC_REF(/mob/living, emote), "scream")

	pilot.apply_damage(damage, damage_type, def_zone, blocked = FALSE, forced = TRUE)

	if((avatar.health + MAX_LIVING_HEALTH) <= damage)
		disconnect_avatar(forced = TRUE)

/// Handles minds being swapped around in subsequent avatars
/datum/mind/proc/on_mind_transfer(mob/living/previous_body)
	SIGNAL_HANDLER

	transfer_avatar_signals(previous_body, current)

/// Helper so that we don't have to apply args to register_signal
/datum/mind/proc/on_sever_connection()
	SIGNAL_HANDLER

	last_death = world.time
	disconnect_avatar(forced = TRUE)

/// Helper to transfer the mind to a new avatar
/datum/mind/proc/transfer_avatar_signals(mob/living/origin, mob/living/target)
	disconnect_avatar_signals(origin)
	connect_avatar_signals(target)
