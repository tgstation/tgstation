/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
	laws_sanity_check()
	var/who

	if (everyone)
		who = world
	else
		who = src
	if(lawupdate)
		if (connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				src << "<b>AI signal lost, unable to sync laws.</b>"

			else
				lawsync()
				src << "<b>Laws synced with AI, be sure to note any changes.</b>"
				if(mind && mind.special_role == "traitor" && mind.original == src)
					src << "<b>Remember, your AI does NOT share or know about your law 0."
		else
			src << "<b>No AI selected to sync laws with, disabling lawsync protocol.</b>"
			lawupdate = 0

	who << "<b>Obey these laws:</b>"
	laws.show_laws(who)
	if (mind && (mind.special_role == "traitor" && mind.original == src) && connected_ai)
		who << "<b>Remember, [connected_ai.name] is technically your master, but your objective comes first.</b>"
	else if (connected_ai)
		who << "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>"
	else if (emagged)
		who << "<b>Remember, you are not required to listen to the AI.</b>"
	else
		who << "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>"


/mob/living/silicon/robot/proc/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai ? connected_ai.laws : null
	var/temp
	if (master)
		laws.ion.len = master.ion.len
		for (var/index = 1, index <= master.ion.len, index++)
			temp = master.ion[index]
			if (length(temp) > 0)
				laws.ion[index] = temp

		if (!is_special_character(src) || mind.original != src)
			if(master.zeroth_borg) //If the AI has a defined law zero specifically for its borgs, give it that one, otherwise give it the same one. --NEO
				temp = master.zeroth_borg
			else
				temp = master.zeroth
			laws.zeroth = temp

		laws.inherent.len = master.inherent.len
		for (var/index = 1, index <= master.inherent.len, index++)
			temp = master.inherent[index]
			if (length(temp) > 0)
				laws.inherent[index] = temp

		laws.supplied.len = master.supplied.len
		for (var/index = 1, index <= master.supplied.len, index++)
			temp = master.supplied[index]
			if (length(temp) > 0)
				laws.supplied[index] = temp
	return

/mob/living/silicon/robot/proc/laws_sanity_check()
	if (!laws)
		laws = new /datum/ai_laws/asimov

/mob/living/silicon/robot/proc/set_zeroth_law(var/law)
	laws_sanity_check()
	laws.set_zeroth_law(law)

/mob/living/silicon/robot/proc/add_inherent_law(var/law)
	laws_sanity_check()
	laws.add_inherent_law(law)

/mob/living/silicon/robot/proc/clear_inherent_laws()
	laws_sanity_check()
	laws.clear_inherent_laws()

/mob/living/silicon/robot/proc/add_supplied_law(var/number, var/law)
	laws_sanity_check()
	laws.add_supplied_law(number, law)

/mob/living/silicon/robot/proc/clear_supplied_laws()
	laws_sanity_check()
	laws.clear_supplied_laws()

/mob/living/silicon/robot/proc/add_ion_law(var/law)
	laws_sanity_check()
	laws.add_ion_law(law)

/mob/living/silicon/robot/proc/clear_ion_laws()
	laws_sanity_check()
	laws.clear_ion_laws()