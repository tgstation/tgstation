/atom/movable/screen/alert/brainwashed
	name = "Brainwashed"
	desc = "You've been brainwashed, you can't resist the Directives engraved upon your mind!"
	icon_state = ALERT_MIND_CONTROL

/atom/movable/screen/alert/brainwashed/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/brainwashed/brainwash_antag = owner?.mind?.has_antag_datum(/datum/antagonist/brainwashed)
	if(QDELETED(brainwash_antag))
		return FALSE
	owner.mind.announce_objectives()
	INVOKE_ASYNC(brainwash_antag, TYPE_PROC_REF(/datum/antagonist/brainwashed, ui_interact), owner)
