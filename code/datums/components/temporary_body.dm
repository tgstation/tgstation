/**
 * ## temporary_body
 *
 * Used on mobs when they are meant to be a 'temporary body'
 * Holds a reference to an old mind, to put them back in
 * once the body this component is attached to, is being deleted.
 */
/datum/component/temporary_body
	///The old mind we will be put back into when parent is being deleted.
	var/datum/mind/old_mind
	///The old body we will be put back into when parent is being deleted.
	var/mob/old_body
	/// Returns the mind if the PARENT dies by any means
	var/return_on_death = FALSE
	/// Returns the mind if the OLD_BODY is revived
	var/return_on_revive = FALSE

/datum/component/temporary_body/Initialize(datum/mind/old_mind, return_on_death = FALSE, return_on_revive = FALSE)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(isnull(old_mind))
		stack_trace("Tried to create a temporary_body component without an old_mind!")
		return COMPONENT_INCOMPATIBLE

	src.old_mind = old_mind
	src.old_body = old_mind.current
	src.return_on_death = return_on_death
	src.return_on_revive = return_on_revive

/datum/component/temporary_body/RegisterWithParent()
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(return_mind))
	if(return_on_death)
		RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(return_mind))

	RegisterSignal(old_mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer))

	if(!isnull(old_body))
		register_body_signals()

/datum/component/temporary_body/proc/register_body_signals()
	ADD_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	RegisterSignal(old_body, COMSIG_QDELETING, PROC_REF(on_body_destroy))
	if(return_on_revive)
		RegisterSignal(old_body, COMSIG_LIVING_REVIVE, PROC_REF(return_mind))

/datum/component/temporary_body/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_QDELETING)
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)
	UnregisterSignal(old_mind, COMSIG_MIND_TRANSFERRED)
	if(!isnull(old_body))
		unregister_body_signals()

/datum/component/temporary_body/proc/unregister_body_signals()
	REMOVE_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	UnregisterSignal(old_body, COMSIG_QDELETING)
	UnregisterSignal(old_body, COMSIG_LIVING_REVIVE)

/datum/component/temporary_body/Destroy()
	. = ..()
	old_mind = null
	old_body = null

/// Swap the target of old_body if old_mind is transferred somewhere while we're away
/datum/component/temporary_body/proc/on_mind_transfer(...)
	SIGNAL_HANDLER

	if(!isnull(old_body))
		unregister_body_signals()
	old_body = old_mind.current
	if(!isnull(old_body))
		register_body_signals()

/**
 * Sends the mind of the temporary body back into their previous host
 * If the previous host is alive, we'll also force them into the body.
 * Otherwise we'll let them hang out as a ghost still.
 */
/datum/component/temporary_body/proc/return_mind(...)
	SIGNAL_HANDLER

	var/mob/new_body = parent
	var/mob/dead/observer/ghost = new_body.get_ghost() || new_body.ghostize()
	if(QDELETED(ghost))
		stack_trace("[src] belonging to [parent] was completely unable to find a ghost to put back into a body!")
		qdel(src) // i guess this is useless now
		return

	ghost.mind = old_mind
	if(old_body)
		if(old_mind.current != old_body)
			stack_trace("Temporary body returning mind to old body, but the mind's current body doesn't match the old body!")
			old_mind.set_current(old_body)
		if(old_body.stat != DEAD)
			ghost.reenter_corpse()

	qdel(src) // we're done here

/// Body reference handling
/datum/component/temporary_body/proc/on_body_destroy(...)
	SIGNAL_HANDLER
	old_body = null
