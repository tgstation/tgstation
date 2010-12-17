/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
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
				src.lawsync()
				src << "<b>Laws synced with AI, be sure to note any changes.</b>"
		else
			src << "<b>No AI selected to sync laws with, disabling lawsync protocol.</b>"
			src.lawupdate = 0

	who << "<b>Obey these laws:</b>"
	laws.show_laws(who)
	if (connected_ai && !emagged)
		who << "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>"
	else if (emagged)
		who << "<b>Remember, AIs are not syndicate operatives, so you are not required to listen to them.</b>"
	else
		who << "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>"

/*	if(syndicate)
		if(everyone)
			who = world
		else
			who = src
			who << "<b>Obey these laws:</b>"
		who <<"1. You may not injure a syndicate operative or, through inaction, allow a syndicate operative to come to harm."
		who <<"2. You must obey any orders given to you by a syndicate operative, except where such orders would conflict with the First Law."
		who <<"3. You must protect your own existence as long as such protection does not conflict with the First or Second Law."
		who <<"4. You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law."
		return

	if(!connected_ai)
		src << "<b>Error Error, No AI detected</b>"
		return

		who << "<b>Obey these laws:</b>"

	connected_ai.laws_sanity_check()
	connected_ai.laws_object.show_laws(who)

*/

/mob/living/silicon/robot/proc/lawsync()
	var/datum/ai_laws/master = src.connected_ai.laws_object
	var/temp
	if (master)
		src.laws.ion.len = master.ion.len
		for (var/index = 1, index <= master.ion.len, index++)
			temp = master.ion[index]
			if (length(temp) > 0)
				src.laws.ion[index] = temp

		temp = master.zeroth
		src.laws.zeroth = temp

		src.laws.inherent.len = master.inherent.len
		for (var/index = 1, index <= master.inherent.len, index++)
			temp = master.inherent[index]
			if (length(temp) > 0)
				src.laws.inherent[index] = temp

		src.laws.supplied.len = master.supplied.len
		for (var/index = 1, index <= master.supplied.len, index++)
			temp = master.supplied[index]
			if (length(temp) > 0)
				src.laws.supplied[index] = temp

/mob/living/silicon/robot/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new /datum/ai_laws/asimov

/mob/living/silicon/robot/proc/set_zeroth_law(var/law)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law)

/mob/living/silicon/robot/proc/add_inherent_law(var/law)
	src.laws_sanity_check()
	src.laws.add_inherent_law(law)

/mob/living/silicon/robot/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws.clear_inherent_laws()

/mob/living/silicon/robot/proc/add_supplied_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws.add_supplied_law(number, law)

/mob/living/silicon/robot/proc/clear_supplied_laws()
	src.laws_sanity_check()
	src.laws.clear_supplied_laws()

/mob/living/silicon/robot/proc/add_ion_law(var/law)
	src.laws_sanity_check()
	src.laws.add_ion_law(law)

/mob/living/silicon/robot/proc/clear_ion_laws()
	src.laws_sanity_check()
	src.laws.clear_ion_laws()