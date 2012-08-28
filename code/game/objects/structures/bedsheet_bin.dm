// BEDSHEET BIN

/obj/structure/bedsheetbin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/bedsheet))
		del(W)
		src.amount++
	return

/obj/structure/bedsheetbin/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/bedsheetbin/attack_hand(mob/user as mob)
	if (src.amount >= 1)
		src.amount--
		new /obj/item/weapon/bedsheet( src.loc )
		add_fingerprint(user)

/obj/structure/bedsheetbin/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	if (src.amount <= 0)
		src.amount = 0
		usr << "There are no bed sheets in the bin."
	else
		if (src.amount == 1)
			usr << "There is one bed sheet in the bin."
		else
			usr << text("There are [] bed sheets in the bin.", src.amount)
	return