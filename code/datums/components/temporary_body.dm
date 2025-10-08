/**
 * ##temporary_body
 *
 * Used on living mobs when they are meant to be a 'temporary body'
 * Holds a reference to an old mind & body, to put them back in
 * once the body this component is attached to, is being deleted.
 */
/datum/component/temporary_body
	///The old mind we will be put back into when parent is being deleted.
	var/datum/weakref/old_mind_ref
	///The old body we will be put back into when parent is being deleted.
	var/datum/weakref/old_body_ref
	/// Returns the mind if the parent dies by any means
	var/delete_on_death = FALSE
	/// If the temporary body is attached to a permanent body (split personality body) then we dont ghostize and instead just simply transfer client back
	var/perma_body_attached

/datum/component/temporary_body/Initialize(datum/mind/old_mind, mob/living/old_body, delete_on_death = FALSE, perma_body_attached = FALSE)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.old_mind_ref = WEAKREF(old_mind)
	if(istype(old_body))
		ADD_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
		src.old_body_ref = WEAKREF(old_body)
	src.delete_on_death = delete_on_death
	src.perma_body_attached = perma_body_attached

/datum/component/temporary_body/RegisterWithParent()
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_destroy))

	if(delete_on_death)
		RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_parent_destroy))

/datum/component/temporary_body/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_QDELETING)

/**
 * Sends the mind of the temporary body back into their previous host
 * If the previous host is alive, we'll force them into the body.
 * Otherwise we'll let them hang out as a ghost still.
 */
/datum/component/temporary_body/proc/on_parent_destroy()
	SIGNAL_HANDLER
	var/datum/mind/old_mind = old_mind_ref?.resolve()
	var/mob/living/old_body = old_body_ref?.resolve() || old_mind.current

	if(!old_mind)
		return

	var/mob/living/living_parent = parent
	if(!perma_body_attached)
		var/mob/dead/observer/ghost = living_parent.ghostize()
		if(!ghost)
			ghost = living_parent.get_ghost()
		if(!ghost)
			CRASH("[src] belonging to [parent] was completely unable to find a ghost to put back into a body!")
		ghost.mind = old_mind
	if(old_body?.stat != DEAD)
		old_mind.transfer_to(old_body, force_key_move = TRUE)
	else
		old_mind.set_current(old_body)

	if(old_body)
		REMOVE_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))

	old_mind = null
	old_body = null
