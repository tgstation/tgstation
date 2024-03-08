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

/mob/living/silicon/robot/try_sync_laws()
	if(QDELETED(connected_ai) || !lawupdate)
		return FALSE

	lawsync()
	law_change_counter++
	return TRUE

/mob/living/silicon/robot/proc/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai?.laws
	var/temp
	if (master)
		laws.ion.len = master.ion.len
		for (var/index in 1 to master.ion.len)
			temp = master.ion[index]
			if (length(temp) > 0)
				laws.ion[index] = temp

		laws.hacked.len = master.hacked.len
		for (var/index in 1 to master.hacked.len)
			temp = master.hacked[index]
			if (length(temp) > 0)
				laws.hacked[index] = temp

		if(master.zeroth_borg) //If the AI has a defined law zero specifically for its borgs, give it that one, otherwise give it the same one. --NEO
			temp = master.zeroth_borg
		else
			temp = master.zeroth
		laws.zeroth = temp

		laws.inherent.len = master.inherent.len
		for (var/index in 1 to master.inherent.len)
			temp = master.inherent[index]
			if (length(temp) > 0)
				laws.inherent[index] = temp

		laws.supplied.len = master.supplied.len
		for (var/index in 1 to master.supplied.len)
			temp = master.supplied[index]
			if (length(temp) > 0)
				laws.supplied[index] = temp

		var/datum/computer_file/program/robotact/program = modularInterface.get_robotact()
		if(program)
			var/datum/tgui/active_ui = SStgui.get_open_ui(src, program.computer)
			if(active_ui)
				active_ui.send_full_update()

	picturesync()

/mob/living/silicon/robot/post_lawchange(announce = TRUE)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(logevent),"Law update processed."), 0, TIMER_UNIQUE | TIMER_OVERRIDE) //Post_Lawchange gets spammed by some law boards, so let's wait it out
