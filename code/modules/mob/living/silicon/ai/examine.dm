/mob/living/silicon/ai/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] <EM>[src]</EM>!\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It appears to be powered-down.</span>\n"
	else
		msg += "<span class='warning'>"
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 30)
				msg += "It looks slightly dented.\n"
			else
				msg += "<B>It looks severely dented!</B>\n"
		if (src.getFireLoss())
			if (src.getFireLoss() < 30)
				msg += "It looks slightly charred.\n"
			else
				msg += "<B>Its casing is melted and heat-warped!</B>\n"
		msg += "</span>"
		if (shunted == 0 && !src.client)
			msg += "[src]Core.exe has stopped responding! NTOS is searching for a solution to the problem...\n"
	msg += "*---------*</span>"

	to_chat(user, msg)

	..()