/mob/living/carbon/monkey/examine()
	set src in oview()

	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, src.name)
	if (src.handcuffed)
		usr << text("\blue [] is handcuffed! \icon[]", src.name, src.handcuffed)
	if (src.wear_mask)
		usr << text("\blue [] has a \icon[] [] on \his[] head!", src.name, src.wear_mask, src.wear_mask.name, src)
	if (src.l_hand)
		usr << text("\blue [] has a \icon[] [] in \his[] left hand!", src.name, src.l_hand, src.l_hand.name, src)
	if (src.r_hand)
		usr << text("\blue [] has a \icon[] [] in \his[] right hand!", src.name, src.r_hand, src.r_hand.name, src)
	if (src.back)
		usr << text("\blue [] has a \icon[] [] on \his[] back!", src.name, src.back, src.back.name, src)
	if (src.stat == 2)
		usr << text("\red [] is limp and unresponsive, a dull lifeless look in their eyes.", src.name)
	else
		if (src.bruteloss)
			if (src.bruteloss < 30)
				usr << text("\red [] looks slightly bruised!", src.name)
			else
				usr << text("\red <B>[] looks severely bruised!</B>", src.name)
		if (src.fireloss)
			if (src.fireloss < 30)
				usr << text("\red [] looks slightly burnt!", src.name)
			else
				usr << text("\red <B>[] looks severely burnt!</B>", src.name)
		if (src.stat == 1)
			usr << text("\red [] doesn't seem to be responding to anything around them, their eyes closed as though asleep.", src.name)
	return