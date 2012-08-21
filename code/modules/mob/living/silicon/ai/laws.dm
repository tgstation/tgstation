
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/ai/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		who << "<b>Obey these laws:</b>"

	src.laws_sanity_check()
	src.laws.show_laws(who)

/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new /datum/ai_laws/asimov

/mob/living/silicon/ai/proc/set_zeroth_law(var/law)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law)

/mob/living/silicon/ai/proc/add_inherent_law(var/law)
	src.laws_sanity_check()
	src.laws.add_inherent_law(law)

/mob/living/silicon/ai/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws.clear_inherent_laws()

/mob/living/silicon/ai/proc/add_ion_law(var/law)
	src.laws_sanity_check()
	src.laws.add_ion_law(law)

/mob/living/silicon/ai/proc/clear_ion_laws()
	src.laws_sanity_check()
	src.laws.clear_ion_laws()

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	src.laws_sanity_check()
	src.laws.clear_supplied_laws()





/mob/living/silicon/ai/proc/statelaws() // -- TLE
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


/mob/living/silicon/ai/verb/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite
	set category = "AI Commands"
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