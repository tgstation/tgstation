/mob/living/silicon/hivebot/examine()
	set src in oview()

	usr << "<span class='notice'>*---------*</span>"
	usr << text("<span class='notice'>This is \icon[src] <B>[src.name]</B>!</span>")
	if (src.stat == 2)
		usr << text("<span class='danger'>[src.name] is powered-down.</span>")
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			usr << text("<span class='danger'>[src.name] looks slightly dented</span>")
		else
			usr << text("<span class='userdanger'>[src.name] looks severely dented!</span>")
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			usr << text("<span class='danger'>[src.name] looks slightly burnt!</span>")
		else
			usr << text("<span class='userdanger'>[src.name] looks severely burnt!</span>")
	if (src.stat == 1)
		usr << text("<span class='danger'>[src.name] doesn't seem to be responding.</span>")
	return