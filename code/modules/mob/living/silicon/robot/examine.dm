/mob/living/silicon/robot/examine()
	set src in oview()

	if(!usr || !src)	return
	if( (usr.sdisabilities & BLIND || usr.blinded || usr.stat) && !istype(usr,/mob/dead/observer) )
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	msg += "<span class='warning'>"
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

	usr << msg
	return
