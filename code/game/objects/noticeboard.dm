/obj/structure/noticeboard

//attaching papers!!
/obj/structure/noticeboard/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/paper))
		if (src.notices < 5)
			O.add_fingerprint(user)
			src.add_fingerprint(user)
			user.drop_item()
			O.loc = src
			src.notices++
			src.icon_state = text("nboard0[]", src.notices) //update sprite
			user << "\blue You pin the paper to the noticeboard."
		else
			user << "\red You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached."

/obj/structure/noticeboard/attack_hand(user as mob)
	var/dat = "<B>Noticeboard</B><BR>"
	for(var/obj/item/weapon/paper/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];write=\ref[]'>Write</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P, src, P)
	user << browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")


/obj/structure/noticeboard/Topic(href, href_list)
	..()
	usr.machine = src
	if (href_list["remove"])
		if ((usr.stat || usr.restrained())) //For when a player is handcuffed while they have the notice window open
			usr << "\red It's a bit hard to remove the notice when you're restrained like this."
			return
		var/obj/item/P = locate(href_list["remove"])
		if ((P && P.loc == src))
			P.loc = get_turf(src) //dump paper on the floor because you're a clumsy fuck
			P.layer = 20
			P.add_fingerprint(usr)
			src.add_fingerprint(usr)
			src.notices--
			src.icon_state = text("nboard0[]", src.notices)

	if(href_list["write"])
		if ((usr.stat || usr.restrained())) //For when a player is handcuffed while they have the notice window open
			usr << "\red It's a bit hard to write when you're restrained like this."
			return
		var/obj/item/P = locate(href_list["write"])

		if((P && P.loc == src)) //if the paper's on the board
			if (istype(usr.r_hand, /obj/item/weapon/pen)) //and you're holding a pen
				src.add_fingerprint(usr)
				P.attackby(usr.r_hand, usr) //then do ittttt
			else
				if (istype(usr.l_hand, /obj/item/weapon/pen)) //check other hand for pen
					src.add_fingerprint(usr)
					P.attackby(usr.l_hand, usr)
				else
					usr << "\red You'll need something to write with!"

	if (href_list["read"])
		var/obj/item/weapon/paper/P = locate(href_list["read"])
		if ((P && P.loc == src))
			if (!( istype(usr, /mob/living/carbon/human) ))
				usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, stars(P.info)), text("window=[]", P.name))
				onclose(usr, "[P.name]")
			else
				usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.info), text("window=[]", P.name))
				onclose(usr, "[P.name]")
	return
