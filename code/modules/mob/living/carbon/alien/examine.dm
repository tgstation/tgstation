/mob/living/carbon/alien/examine(mob/user) //Copy-pasted from mankey code
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"

	if(src.handcuffed)
		msg += "It is \icon[src.handcuffed] handcuffed!\n"
	if(src.l_hand)
		msg += "It has \icon[src.l_hand] \a [src.l_hand] in its left hand.\n"
	if(src.r_hand)
		msg += "It has \icon[src.r_hand] \a [src.r_hand] in its right hand.\n"

	msg += "<span class='warning'>"

	if(src.getBruteLoss())
		if(src.getBruteLoss() < 30)
			msg += "It has minor bruising.\n"
		else
			msg += "<B>It has severe bruising!</B>\n"
	if(src.getFireLoss())
		if(src.getFireLoss() < 30)
			msg += "It has minor burns.\n"
		else
			msg += "<B>It has severe burns!</B>\n"
	if(src.getCloneLoss())
		if(src.getCloneLoss() < 30)
			msg += "It is slightly deformed.\n"
		else
			msg += "<b>It is severely deformed.</b>\n"
	if(src.getBrainLoss() > 60)
		msg += "It seems to be clumsy and unable to think.\n"

	if(src.fire_stacks > 0)
		msg += "It's covered in something flammable.\n"
	if(src.fire_stacks < 0)
		msg += "It's soaked in water.\n"

	if(src.stat == UNCONSCIOUS)
		msg += "It isn't responding to anything around it and seems to be asleep.\n"
	if(src.stat == DEAD)
		msg += "<span class='deadsay'>It is limp and unresponsive; there are no signs of life...</span>\n"

	msg += "</span>"


	msg += "*---------*</span>"

	user << msg
