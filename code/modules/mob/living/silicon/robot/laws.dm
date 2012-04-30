/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	show_laws()

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
	var/datum/ai_laws/master = connected_ai ? connected_ai.laws : null
	var/temp
	if (master)
		laws.ion.len = master.ion.len
		for (var/index = 1, index <= master.ion.len, index++)
			temp = master.ion[index]
			if (length(temp) > 0)
				laws.ion[index] = temp

		if (!is_special_character(src) || mind.original != src)
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
		laws = new /datum/ai_laws/nanotrasen

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

/mob/living/silicon/robot/proc/statelaws() // -- TLE
//	set category = "AI Commands"
//	set name = "State Laws"
	src.say("Current Active Laws:")
	//src.laws_sanity_check()
	//src.laws.show_laws(world)
	var/number = 1
	sleep(10)



	if (src.laws.zeroth)
		if (src.lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			src.say("0. [src.laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (src.ioncheck[index] == "Yes")
				src.say("[num]. [law]")
				sleep(10)

	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			if (src.lawcheck[index+1] == "Yes")
				src.say("[number]. [law]")
				sleep(10)
			number++


	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]

		if (length(law) > 0)
			if(src.lawcheck.len >= number+1)
				if (src.lawcheck[number+1] == "Yes")
					src.say("[number]. [law]")
					sleep(10)
				number++


/mob/living/silicon/robot/verb/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite
	set category = "Robot Commands"
	set name = "State Laws"

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"



	if (src.laws.zeroth)
		if (!src.lawcheck[1])
			src.lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=\ref[src];lawc=0'>[src.lawcheck[1]] 0:</A> [src.laws.zeroth]<BR>"}

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]

		if (length(law) > 0)


			if (!src.ioncheck[index])
				src.ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawi=[index]'>[src.ioncheck[index]] [ionnum()]:</A> [law]<BR>"}
			src.ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			src.lawcheck.len += 1

			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]
		if (length(law) > 0)
			src.lawcheck.len += 1
			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++
	list += {"<br><br><A href='byond://?src=\ref[src];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")