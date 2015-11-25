/mob/living/silicon/robot/examine(mob/user)
	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\\mob\living\silicon\robot\examine.dm:9: var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>[custom_name ? ", [modtype] [braintype]" : ""]!\n"
	var/msg = {"<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>[custom_name ? ", [modtype] [braintype]" : ""]!\n
<span class='warning'>"}
	// END AUTOFIX
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed.\n"

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)	msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)		msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)			msg += "<span class='deadsay'>It looks completely unsalvageable.</span>\n"
	msg += "*---------*</span>"

	if(print_flavor_text()) msg += "[print_flavor_text()]\n"

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"

	to_chat(user, msg)
