/mob/living/silicon/pai/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, src.name)
	if (src.stat == 2)
		usr << text("\red [] appears disabled.", src.name)
	else
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 30)
				usr << text("\red [] looks slightly dented", src.name)
			else
				usr << text("\red <B>[]'s casing appears cracked and broken!</B>", src.name)
			if (src.getFireLoss())
				if (src.getFireLoss() < 30)
					usr << text("\red [] looks slightly charred!", src.name)
				else
					usr << text("\red <B>[]'s casing is melted and heat-warped!</B>", src.name)
				if (src.stat == 1)
					usr << text("\red [] doesn't seem to be responding.", src.name)

	usr << print_flavor_text()

	return