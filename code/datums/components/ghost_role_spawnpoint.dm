/datum/component/ghost_role_spawnpoint //Small component, but it helps to consolidate general observer role spawning behavior/checks into one place.
	var/mob/living/spawnpoint

/datum/component/ghost_role_spawnpoint/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	spawnpoint = parent

/datum/component/ghost_role_spawnpoint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTEMPT_POSSESSION, .proc/get_clicked_player)

/datum/component/ghost_role_spawnpoint/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTEMPT_POSSESSION)

/**
 * Runs the final validity checks for whether or not something should be able to be possessed by an observer
 *
 * Checks for things that should block any observers from possessing a mob. Role-specific checks should be done before
 * the COMSIG_ATTEMPT_POSSESSION is sent -- This only checks for circumstances that apply to every ghost-possessable spawnpoint
 *
 * Arguments:
 * * soul - The ghost that will be placed into the spawnpoint
 */

/datum/component/ghost_role_spawnpoint/proc/get_clicked_player(datum/source, mob/soul)
	SIGNAL_HANDLER
	if(spawnpoint.mind || spawnpoint.client)
		to_chat(soul, span_warning("Someone else has already assumed control of this!"))
		qdel(src) //Oh my goodness how did this even happen
		return
	if(!SSticker.HasRoundStarted())
		to_chat(soul, span_warning("You cannot assume control of this until after the round has started!"))
		return
	soul.log_message("took control of [spawnpoint.name].", LOG_GAME) //Find something better to log this on
	spawnpoint.key = soul.key
	qdel(src) //We shant fit multiple souls into one cursed vessel. One is enough.
