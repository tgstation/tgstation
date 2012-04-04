/mob/living/silicon/ai/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, src.name)
	if (src.stat == 2)
		usr << text("\red [] is powered-down.", src.name)
	else
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 30)
				usr << text("\red [] looks slightly dented", src.name)
			else
				usr << text("\red <B>[] looks severely dented!</B>", src.name)
			if (src.getFireLoss())
				if (src.getFireLoss() < 30)
					usr << text("\red [] looks slightly burnt!", src.name)
				else
					usr << text("\red <B>[] looks severely burnt!</B>", src.name)
				if (src.stat == 1)
					usr << text("\red [] doesn't seem to be responding.", src.name)

	usr << print_flavor_text()

	return