/*
CONTAINS:
PAPER
PAPER BIN
WRAPPING PAPER
GIFTS
BEDSHEET BIN
PHOTOGRAPHS
CLIPBOARDS
NOTEBOOK

*/

// PAPER

/obj/item/weapon/paper/New()
	..()
	src.pixel_y = rand(-8, 8)
	src.pixel_x = rand(-9, 9)
	spawn(2)
		if(src.info)
			src.overlays += "paper_words"
		return

/obj/item/weapon/paper/process()
	if(iteration < 5)
		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = get_turf(M)
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)
		iteration++
	else
		for(var/mob/M in viewers(5, get_turf(src)))
			M << "\red \the [src] burns up."
		if(istype(src.loc,/mob))
			var/mob/M = src.loc
			M.total_luminosity -= 8
		else
			src.sd_SetLuminosity(0)
		processing_objects.Remove(src)
		del(src)

/obj/item/weapon/paper/update_icon() //derp.
	if(src.info)
		src.overlays += "paper_words"
	if(src.burning)
		src.overlays += "paper_fire"
	return


/obj/item/weapon/paper/pickup(mob/user)
	if(burning)
		src.sd_SetLuminosity(0)
		user.total_luminosity += 8

/obj/item/weapon/paper/dropped(mob/user)
	if(burning)
		user.total_luminosity -= 8
		src.sd_SetLuminosity(8)

/obj/item/weapon/paper/examine()
	set src in view()

	..()
	if (!( istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon) ))
		// actually strip formatting, so stars doesn't screw up
		var/t = dd_replacetext(src.info, "\n", "")
		t = dd_replacetext(t, "\[b\]", "")
		t = dd_replacetext(t, "\[/b\]", "")
		t = dd_replacetext(t, "\[i\]", "")
		t = dd_replacetext(t, "\[/i\]", "")
		t = dd_replacetext(t, "\[u\]", "")
		t = dd_replacetext(t, "\[/u\]", "")
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(t)), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	else
		// if people want lazy bb-code
		var/t = dd_replacetext(src.info, "\n", "<BR>")
		t = dd_replacetext(t, "\[b\]", "<B>")
		t = dd_replacetext(t, "\[/b\]", "</B>")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = text("<font face=calligrapher>[]</font>", t)
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, t), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	return


