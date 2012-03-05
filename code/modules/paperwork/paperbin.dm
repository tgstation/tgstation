/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = 3
	throw_speed = 3
	throw_range = 7
	var/amount = 30	//How much paper is in the bin.

/obj/item/weapon/paper_bin/MouseDrop(mob/user as mob)
	if ((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if (usr.hand)
			if (!( usr.l_hand ))
				spawn( 0 )
					src.attack_hand(usr, 1, 1)
					return
		else
			if (!( usr.r_hand ))
				spawn( 0 )
					src.attack_hand(usr, 0, 1)
					return
	return


/obj/item/weapon/paper_bin/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/paper_bin/attack_hand(mob/user as mob)
	if (amount >= 1)
		amount--
		update_icon()
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper
		P.loc = user.loc
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hand(P)
				user << "You take a paper out of the bin."
		else
			P.loc = get_turf_loc(src)
			user << "You take a paper out of the bin."
	else
		user << "The paper bin is empty!"

	add_fingerprint(user)
	return

/obj/item/weapon/paper_bin/examine()
	set src in oview(1)

	if(amount)
		if(amount > 1)
			usr << "There are [amount] papers in the bin."
		else
			usr << "There is one paper in the bin."
	else
		usr << "There are no papers in the bin."
	return

/obj/item/weapon/paper_bin/update_icon()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"