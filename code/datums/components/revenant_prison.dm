/datum/component/revenant_prison
	// The revenant which is currently imprisoned
	var/mob/living/basic/revenant/revenant
	// ckey of the player who controlled it when it was imprisoned
	var/old_ckey

/datum/component/revenant_prison/Initialize(mob/living/basic/revenant/revenant)
	. = ..()
	if(!revenant)
		return COMPONENT_INCOMPATIBLE
	src.revenant = revenant
	old_ckey = revenant.client?.ckey
	revenant.forceMove(parent)
	RegisterSignal(parent, COMSIG_REVENANT_RELEASE, PROC_REF(release_revenant))

/datum/component/revenant_prison/Destroy()
	if(revenant)
		qdel(revenant)
	return ..()

/datum/component/revenant_prison/proc/release_revenant(cause)
	SIGNAL_HANDLER
	if(!revenant)
		return
	message_admins("[revenant] has been released from [parent]. Cause: [cause]")
	if(!revenant.reform(old_ckey))
		message_admins("Couldn't reform revenant upon release.")
	revenant = null
	qdel(src)

/datum/component/revenant_prison/RegisterWithParent()
	RegisterSignal(parent, COMSIG_REVENANT_RELEASE, PROC_REF(release_revenant))

/datum/component/revenant_prison/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_REVENANT_RELEASE)

/datum/component/revenant_prison/PostTransfer()
	revenant.forceMove(parent)
