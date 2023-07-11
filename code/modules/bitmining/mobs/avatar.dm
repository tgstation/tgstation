/**
 * ### An avatar for the virtual domain.
 * Provides a link to the owner's body.
 */
/mob/living/carbon/human/avatar
	job = "Bit Avatar"
	/// The pilot of this avatar. This changes on connection.
	var/mob/living/carbon/human/pilot

/mob/living/carbon/human/avatar/proc/connect(mob/living/carbon/human/pilot)
	src.pilot = pilot
	RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))
	RegisterSignals(src, list(
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_GIBBED,
		COMSIG_QSERVER_DISCONNECT
		),
		PROC_REF(disconnect),
		TRUE
	)
	RegisterSignals(pilot, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_UNBUCKLE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_DEATH
		),
		PROC_REF(disconnect),
		TRUE
	)

/// Disconnects the avatar and returns the mind to the pilot.
/mob/living/carbon/human/avatar/proc/disconnect(forced = FALSE)
	SIGNAL_HANDLER

	if(QDELETED(pilot))
		dust()
		return

	playsound_local(src, 'sound/magic/blind.ogg', 30, 2)
	mind.transfer_to(pilot)
	pilot.Paralyze(3)

	UnregisterSignal(src, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(src, COMSIG_LIVING_DEATH)
	UnregisterSignal(src, COMSIG_LIVING_GIBBED)
	UnregisterSignal(src, COMSIG_QSERVER_DISCONNECT)
	UnregisterSignal(pilot, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(pilot, COMSIG_LIVING_DEATH)
	UnregisterSignal(pilot, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(pilot, COMSIG_MOVABLE_UNBUCKLE)

	if(!forced || pilot.stat == DEAD)
		return

	pilot.flash_act()
	pilot.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	INVOKE_ASYNC(pilot, PROC_REF(emote), "scream")
	pilot.do_jitter_animation(100)
	to_chat(pilot, span_danger("You've been forcefully disconnected from your avatar! Your thoughts feel scrambled!"))

/// Injures the pilot of this avatar.
/mob/living/carbon/human/avatar/proc/on_damage(mob/target, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	if(QDELETED(pilot) || damage_type == STAMINA || damage_type == OXY)
		return

	if(damage > 15)
		pilot.do_jitter_animation(damage)

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(pilot, PROC_REF(emote), "scream")

	pilot.apply_damage(damage, damage_type, def_zone, forced = TRUE)

