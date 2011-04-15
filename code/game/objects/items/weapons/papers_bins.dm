/*
CONTAINS:
PAPER
PAPER BIN
WRAPPING PAPER
GIFTS
BEDSHEET BIN
PHOTOGRAPHS
CLIPBOARDS

*/


// PAPER

/obj/item/weapon/paper/New()

	..()
	src.pixel_y = rand(-8, 8)
	src.pixel_x = rand(-9, 9)
	return


/obj/item/weapon/paper/examine()
	set src in view()

	..()
	if (!( istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon) ))
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	return


/obj/item/weapon/paper/Map/examine()
	set src in view()

	..()

	usr << browse_rsc(map_graphic)
	if (!( istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon) ))
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, stars(src.info)), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	else
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
		onclose(usr, "[src.name]")
	return

/obj/item/weapon/pen/proc/formatText(var/s)
	if (text_size < 2 || text_size > 7)
		text_size = 3
	if (!(text_color))
		text_color = "#000000"

	var/textToAddHeader = ""
	var/textToAddFooter = ""

	if (text_color && text_size)
		textToAddHeader = "<font size=[text_size] color=[text_color]>"
		textToAddFooter = "</font>"

	if (text_bold == 1)
		textToAddHeader = "[textToAddHeader]<b>"
		textToAddFooter = "</b>[textToAddFooter]"

	if (text_underline == 1)
		textToAddHeader = "[textToAddHeader]<u>"
		textToAddFooter = "</u>[textToAddFooter]"

	if (text_italic == 1)
		textToAddHeader = "[textToAddHeader]<i>"
		textToAddFooter = "</i>[textToAddFooter]"

	if (text_break == 1)
		textToAddFooter = "[textToAddFooter]<br>"

	var/r = "[textToAddHeader][s][textToAddFooter]"
	return r

