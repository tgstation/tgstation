<<<<<<< HEAD
/mob/living/silicon/ai/examine(mob/user)
	. = list("<span class='info'>*---------*\nThis is [icon2html(src, user)] <EM>[src]</EM>!")
	if (stat == DEAD)
		. += "<span class='deadsay'>It appears to be powered-down.</span>"
	else
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				. += "<span class='warning'>It looks slightly dented.</span>"
			else
				. += "<span class='warning'><B>It looks severely dented!</B></span>"
		if (getFireLoss())
			if (getFireLoss() < 30)
				. += "<span class='warning'>It looks slightly charred.</span>"
			else
				. += "<span class='warning'><B>Its casing is melted and heat-warped!</B></span>"
		if(deployed_shell)
			. += "The wireless networking light is blinking.\n"
		else if (!shunted && !client)
			. += "[src]Core.exe has stopped responding! NTOS is searching for a solution to the problem...\n"
	. += "*---------*</span>"

	. += ..()
=======
/mob/living/silicon/ai/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [icon2html(src, user)] <EM>[src]</EM>!\n"
	if (stat == DEAD)
		msg += "<span class='deadsay'>It appears to be powered-down.</span>\n"
	else
		msg += "<span class='warning'>"
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				msg += "It looks slightly dented.\n"
			else
				msg += "<B>It looks severely dented!</B>\n"
		if (getFireLoss())
			if (getFireLoss() < 30)
				msg += "It looks slightly charred.\n"
			else
				msg += "<B>Its casing is melted and heat-warped!</B>\n"
		msg += "</span>"
		if(deployed_shell)
			msg += "The wireless networking light is blinking.\n"
		else if (!shunted && !client)
			msg += "[src]Core.exe has stopped responding! NTOS is searching for a solution to the problem...\n"
	msg += "*---------*</span>"

	to_chat(user, msg)
	..()
	return msg
>>>>>>> Updated this old code to fork
