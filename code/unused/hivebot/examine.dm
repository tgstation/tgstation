/mob/living/silicon/hivebot/examine(mob/user)
	user << "\blue *---------*"
	user << text("\blue This is \icon[src] <B>[src.name]</B>!")
	if (src.stat == 2)
		user << text("\red [src.name] is powered-down.")
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			user << text("\red [src.name] looks slightly dented")
		else
			user << text("\red <B>[src.name] looks severely dented!</B>")
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			user << text("\red [src.name] looks slightly burnt!")
		else
			user << text("\red <B>[src.name] looks severely burnt!</B>")
	if (src.stat == 1)
		user << text("\red [src.name] doesn't seem to be responding.")