/obj/item/weapon/pen/attack_self(mob/user as mob)
	var/dat

	dat = text("How would you like to write?<br>")

	dat = text("[formatText("example")]<br>")

	dat += text("<b>size:</b><br>")
	dat += text("<A href='?src=\ref[src];size=2'><font size=2>2</font></A> ")
	dat += text("<A href='?src=\ref[src];size=3'><font size=3>3</font></A> ")
	dat += text("<A href='?src=\ref[src];size=4'><font size=4>4</font></A> ")
	dat += text("<A href='?src=\ref[src];size=5'><font size=5>5</font></A> ")
	dat += text("<A href='?src=\ref[src];size=6'><font size=6>6</font></A> ")
	dat += text("<A href='?src=\ref[src];size=7'><font size=7>7<font></A><br><br>")

	dat += text("<b>Color:</b><br>")
	dat += text("<A href='?src=\ref[src];color=["000000"]'><font color=black>black:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["222222"]'><font color=#222222>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["444444"]'><font color=#444444>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["666666"]'><font color=#666666>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["888888"]'><font color=#888888>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["AAAAAA"]'><font color=#AAAAAA>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["CCCCCC"]'><font color=#CCCCCC>6</font></A><br>")

	dat += text("<A href='?src=\ref[src];color=["FF0000"]'><font color=#FF0000>Red:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["440000"]'><font color=#440000>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["880000"]'><font color=#880000>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["CC0000"]'><font color=#CC0000>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FF2222"]'><font color=#FF2222>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FF6666"]'><font color=#FF6666>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FFBBBB"]'><font color=#FFBBBB>6</font></A><br>")

	dat += text("<A href='?src=\ref[src];color=["FFFF00"]'><font color=#FFFF00>Yellow:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["444400"]'><font color=#444400>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["888800"]'><font color=#888800>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["CCCC00"]'><font color=#CCCC00>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FFFF22"]'><font color=#FFFF22>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FFFF66"]'><font color=#FFFF66>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FFFFBB"]'><font color=#FFFFBB>6</font></A><br>")

	dat += text("<A href='?src=\ref[src];color=["00FF00"]'><font color=#00FF00>Green:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["004400"]'><font color=#004400>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["008800"]'><font color=#008800>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["00CC00"]'><font color=#00CC00>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["22FF22"]'><font color=#22FF22>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["66FF66"]'><font color=#66FF66>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["BBFFBB"]'><font color=#BBFFBB>6</font></A><br>")

	dat += text("<A href='?src=\ref[src];color=["00FFFF"]'><font color=#00FFFF>Cyan:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["004444"]'><font color=#004444>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["008888"]'><font color=#008888>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["00CCCC"]'><font color=#00CCCC>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["22FFFF"]'><font color=#22FFFF>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["66FFFF"]'><font color=#66FFFF>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["BBFFFF"]'><font color=#BBFFFF>6</font></A><br>")

	dat += text("<A href='?src=\ref[src];color=["0000FF"]'><font color=#0000FF>Blue:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["000044"]'><font color=#000044>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["000088"]'><font color=#000088>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["0000CC"]'><font color=#0000CC>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["2222FF"]'><font color=#2222FF>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["6666FF"]'><font color=#6666FF>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["BBBBFF"]'><font color=#BBBBFF>6</font></A><br>")

	dat += text("<A href='?src=\ref[src];color=["000000"]'><font color=#FF00FF>Purple:</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["440044"]'><font color=#440044>1</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["880088"]'><font color=#880088>2</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["CC00CC"]'><font color=#CC00CC>3</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FF22FF"]'><font color=#FF22FF>4</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FF66FF"]'><font color=#FF66FF>5</font></A> ")
	dat += text("<A href='?src=\ref[src];color=["FFBBFF"]'><font color=#FFBBFF>6</font></A><br><br>")

	if (text_bold)
		dat += text("<b>Bold:</b> yes / <A href='?src=\ref[src];bold=[0]'>no</A><br>")
	else
		dat += text("<b>Bold: <A href='?src=\ref[src];bold=[1]'>yes</A> / no<br>")

	if (text_italic)
		dat += text("<b>Italic:</b> yes / <A href='?src=\ref[src];italic=[0]'>no</A><br>")
	else
		dat += text("<b>Italic: <A href='?src=\ref[src];italic=[1]'>yes</A> / no<br>")

	if (text_underline)
		dat += text("<b>Underline:</b> yes / <A href='?src=\ref[src];underline=[0]'>no</A><br>")
	else
		dat += text("<b>Underline:</b> <A href='?src=\ref[src];underline=[1]'>yes</A> / no<br>")

	if (text_break)
		dat += text("<b>Jump into a new line at the end?</b> yes / <A href='?src=\ref[src];break=[0]'>no</A><br>")
	else
		dat += text("<b>Jump into a new line at the end?</b> <A href='?src=\ref[src];break=[1]'>yes</A> / no<br>")
	user << browse("[dat]", "window=pen")

