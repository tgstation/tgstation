
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

/mob/living/silicon/ai/proc/set_zeroth_law(var/law, var/law_borg)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/ai/proc/add_inherent_law(var/law)
	src.laws_sanity_check()
	src.laws.add_inherent_law(law)

/mob/living/silicon/ai/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws.clear_inherent_laws()

/mob/living/silicon/ai/proc/add_ion_law(var/law)
	src.laws_sanity_check()
	src.laws.add_ion_law(law)
	for(var/mob/living/silicon/robot/R in mob_list)
		if(R.lawupdate && (R.connected_ai == src))
			R << "\red " + law + "\red...LAWS UPDATED"

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
	if(statelaws_cooldown > world.time)
		var/wait = Ceiling((statelaws_cooldown - world.time) * 0.1)
		src << "<span class='notice'>Wait for [wait] more second\s.</span>"
		return

	statelaws_cooldown = world.time + 150
	say("Current Active Laws:")
	var/number = 1
	sleep(10)

	if(laws.zeroth)
		if(lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			say("0. [src.laws.zeroth]")
			sleep(10)

	for(var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]
		var/num = ionnum()
		if(length(law) > 0)
			if(ioncheck[index] == "Yes")
				say("[num]. [law]")
				sleep(10)

	for(var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]
		if(length(law) > 0)
			if(lawcheck[index+1] == "Yes")
				say("[number]. [law]")
				sleep(10)
			number++

	for(var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]
		if(length(law) > 0)
			if(lawcheck.len >= number+1)
				if(lawcheck[number+1] == "Yes")
					say("[number]. [law]")
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