/mob/living/carbon/metroid/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, src.name)
	if (src.stat == 2)
		usr << text("\red [] is limp and unresponsive.", src.name)
	else
		if (src.getBruteLoss())
			if (src.getBruteLoss() < 40)
				usr << text("\red [] has some punctures in its flesh!", src.name)
			else
				usr << text("\red <B>[] has a lot of punctures and tears in its flesh!</B>", src.name)

		switch(powerlevel)

			if(2 to 3)
				usr << text("\blue [] seems to have little bit of electrical activity inside it.", src.name)

			if(4 to 5)
				usr << text("\blue [] seems to some electricity inside of it.", src.name)

			if(6 to 9)
				usr << text("\blue [] seems to have a lot of electricity inside of it.", src.name)

			if(10)
				usr << text("\blue <B>[] seems to have extreme electrical activity inside it!</B>", src.name)

	usr << "[print_flavor_text()]\n"

	return