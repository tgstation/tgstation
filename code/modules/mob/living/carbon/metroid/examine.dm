/mob/living/carbon/metroid/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, src.name)
	if (src.stat == 2)
		usr << text("\red [] is limp and unresponsive.", src.name)
	else
		if (src.bruteloss)
			if (src.bruteloss < 30)
				usr << text("\red [] looks slightly damaged!", src.name)
			else
				usr << text("\red <B>[] looks severely damaged!</B>", src.name)

		switch(powerlevel)

			if(2 to 3)
				usr << text("[] seems to have very little electrical activity inside it.", src.name)

			if(4 to 5)
				usr << text("[] seems to some electricity inside of it.", src.name)

			if(6 to 9)
				usr << text("[] seems to have a lot of electricity inside of it.", src.name)

			if(10)
				usr << text("<B>[] seems to have extreme electrical activity inside it!</B>", src.name)

	return