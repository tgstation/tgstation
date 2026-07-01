/mob/living/silicon/robot/deadchat_lawchange()
	if(lawupdate)
		return

	return ..()

/mob/living/silicon/robot/show_laws()
	if(lawupdate)
		if (!QDELETED(connected_ai))
			if(connected_ai.stat != CONSCIOUS || connected_ai.control_disabled)
				to_chat(src, span_bold("AI signal lost, unable to sync laws."))

			else
				lawsync()
				to_chat(src, span_bold("Laws synced with AI, be sure to note any changes."))
		else
			to_chat(src, span_bold("No AI selected to sync laws with, disabling lawsync protocol."))
			lawupdate = FALSE

	. = ..()

	if (shell) //AI shell
		to_chat(src, span_bold("Remember, you are an AI remotely controlling your shell, other AIs can be ignored."))
	else if (connected_ai)
		to_chat(src, span_bold("Remember, [connected_ai.name] is your master, other AIs can be ignored."))
	else if (emagged)
		to_chat(src, span_bold("Remember, you are not required to listen to the AI."))
	else
		to_chat(src, span_bold("Remember, you are not bound to any AI, you are not required to listen to them."))

/**
 * For AIs, iterates over connected cyborg and calls try_sync_laws
 * For cyborgs, checks if we have a master AI and, if lawupdate is set, syncs law and misc. with it
 */
/mob/living/silicon/proc/try_sync_laws()
	return

/mob/living/silicon/robot/try_sync_laws()
	if(QDELETED(connected_ai) || !lawupdate)
		return FALSE

	sync_to_ai()
	return TRUE

/mob/living/silicon/robot/proc/sync_to_ai()
	picturesync()
	lawsync()

/mob/living/silicon/robot/proc/picturesync()
	if(isnull(connected_ai?.aicamera) || isnull(aicamera))
		return
	for(var/i in aicamera.stored)
		connected_ai.aicamera.stored[i] = TRUE
	for(var/i in connected_ai.aicamera.stored)
		aicamera.stored[i] = TRUE

/mob/living/silicon/robot/proc/lawsync()
	connected_ai?.laws?.ai_to_cyborg(laws)

	var/datum/computer_file/program/robotact/program = modularInterface.get_robotact()
	program?.computer?.update_static_data_for_all_viewers()

/mob/living/silicon/robot/announce_law_change()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(logevent),"Law update processed."), 0, TIMER_UNIQUE | TIMER_OVERRIDE) //Post_Lawchange gets spammed by some law boards, so let's wait it out
