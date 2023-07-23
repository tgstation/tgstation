/// Sets the pilot to the occupant in the chair, linking damage. Represents the start of the avatar process
/datum/mind/proc/initial_avatar_connection(
	mob/living/carbon/human/occupant,
	mob/living/carbon/human/avatar,
	obj/structure/netchair/hosting_chair,
	obj/machinery/quantum_server/server,
	help_text,
)

	if(!locate(/datum/action/avatar_domain_info) in avatar.actions)
		var/datum/avatar_help_text/help_datum = new(help_text)
		var/datum/action/avatar_domain_info/action = new(help_datum)
		action.Grant(avatar)

	pilot_ref = WEAKREF(occupant)
	netchair_ref = WEAKREF(hosting_chair)

	// Begin the swap - use a fake mind so it isn't cata
	var/datum/mind/fake_mind = new(key + " (pilot)")
	transfer_to(avatar)
	fake_mind.active = TRUE
	fake_mind.transfer_to(occupant)

	avatar.playsound_local(avatar, "sound/magic/blink.ogg", 25, TRUE)
	avatar.set_static_vision(2 SECONDS)
	avatar.set_temp_blindness(1 SECONDS)

	connect_avatar_signals(avatar)
	RegisterSignals(occupant, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_UNBUCKLE,
		),
		PROC_REF(on_sever_connection),
	)
	RegisterSignal(server, COMSIG_QSERVER_DISCONNECTED, PROC_REF(on_sever_connection))
	RegisterSignal(src, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer))
	RegisterSignal(SSdcs, COMSIG_GLOB_BITMINING_PROXIMITY, PROC_REF(on_proximity))

/// Links mob damage & death as long as the netchair is there
/datum/mind/proc/connect_avatar_signals(mob/living/target)
	var/obj/structure/netchair/hosting_chair = netchair_ref?.resolve()
	if(isnull(hosting_chair))
		current.dust()
		return

	hosting_chair.avatar_ref = WEAKREF(target) // we need to set this just in case there's a subsequent hop

	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_linked_damage))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_sever_connection), override = TRUE)

/// Unregisters damage & death signals
/datum/mind/proc/disconnect_avatar_signals()
	UnregisterSignal(current, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(current, COMSIG_LIVING_DEATH)

/// Transfers damage from the avatar to the pilot
/datum/mind/proc/on_linked_damage(datum/source, damage, damage_type, def_zone, blocked, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/pilot = pilot_ref?.resolve()

	if(!pilot || damage_type == STAMINA || damage_type == OXYLOSS)
		return

	if(damage > 15)
		pilot.do_jitter_animation(damage)

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(pilot, TYPE_PROC_REF(/mob/living, emote), "scream")

	pilot.apply_damage(damage, damage_type, def_zone, blocked, forced)

/// Handles minds being swapped around in subsequent avatars
/datum/mind/proc/on_mind_transfer(datum/mind/source, mob/living/previous_body)
	SIGNAL_HANDLER

	disconnect_avatar_signals(previous_body)
	connect_avatar_signals(current)

/// Triggers when someone steps onto a trapped tile
/datum/mind/proc/on_proximity(datum/source, mob/living/intruder)
	SIGNAL_HANDLER

	current.throw_alert(
		ALERT_BITMINING_PROXIMITY,
		/atom/movable/screen/alert/bitmining_proximity,
		new_master = intruder
	)

/// Helper so that we don't have to apply args to register_signal
/datum/mind/proc/on_sever_connection(datum/source)
	SIGNAL_HANDLER

	last_death = world.time
	sever_avatar(forced = TRUE)

/// Disconnects the avatar and returns the mind to the pilot.
/// Handles case where the chair is destroyed via broken_chair
/datum/mind/proc/sever_avatar(forced = FALSE, obj/structure/netchair/broken_chair)
	var/mob/living/pilot = pilot_ref?.resolve()
	var/obj/structure/netchair/chair = netchair_ref?.resolve() || broken_chair
	if(isnull(chair)  || isnull(pilot))
		current.dust()

	disconnect_avatar_signals()
	UnregisterSignal(SSdcs, COMSIG_GLOB_BITMINING_PROXIMITY)
	UnregisterSignal(src, COMSIG_MIND_TRANSFERRED)
	UnregisterSignal(pilot, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(pilot, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(pilot, COMSIG_MOVABLE_UNBUCKLE)
	UnregisterSignal(pilot, COMSIG_LIVING_DEATH)

	netchair_ref = null
	pilot_ref = null

	current.playsound_local(src, "sound/magic/blink.ogg", 25, TRUE)
	current.flash_act(override_blindness_check = TRUE, visual = TRUE)
	chair.disconnect_occupant(src, forced)