/obj/item/weapon/pen/Topic(href, href_list)
	usr.machine = src
	if(href_list["color"])
		src.text_color = "#"
		src.text_color += href_list["color"]
	if(href_list["size"])
		src.text_size = text2num(href_list["size"])
	if(href_list["bold"])
		src.text_bold = text2num(href_list["bold"])
	if(href_list["underline"])
		src.text_underline = text2num(href_list["underline"])
	if(href_list["italic"])
		src.text_italic = text2num(href_list["italic"])
	if(href_list["break"])
		src.text_break = text2num(href_list["break"])
	attack_self(usr)
	return

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	if ((user.mutations & 16) && prob(50))
		user << text("\red You cut yourself on the paper.")
		user.take_organ_damage(3)
		return
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text
	n_name = copytext(n_name, 1, 32)
	if ((src.loc == user && user.stat == 0))
		src.name = text("paper[]", (n_name ? text("- '[]'", n_name) : null))
	src.add_fingerprint(user)
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
	var/clown = 0
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = 1

	if (istype(P, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/PEN = P

		var/t = strip_html(input(user, "What text do you wish to add?", text("[]", src.name), null),8192)  as message
		t = text("[PEN.formatText(t)]")

		if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
			return
		/*
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		t = dd_replacetext(t, "\n", "<BR>")
		t = dd_replacetext(t, "\[b\]", "<B>")
		t = dd_replacetext(t, "\[/b\]", "</B>")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = dd_replacetext(t, "\[sign\]", text("<font face=vivaldi>[]</font>", user.real_name))
		*/
		t = text("<font face=calligrapher>[]</font>", t)

		src.info += t

	else
		if(istype(P, /obj/item/weapon/stamp))
			if ((!in_range(src, usr) && src.loc != user && !( istype(src.loc, /obj/item/weapon/clipboard) ) && src.loc.loc != user && user.equipped() != P))
				return
			src.info += text("<BR><i>This paper has been stamped with the [].</i><BR>", P.name)
			switch(P.type)
				if(/obj/item/weapon/stamp/captain)
					src.icon_state = "paper_stamped_cap"
				if(/obj/item/weapon/stamp/hop)
					src.icon_state = "paper_stamped_hop"
				if(/obj/item/weapon/stamp/hos)
					src.icon_state = "paper_stamped_hos"
				if(/obj/item/weapon/stamp/ce)
					src.icon_state = "paper_stamped_ce"
				if(/obj/item/weapon/stamp/rd)
					src.icon_state = "paper_stamped_rd"
				if(/obj/item/weapon/stamp/cmo)
					src.icon_state = "paper_stamped_cmo"
				if(/obj/item/weapon/stamp/denied)
					src.icon_state = "paper_stamped_denied"
				if(/obj/item/weapon/stamp/clown)
					if (!clown)
						usr << "\red You are totally unable to use the stamp. HONK!"
						return
					else
						src.icon_state = "paper_stamped_clown"
				else
					src.icon_state = "paper_stamped"
			if(!stamped)
				stamped = new
			stamped += P.type

			user << "\blue You stamp the paper with your rubber stamp."
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
			new /obj/item/weapon/paper( usr.loc )
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
	if (!( locate(/obj/table, src.loc) ))
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

/obj/item/weapon/wrapping_paper/attack(target as mob, mob/user as mob)
	if (!istype(target, /mob/living/carbon/human)) return
	if (istype(target:wear_suit, /obj/item/clothing/suit/straight_jacket) || target:stat)
		if (src.amount > 2)
			var/obj/spresent/present = new /obj/spresent (target:loc)
			src.amount -= 2

			if (target:client)
				target:client:perspective = EYE_PERSPECTIVE
				target:client:eye = present

			target:loc = present
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


/obj/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	user << "\blue You cant move."

/obj/spresent/attackby(obj/item/weapon/W as obj, mob/user as mob)
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
			var/obj/item/weapon/gun/energy/laser_gun/W = new /obj/item/weapon/gun/energy/laser_gun( M )
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
			var/obj/item/weapon/gun/energy/taser_gun/W = new /obj/item/weapon/gun/energy/taser_gun( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("shield")
			var/obj/item/device/shield/W = new /obj/item/device/shield( M )
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
			var/obj/item/weapon/sword/W = new /obj/item/weapon/sword( M )
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
			var/obj/item/weapon/axe/W = new /obj/item/weapon/axe( M )
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

/obj/bedsheetbin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/bedsheet))
		//W = null
		del(W)
		src.amount++
	return

/obj/bedsheetbin/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/bedsheetbin/attack_hand(mob/user as mob)
	if (src.amount >= 1)
		src.amount--
		new /obj/item/weapon/bedsheet( src.loc )
		add_fingerprint(user)

/obj/bedsheetbin/examine()
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
		if (user.contents.Find(src))
			spawn( 0 )
				src.attack_self(user)
				return
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
			user << "\blue Not enough space!!!"
	else
		if (istype(P, /obj/item/weapon/pen))
			if (!src.pen)
				user.drop_item()
				P.loc = src
				src.pen = P
		else
			return
	src.update()
	spawn(0)
		attack_self(user)
		return
	return

/obj/item/weapon/clipboard/proc/update()
	src.icon_state = text("clipboard[][]", (locate(/obj/item/weapon/paper, src) ? "1" : "0"), (locate(/obj/item/weapon/pen, src) ? "1" : "0"))
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
