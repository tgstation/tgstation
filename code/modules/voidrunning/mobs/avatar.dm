/**
 * ### An avatar for the virtual domain.
 * Provides a link to the owner's body.
 */
/mob/living/carbon/human/avatar
	/// The owner of this avatar.
	var/mob/living/carbon/human/owner

/mob/living/carbon/human/avatar/Initialize(mapload, mob/living/carbon/human/owner)
	. = ..()
	src.owner = owner
	job = "Void Avatar"
	RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(disconnect))

	RegisterSignals(owner, list(COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_DEATH), PROC_REF(disconnect))

/// Injures the owner of this avatar.
/mob/living/carbon/human/avatar/proc/on_damage(mob/target, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	if(QDELETED(owner) || damage_type == STAMINA || damage_type == OXY)
		return

	owner.apply_damage(damage, damage_type, def_zone, forced = TRUE)

/// Disconnects the avatar and returns the mind to the owner.
/mob/living/carbon/human/avatar/proc/disconnect()
	SIGNAL_HANDLER

	if(QDELETED(owner))
		dust()
		return

	flash_act()
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	mind.transfer_to(owner)
	if(owner.stat != DEAD)
		to_chat(owner, span_danger("You've been forcefully disconnected from your avatar! Your thoughts feel scrambled!"))
		owner.do_jitter_animation(100)
		owner.Paralyze(3)

	dust()
