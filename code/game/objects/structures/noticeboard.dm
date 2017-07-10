/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	density = 0
	anchored = 1
	max_integrity = 150
	var/notices = 0

/obj/structure/noticeboard/Initialize(mapload)
	..()

	if(!mapload)
		return

	for(var/obj/item/I in loc)
		if(notices > 4) break
		if(istype(I, /obj/item/weapon/paper))
			I.loc = src
			notices++
	icon_state = "nboard0[notices]"

//attaching papers!!
/obj/structure/noticeboard/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo))
		if(!allowed(user))
			to_chat(user, "<span class='info'>You are not authorized to add notices</span>")
			return
		if(notices < 5)
			if(!user.transferItemToLoc(O, src))
				return
			notices++
			icon_state = "nboard0[notices]"
			to_chat(user, "<span class='notice'>You pin the [O] to the noticeboard.</span>")
		else
			to_chat(user, "<span class='notice'>The notice board is full</span>")
	else
		return ..()

/obj/structure/noticeboard/attack_hand(mob/user)
	var/auth = allowed(user)
	var/dat = "<B>[name]</B><BR>"
	for(var/obj/item/P in src)
		if(istype(P, /obj/item/weapon/paper))
			dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> [auth ? "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A>" : ""]<BR>"
		else
			dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> [auth ? "<A href='?src=\ref[src];remove=\ref[P]'>Remove</A>" : ""]<BR>"
	user << browse("<HEAD><TITLE>Notices</TITLE></HEAD>[dat]","window=noticeboard")
	onclose(user, "noticeboard")

/obj/structure/noticeboard/Topic(href, href_list)
	..()
	usr.set_machine(src)
	if(href_list["remove"])
		if((usr.stat || usr.restrained()))	//For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/I = locate(href_list["remove"]) in contents
		if(istype(I) && I.loc == src)
			I.loc = usr.loc
			usr.put_in_hands(I)
			notices--
			icon_state = "nboard0[notices]"

	if(href_list["write"])
		if((usr.stat || usr.restrained())) //For when a player is handcuffed while they have the notice window open
			return
		var/obj/item/P = locate(href_list["write"]) in contents
		if(istype(P) && P.loc == src)
			var/obj/item/I = usr.is_holding_item_of_type(/obj/item/weapon/pen)
			if(I)
				add_fingerprint(usr)
				P.attackby(I, usr)
			else
				to_chat(usr, "<span class='notice'>You'll need something to write with!</span>")

	if(href_list["read"])
		var/obj/item/I = locate(href_list["read"]) in contents
		if(istype(I) && I.loc == src)
			usr.examinate(I)

/obj/structure/noticeboard/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal (loc, 1)
	qdel(src)

// Notice boards for the heads of staff (plus the qm)

/obj/structure/noticeboard/captain
	name = "Captain's Notice Board"
	desc = "Important notices from the Captain."
	req_access = list(GLOB.access_captain)

/obj/structure/noticeboard/hop
	name = "Head of Personnel's Notice Board"
	desc = "Important notices from the Head of Personnel."
	req_access = list(GLOB.access_hop)

/obj/structure/noticeboard/ce
	name = "Chief Engineer's Notice Board"
	desc = "Important notices from the Chief Engineer."
	req_access = list(GLOB.access_ce)

/obj/structure/noticeboard/hos
	name = "Head of Security's Notice Board"
	desc = "Important notices from the Head of Security."
	req_access = list(GLOB.access_hos)

/obj/structure/noticeboard/cmo
	name = "Chief Medical Officer's Notice Board"
	desc = "Important notices from the Chief Medical Officer."
	req_access = list(GLOB.access_cmo)

/obj/structure/noticeboard/rd
	name = "Research Director's Notice Board"
	desc = "Important notices from the Research Director."
	req_access = list(GLOB.access_rd)

/obj/structure/noticeboard/qm
	name = "Quartermaster's Notice Board"
	desc = "Important notices from the Quartermaster."
	req_access = list(GLOB.access_qm)

/obj/structure/noticeboard/staff
	name = "Staff Notice Board"
	desc = "Important notices from the heads of staff."
	req_access = list(GLOB.access_heads)
