/mob/living/silicon/robot/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[src] <B>[src.name]</B>!")
	if (src.stat == 2)
		usr << text("\red [src.name] is powered-down.")
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			usr << text("\red [src.name] looks slightly dented")
		else
			usr << text("\red <B>[src.name] looks severely dented!</B>")
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			usr << text("\red [src.name] looks slightly burnt!")
		else
			usr << text("\red <B>[src.name] looks severely burnt!</B>")
	if (src.stat == 1)
		usr << text("\red [src.name] doesn't seem to be responding.")
	if(opened)
		usr << "The cover is open and the power cell is [ cell ? "installed" : "missing"]."
	else
		usr << "The cover is closed."

	usr << print_flavor_text()

	return