/mob/living/silicon/hivebot/examine(mob/user)
	user << "<span class='notice'>*---------*</span>"
	user << text("<span class='notice'>This is \icon[src] <B>[src.name]</B>!</span>")
	if (src.stat == 2)
		user << text("<span class='warning'>[src.name] is powered-down.</span>")
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			user << text("<span class='warning'>[src.name] looks slightly dented</span>")
		else
			user << text("<span class='danger'>[src.name] looks severely dented!</span>")
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			user << text("<span class='warning'>[src.name] looks slightly burnt!</span>")
		else
			user << text("<span class='danger'>[src.name] looks severely burnt!</span>")
	if (src.stat == 1)
		user << text("<span class='warning'>[src.name] doesn't seem to be responding.</span>")