/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if ((usr.mutations & CLUMSY) && prob(50))
		usr << text("\red You cut yourself on the paper.")
		return
	var/n_name = input(usr, "What would you like to label the paper?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((src.loc == usr && usr.stat == 0))
		src.name = n_name && n_name != "" ? n_name : "Untitled paper"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	examine()
	return

/obj/item/weapon/paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if (istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if (dist < 2)
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	return

/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	if (istype(P, /obj/item/weapon/pen))
		if(src.stamped != null && src.stamped.len > 0)
			user << "\blue This paper has been stamped and can no longer be edited."
			return

		for(var/mob/O in viewers(user))
			O.show_message("\blue [user] starts writing on the paper with [P].", 1)
		var/t = "[src.info]"
		do
			t = input(user, "What text do you wish to add?", text("[]", src.name), t)  as message
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return

			if(lentext(t) >= MAX_PAPER_MESSAGE_LEN)
				var/cont = input(user, "Your message is too long! Would you like to continue editing it?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(lentext(t) > MAX_PAPER_MESSAGE_LEN)


		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return

		// check for exploits
		for(var/tag in paper_blacklist)
			if(findtext(t,"<"+tag))
				user << "\blue You think to yourself, \"Hm.. this is only paper...\""
				return

		if(!overlays.Find("paper_words"))
			src.overlays += "paper_words"

		src.info = t
	else
		if(is_burn(P))
			for(var/mob/M in viewers(5, get_turf(src)))
				M << "\red [user] sets \the [src] on fire."
			user.total_luminosity += 8
			burning = 1
			processing_objects.Add(src)
			update_icon()
			return
		if(istype(P, /obj/item/weapon/stamp))
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return
			if(!src.infoold)
				src.infoold = src.info
			src.info += text("<BR><i>This paper has been stamped with the [].</i><BR>", P.name)
			switch(P.type)
				if(/obj/item/weapon/stamp/captain)
					src.overlays += "paper_stamped_cap"
				if(/obj/item/weapon/stamp/hop)
					src.overlays += "paper_stamped_hop"
				if(/obj/item/weapon/stamp/hos)
					src.overlays += "paper_stamped_hos"
				if(/obj/item/weapon/stamp/ce)
					src.overlays += "paper_stamped_ce"
				if(/obj/item/weapon/stamp/rd)
					src.overlays += "paper_stamped_rd"
				if(/obj/item/weapon/stamp/cmo)
					src.overlays += "paper_stamped_cmo"
				if(/obj/item/weapon/stamp/denied)
					src.overlays += "paper_stamped_denied"
				if(/obj/item/weapon/stamp/clown)
					src.overlays += "paper_stamped_clown"
				if(/obj/item/weapon/stamp/centcom)
					src.overlays += "paper_stamped_cent"
				else
					src.overlays += "paper_stamped"
			if(!stamped)
				stamped = new
			stamped += P.type

			user << "\blue You stamp the paper with your rubber stamp."

		if(istype(P, /obj/item/weapon/stamperaser))
			switch(alert("Would you like to erase all stamps, or forge one?","Choose.","Erase","Forge"))
				if("Erase")
					if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
						return
					src.info = src.infoold
					src.infoold = null
					src.overlays -= "paper_stamped_cap"
					src.overlays -= "paper_stamped_hop"
					src.overlays -= "paper_stamped_hos"
					src.overlays -= "paper_stamped_ce"
					src.overlays -= "paper_stamped_rd"
					src.overlays -= "paper_stamped_cmo"
					src.overlays -= "paper_stamped_denied"
					src.overlays -= "paper_stamped_clown"
					src.overlays -= "paper_stamped"
					stamped = list()
					user << "\blue You sucessfully remove those pesky stamps."
					return
				if("Forge")
					if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
						return
					if(!src.infoold)
						src.infoold = src.info
					var/forgename = ""
					var/stamptype = ""
					var/pathtype = ""
					var/list/stamps = list("Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "DENIED")
					stamptype = input("Select a stamp type.", null) in stamps
					if(stamptype == "Captain")
						src.overlays += "paper_stamped_cap"
						forgename = "captain's rubber stamp"
						pathtype = "/obj/item/weapon/stamp/captain"
					else if(stamptype == "Head of Personnel")
						src.overlays += "paper_stamped_hop"
						forgename = "head of personnel's rubber stamp"
						pathtype = "/obj/item/weapon/stamp/hop"
					else if(stamptype == "Head of Security")
						src.overlays += "paper_stamped_hos"
						forgename = "head of security's rubber stamp"
						pathtype = "/obj/item/weapon/stamp/hos"
					else if(stamptype == "Chief Engineer")
						src.overlays += "paper_stamped_ce"
						forgename = "chief engineers's rubber stamp"
						pathtype = "/obj/item/weapon/stamp/ce"
					else if(stamptype == "Research Director")
						src.overlays += "paper_stamped_rd"
						forgename = "research director's rubber stamp"
						pathtype = "/obj/item/weapon/stamp/rd"
					else if(stamptype == "Chief Medical Officer")
						src.overlays += "paper_stamped_cmo"
						forgename = "chief medical officer's rubber stamp"
						pathtype = "/obj/item/weapon/stamp/cmo"
					else if(stamptype == "DENIED")
						src.overlays += "paper_stamped_denied"
						forgename = "\improper DENIED rubber stamp"
						pathtype = "/obj/item/weapon/stamp/denied"
					src.info += text("<BR><i>This paper has been stamped with the [].</i><BR>", forgename)
					if(!stamped)
						stamped = new
					stamped += pathtype

					user << "\blue You forge a stamp on the paper."
					return

	/*
	else
		if (istype(P, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = P
			if ((W.welding && W.weldfuel > 0))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] burns [] with the welding tool!", user, src), 1, "\red You hear a small burning noise", 2)
					//Foreach goto(323)
				spawn( 0 )
					src.burn(1800000.0)
					return
		else
			if (istype(P, /obj/item/device/igniter))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] burns [] with the igniter!", user, src), 1, "\red You hear a small burning noise", 2)
					//Foreach goto(406)
				spawn( 0 )
					src.burn(1800000.0)
					return
			else
				if (istype(P, /obj/item/weapon/wirecutters))
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red [] starts cutting []!", user, src), 1)
						//Foreach goto(489)
					sleep(50)
					if (((src.loc == src || get_dist(src, user) <= 1) && (!( user.stat ) && !( user.restrained() ))))
						for(var/mob/O in viewers(user, null))
							O.show_message(text("\red [] cuts [] to pieces!", user, src), 1)
							//Foreach goto(580)
						//SN src = null
						del(src)
						return
	*/ //TODO: FIX
	src.add_fingerprint(user)
	return





//PAPER BIN

/obj/item/weapon/paper_bin/proc/update()
	src.icon_state = text("paper_bin[]", ((src.amount || locate(/obj/item/weapon/paper, src)) ? "1" : null))
	return


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

/obj/item/weapon/paper_bin/attack_hand(mob/user as mob, unused, flag)
	if (flag)
		return ..()
	src.add_fingerprint(user)
	if (locate(/obj/item/weapon/paper, src))
		for(var/obj/item/weapon/paper/P in src)
			if ((usr.hand && !( usr.l_hand )))
				usr.l_hand = P
				P.loc = usr
				P.layer = 20
				P = null
				usr.update_clothing()
				break
			else if (!usr.r_hand)
				usr.r_hand = P
				P.loc = usr
				P.layer = 20
				P = null
				usr.update_clothing()
				break
	else
		if (src.amount >= 1)
			src.amount--
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper
			P.loc = usr.loc
			if(ishuman(usr))
				if(!usr.get_active_hand())
					usr.put_in_hand(P)
					usr << "You take a paper out of the bin."
			else
				P.loc = get_turf_loc(src)
				usr << "You take a paper out of the bin."

	src.update()
	return

/obj/item/weapon/paper_bin/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	var/n = src.amount
	for(var/obj/item/weapon/paper/P in src)
		n++
	if (n <= 0)
		n = 0
		usr << "There are no papers in the bin."
	else
		if (n == 1)
			usr << "There is one paper in the bin."
		else
			usr << text("There are [] papers in the bin.", n)
	return

/*
/obj/item/weapon/paper_bin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/paper))
		user.drop_item()
		W.loc = src
	else
		if (istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/T = W
			if ((T.welding && T.weldfuel > 0))
				viewers(user, null) << text("[] burns the paper with the welding tool!", user)
				spawn( 0 )
					src.burn(1800000.0)
					return
		else
			if (istype(W, /obj/item/device/igniter))
				viewers(user, null) << text("[] burns the paper with the igniter!", user)
				spawn( 0 )
					src.burn(1800000.0)
					return
	src.update()
	return
*/ //TODO: FIX





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
				//SN src = null
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
	if (istype(target:wear_suit, /obj/item/clothing/suit/straight_jacket) || target:stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (target:loc)
			src.amount -= 2

			if (target:client)
				target:client:perspective = EYE_PERSPECTIVE
				target:client:eye = present

			target:loc = present
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wrapped with [src.name]  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to wrap [target.name] ([target.ckey])</font>")
			log_admin("ATTACK: [user] ([user.ckey]) wrapped up [target] ([target.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) wrapped up [target] ([target.ckey]) with [src].")
			log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to wrap [target.name] ([target.ckey])</font>")

		else
			user << "/blue You need more paper."
	else
		user << "Theyre moving around too much. a Straitjacket would help."





// GIFTS

/obj/item/weapon/gift/attack_self(mob/user as mob)
	if(!src.gift)
		user << "\blue The gift was empty!"
		del(src)
	src.gift.loc = user
	if (user.hand)
		user.l_hand = src.gift
	else
		user.r_hand = src.gift
	src.gift.layer = 20
	src.gift.add_fingerprint(user)
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
		user << "/blue I need wirecutters for that."
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
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("l_gun")
			var/obj/item/weapon/gun/energy/laser/W = new /obj/item/weapon/gun/energy/laser( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("t_gun")
			var/obj/item/weapon/gun/energy/taser/W = new /obj/item/weapon/gun/energy/taser( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("sword")
			var/obj/item/weapon/melee/energy/sword/W = new /obj/item/weapon/melee/energy/sword( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("axe")
			var/obj/item/weapon/melee/energy/axe/W = new /obj/item/weapon/melee/energy/axe( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		else
	return







// BEDSHEET BIN

/obj/structure/bedsheetbin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/bedsheet))
		//W = null
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






// CLIPBOARD

/obj/item/weapon/clipboard/attack_self(mob/user as mob)
	var/dat = "<B>Clipboard</B><BR>"
	if (src.pen)
		dat += text("<A href='?src=\ref[];pen=1'>Remove Pen</A><BR><HR>", src)
	for(var/obj/item/weapon/paper/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];write=\ref[]'>Write</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P, src, P)
	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	return

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return
	if (usr.contents.Find(src))
		usr.machine = src
		if (href_list["pen"])
			if (src.pen)
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = src.pen
					src.pen.loc = usr
					src.pen.layer = 20
					src.pen = null
					usr.update_clothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = src.pen
						src.pen.loc = usr
						src.pen.layer = 20
						src.pen = null
						usr.update_clothing()
				if (src.pen)
					src.pen.add_fingerprint(usr)
				src.add_fingerprint(usr)
		if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if ((P && P.loc == src))
				if ((usr.hand && !( usr.l_hand )))
					usr.l_hand = P
					P.loc = usr
					P.layer = 20
					usr.update_clothing()
				else
					if (!( usr.r_hand ))
						usr.r_hand = P
						P.loc = usr
						P.layer = 20
						usr.update_clothing()
				P.add_fingerprint(usr)
				src.add_fingerprint(usr)
		if (href_list["write"])
			var/obj/item/P = locate(href_list["write"])
			if ((P && P.loc == src))
				if (istype(usr.r_hand, /obj/item/weapon/pen))
					P.attackby(usr.r_hand, usr)
				else
					if (istype(usr.l_hand, /obj/item/weapon/pen))
						P.attackby(usr.l_hand, usr)
					else
						if (istype(src.pen, /obj/item/weapon/pen))
							P.attackby(src.pen, usr)
			src.add_fingerprint(usr)
		if (href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if ((P && P.loc == src))
				if (!( istype(usr, /mob/living/carbon/human) ))
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, stars(P.info)), text("window=[]", P.name))
					onclose(usr, "[P.name]")
				else
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.info), text("window=[]", P.name))
					onclose(usr, "[P.name]")
		if (ismob(src.loc))
			var/mob/M = src.loc
			if (M.machine == src)
				spawn( 0 )
					src.attack_self(M)
					return
	return

/obj/item/weapon/clipboard/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/clipboard/attack_hand(mob/user as mob)

	if ((locate(/obj/item/weapon/paper, src) && (!( user.equipped() ) && (user.l_hand == src || user.r_hand == src))))
		var/obj/item/weapon/paper/P
		for(P in src)
			break
		if (P)
			if (user.hand)
				user.l_hand = P
			else
				user.r_hand = P
			P.loc = user
			P.layer = 20
			P.add_fingerprint(user)
			user.update_clothing()
		src.add_fingerprint(user)
	else
		return ..()
	return

/obj/item/weapon/clipboard/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	if (istype(P, /obj/item/weapon/paper))
		if (src.contents.len < 15)
			user.drop_item()
			P.loc = src
		else
			user << "\blue Not enough space!"
	else
		if (istype(P, /obj/item/weapon/pen))
			if (!src.pen)
				user.drop_item()
				P.loc = src
				src.pen = P
		else
			return
	src.update()
	return

/obj/item/weapon/clipboard/proc/update()
	src.icon_state = text("[src.name][][]", (locate(/obj/item/weapon/paper, src) ? "1" : "0"), (locate(/obj/item/weapon/pen, src) ? "1" : "0"))
	return


/obj/item/weapon/clipboard/MouseDrop(obj/over_object as obj) //Quick clipboard fix. -Agouri
	if (ishuman(usr) || ismonkey(usr)) //Can monkeys even place items in the pocket slots? Leaving this in just in case~
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) /*&& M.pocket == src*/))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return //

/obj/item/weapon/clipboard/New()

	..()
	for(var/i = 1, i <= 3, i++)
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)
		P.loc = src
	src.pen = new /obj/item/weapon/pen(src)
	src.update()
	return

// PHOTOGRAPH

/obj/item/weapon/paper/photograph/New()

	..()
	src.pixel_y = 0
	src.pixel_x = 0
	return

/obj/item/weapon/paper/photograph/attack_self(mob/user as mob)

	var/n_name = input(user, "What would you like to label the photo?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((src.loc == user && user.stat == 0))
		src.name = text("photo[]", (n_name ? text("- '[]'", n_name) : null))
	src.add_fingerprint(user)
	return
