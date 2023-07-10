/**
 * ### An avatar for the virtual domain.
 * Provides a link to the owner's body.
 */
/mob/living/carbon/human/avatar
	job = "Void Avatar"
	/// The owner of this avatar. Any pilot.
	var/mob/living/carbon/human/owner


/mob/living/carbon/human/avatar/proc/connect(mob/living/carbon/human/owner)
	src.owner = owner
	RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(disconnect), TRUE)
	RegisterSignals(owner, list(COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_DEATH), PROC_REF(disconnect))

/// Disconnects the avatar and returns the mind to the owner.
/mob/living/carbon/human/avatar/proc/disconnect(forced = FALSE)
	SIGNAL_HANDLER

	if(QDELETED(owner))
		dust()
		return

	playsound_local(src, 'sound/magic/blind.ogg', 30, 2)
	mind.transfer_to(owner)
	owner.flash_act()
	owner.Paralyze(3)

	UnregisterSignal(src, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(src, COMSIG_LIVING_DEATH)
	UnregisterSignal(owner, COMSIG_LIVING_STATUS_UNCONSCIOUS)
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)

	if(!forced || owner.stat == DEAD)
		return

	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	INVOKE_ASYNC(owner, PROC_REF(emote), "scream")
	owner.do_jitter_animation(100)
	to_chat(owner, span_danger("You've been forcefully disconnected from your avatar! Your thoughts feel scrambled!"))

/// Injures the owner of this avatar.
/mob/living/carbon/human/avatar/proc/on_damage(mob/target, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	if(QDELETED(owner) || damage_type == STAMINA || damage_type == OXY)
		return

	owner.apply_damage(damage, damage_type, def_zone, forced = TRUE)

