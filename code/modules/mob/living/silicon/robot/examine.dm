/mob/living/silicon/robot/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if(desc)
		msg += "[desc]\n"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		msg += "It is holding \icon[act_module] \a [act_module].\n"
	msg += "<span class='warning'>"
	if (src.getBruteLoss())
		if (src.getBruteLoss() < maxHealth*0.5)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (src.getFireLoss() < maxHealth*0.5)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	if (src.health < -maxHealth*0.5)
		msg += "It looks barely operational.\n"
	if (src.fire_stacks < 0)
		msg += "It's covered in water.\n"
	else if (src.fire_stacks > 0)
		msg += "It's coated in something flammable.\n"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed[locked ? "" : ", and looks unlocked"].\n"

	if(cell && cell.charge <= 0)
		msg += "<span class='warning'>Its battery indicator is blinking red!</span>\n"

	if(is_servant_of_ratvar(src) && user.Adjacent(src) && !stat) //To counter pseudo-stealth by using headlamps
		msg += "<span class='warning'>Its eyes are glowing a blazing yellow!</span>\n"

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)
				msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)
			msg += "<span class='deadsay'>It looks like its system is corrupted and requires a reset.</span>\n"
	msg += "*---------*</span>"

	user << msg

	..()
