/mob/living/silicon/robot/examine()
	set src in oview()

	if(!usr || !src)
		return
	if((usr.sdisabilities & BLIND || usr.blinded || usr.stat) && !istype(usr, /mob/dead/observer))
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!<br>"
	msg += "<span class='warning'>"
	if(getBruteLoss())
		if(getBruteLoss() < 60)
			msg += "It looks slightly dented.<br>"
		else
			msg += "<B>It looks severely dented!</B><br>"
	if(getFireLoss())
		if (getFireLoss() < 60)
			msg += "It looks slightly charred.<br>"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B><br>"
	if(health < -50)
		msg += "It looks barely operational.<br>"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span><br>"
	else
		msg += "Its cover is closed.<br>"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += "Its cognitive circuits do not appear to be functioning.<br>"
			else if(resting)
				msg += "It appears to be in standby mode.<br>"
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span><br>"
		if(DEAD)
			msg += "<span class='deadsay'>It looks like its system is corrupted and requires a reset.</span><br>"
	msg += "*---------*</span>"

	usr << msg
