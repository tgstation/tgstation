/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	density = 0
	anchored = 1
	obj_integrity = 150
	max_integrity = 150
	var/notices = 0

/obj/structure/noticeboard/initialize()
	for(var/obj/item/I in loc)
		if(notices > 4) break
		if(istype(I, /obj/item/weapon/paper))
			I.loc = src
			notices++
	icon_state = "nboard0[notices]"

//attaching papers!!
/obj/structure/noticeboard/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/paper))
		if(!src.allowed(user))
			user << "<span class='info'>You are not authorized to add notices</span>"
			return
		if(notices < 5)
			if(!user.drop_item())
				return
			O.add_fingerprint(user)
			add_fingerprint(user)
			O.loc = src
			notices++
			icon_state = "nboard0[notices]"	//update sprite
			user << "<span class='notice'>You pin the paper to the noticeboard.</span>"
		else
			user << "<span class='notice'>You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached.</span>"
	else
		return ..()

/obj/structure/noticeboard/attack_hand(mob/user)
	var/auth = src.allowed(user)
	var/dat = "<B>[name]</B><BR>"
	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> [auth ? "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>" : ""]"
	user << browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")

/obj/structure/noticeboard/Topic(href, href_list)
	..()
	usr.set_machine(src)
	if(href_list["remove"])
		if((usr.stat || usr.restrained()))	//For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["remove"])
		if((P && P.loc == src))
			P.loc = get_turf(src)	//dump paper on the floor because you're a clumsy fuck
			P.add_fingerprint(usr)
			add_fingerprint(usr)
			notices--
			icon_state = "nboard0[notices]"

	if(href_list["write"])
		if((usr.stat || usr.restrained())) //For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["write"])

		if((P && P.loc == src)) //ifthe paper's on the board
			var/obj/item/I = usr.is_holding_item_of_type(/obj/item/weapon/pen)
			if(I) //check hand for pen
				add_fingerprint(usr)
				P.attackby(I, usr)
			else
				usr << "<span class='notice'>You'll need something to write with!</span>"

	if(href_list["read"])
		var/obj/item/weapon/paper/P = locate(href_list["read"])
		if((P && P.loc == src))
			if(!ishuman(usr))
				usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY><TT>[stars(P.info)]</TT></BODY></HTML>", "window=[P.name]")
				onclose(usr, "[P.name]")
			else
				usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY><TT>[P.info]</TT></BODY></HTML>", "window=[P.name]")
				onclose(usr, "[P.name]")

/obj/structure/noticeboard/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal (loc, 1)
	qdel(src)

// Notice boards for the heads of staff (plus the qm)

/obj/structure/noticeboard/captain
	name = "Captain's Notice Board"
	desc = "Important notices from the Captain"
	req_access = list(access_captain)

/obj/structure/noticeboard/hop
	name = "Head of Personel's Notice Board"
	desc = "Important notices from the Head of Personel"
	req_access = list(access_hop)

/obj/structure/noticeboard/ce
	name = "Chief Engineer's Notice Board"
	desc = "Important notices from the Chief Engineer"
	req_access = list(access_ce)

/obj/structure/noticeboard/hos
	name = "Head of Security's Notice Board"
	desc = "Important notices from the Head of Security"
	req_access = list(access_hos)

/obj/structure/noticeboard/cmo
	name = "Chief Medical Officer's Notice Board"
	desc = "Important notices from the Chief Medical Officer"
	req_access = list(access_cmo)

/obj/structure/noticeboard/rd
	name = "Research Director's Notice Board"
	desc = "Important notices from the Research Director"
	req_access = list(access_rd)

/obj/structure/noticeboard/qm
	name = "Quartermaster's Notice Board"
	desc = "Important notices from the Quartermaster"
	req_access = list(access_qm)

/obj/structure/noticeboard/staff
	name = "Staff Notice Board"
	desc = "Important notices from the heads of staff"
	req_access = list(access_heads)
