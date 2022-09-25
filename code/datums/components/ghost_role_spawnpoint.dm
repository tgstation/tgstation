//Small component, but it helps to consolidate general observer role spawning behavior/checks into one place.
//This should only be for observer role checks that are universal. All case-specific checks (like rolebans) should be checked before the COMSIG_ATTEMPT_POSITION signal is sent
/datum/component/ghost_role_spawnpoint
	var/mob/living/spawnpoint
	var/ask_text = "Assume control of this mob and enter the realm of the living?"

/datum/component/ghost_role_spawnpoint/Initialize(ask_text)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	spawnpoint = parent
	src.ask_text = ask_text

/datum/component/ghost_role_spawnpoint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/get_clicked_player)

/datum/component/ghost_role_spawnpoint/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST)

/**
 * Runs the final validity checks for whether or not something should be able to be possessed by an observer
 *
 * Checks for things that should block any observers from possessing a mob. Role-specific checks should be done before
 * the COMSIG_ATTEMPT_POSSESSION is sent -- This only checks for circumstances that apply to every ghost-possessable spawnpoint
 *
 * Arguments:
 * * soul - The ghost that will be placed into the spawnpoint
 */

/datum/component/ghost_role_spawnpoint/proc/get_clicked_player(datum/source)
	SIGNAL_HANDLER
	var/mob/soul = source //This does not work
	if(spawnpoint.mind || spawnpoint.client)
		to_chat(soul, span_warning("Someone else has already assumed control of this!"))
		qdel(src) //Oh my goodness how did this even happen
		return
	if(!SSticker.HasRoundStarted())
		to_chat(soul, span_warning("You cannot assume control of this until after the round has started!"))
		return

	INVOKE_ASYNC(src, .proc/ask_message, soul)

/datum/component/ghost_role_spawnpoint/proc/ask_message(datum/source, mob/soul)
	var/ask_message = tgui_alert(usr, ask_text, "Are you sure?", list("Yes", "No"))
	if(ask_message != "Yes" || QDELETED(src))
		return

	//Rolebans to be implemented here as soon as I figure out how to do that

	soul.log_message("took control of [spawnpoint.name].", LOG_GAME) //Breaks about here, because soul is null
	spawnpoint.key = soul.key
	qdel(src) //We shant fit multiple souls into one cursed vessel. One is enough.
