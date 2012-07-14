/*
CONTAINS:
WRAPPING PAPER
GIFTS
BEDSHEET BIN
PHOTOGRAPHS

*/
// WRAPPING PAPER

/obj/item/weapon/wrapping_paper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (!( locate(/obj/structure/table, src.loc) ))
		user << "\blue You MUST put the paper on a table!"
	if (W.w_class < 4)
		if ((istype(user.l_hand, /obj/item/weapon/wirecutters) || istype(user.r_hand, /obj/item/weapon/wirecutters)))
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				user << "\blue You need more paper!"
				return
			else
				if(istype(W, /obj/item/smallDelivery) || istype(W, /obj/item/weapon/gift)) //No gift wrapping gifts!
					return

				src.amount -= a_used
				user.drop_item()
				var/obj/item/weapon/gift/G = new /obj/item/weapon/gift( src.loc )
				G.size = W.w_class
				G.w_class = G.size + 1
				G.icon_state = text("gift[]", G.size)
				G.gift = W
				W.loc = G
				G.add_fingerprint(user)
				W.add_fingerprint(user)
				src.add_fingerprint(user)
			if (src.amount <= 0)
				new /obj/item/weapon/c_tube( src.loc )
				del(src)
				return
		else
			user << "\blue You need scissors!"
	else
		user << "\blue The object is FAR too large!"
	return


/obj/item/weapon/wrapping_paper/examine()
	set src in oview(1)

	..()
	usr << text("There is about [] square units of paper left!", src.amount)
	return

/obj/item/weapon/wrapping_paper/attack(mob/target as mob, mob/user as mob)
	if (!istype(target, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = target

	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) || H.stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (H.loc)
			src.amount -= 2

			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present

			H.loc = present
			H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wrapped with [src.name]  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to wrap [H.name] ([H.ckey])</font>")

			log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to wrap [H.name] ([H.ckey])</font>")

		else
			user << "\blue You need more paper."
	else
		user << "Theyre moving around too much. a Straitjacket would help."





// GIFTS

/obj/item/weapon/gift/attack_self(mob/user as mob)
	user.drop_item()
	if(src.gift)
		user.put_in_active_hand(gift)
		src.gift.add_fingerprint(user)
	else
		user << "\blue The gift was empty!"
	del(src)
	return

/obj/item/weapon/a_gift/ex_act()
	del(src)
	return


/obj/effect/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	user << "\blue You cant move."

/obj/effect/spresent/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (!istype(W, /obj/item/weapon/wirecutters))
		user << "\blue I need wirecutters for that."
		return

	user << "\blue You cut open the present."

	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	del(src)


/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	switch(pick("flash", "t_gun", "l_gun", "shield", "sword", "axe"))
		if("flash")
			var/obj/item/device/flash/W = new /obj/item/device/flash( M )
			M.put_in_active_hand(W)
			W.add_fingerprint(M)
			del(src)
			return
		if("l_gun")
			var/obj/item/weapon/gun/energy/laser/W = new /obj/item/weapon/gun/energy/laser( M )
			M.put_in_active_hand(W)
			W.add_fingerprint(M)
			del(src)
			return
		if("t_gun")
			var/obj/item/weapon/gun/energy/taser/W = new /obj/item/weapon/gun/energy/taser( M )
			M.put_in_active_hand(W)
			W.add_fingerprint(M)
			del(src)
			return
		if("sword")
			var/obj/item/weapon/melee/energy/sword/W = new /obj/item/weapon/melee/energy/sword( M )
			M.put_in_active_hand(W)
			W.add_fingerprint(M)
			del(src)
			return
		if("axe")
			var/obj/item/weapon/melee/energy/axe/W = new /obj/item/weapon/melee/energy/axe( M )
			M.put_in_active_hand(W)
			W.add_fingerprint(M)
			del(src)
			return
		else
	return

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

// PHOTOGRAPH

/obj/item/weapon/paper/photograph/New()

	..()
	src.pixel_y = 0
	src.pixel_x = 0
	return

/obj/item/weapon/paper/photograph/attack_self(mob/user as mob)

	var/n_name = copytext(sanitize(input(user, "What would you like to label the photo?", "Paper Labelling", null)  as text),1,32)
	if ((src.loc == user && user.stat == 0))
		src.name = text("photo[]", (n_name ? text("- '[]'", n_name) : null))
	src.add_fingerprint(user)
	return
