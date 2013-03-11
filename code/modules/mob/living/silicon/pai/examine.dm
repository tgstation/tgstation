/mob/living/silicon/pai/examine() //removed as it was pointless...moved to the pai-card instead.
	/* This is totaly pointless because this mob is contained inside a card!
	set src in oview()

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It appears to be offline.</span>\n"
	else
		msg += "<span class='warning'>"
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 30)
				msg += "It looks slightly dented.\n"
			else
				msg += "<B>Its casing appears cracked and broken!</B>\n"
		if (src.getFireLoss())
			if (src.getFireLoss() < 30)
				msg += "It looks slightly charred!\n"
			else
				msg += "<B>Its casing is melted and heat-warped!</B>\n"
		if (src.stat == UNCONSCIOUS)
			msg += "It doesn't seem to be responding and its text-output is lagging.\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	*/
	return