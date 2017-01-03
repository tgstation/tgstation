/obj/item/weapon/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/obj/item/weapon/pen/haspen		//The stored pen.
	var/obj/item/weapon/paper/toppaper	//The topmost piece of paper.
	slot_flags = SLOT_BELT
	resistance_flags = FLAMMABLE

/obj/item/weapon/clipboard/New()
	update_icon()
	..()


/obj/item/weapon/clipboard/update_icon()
	cut_overlays()
	if(toppaper)
		add_overlay(toppaper.icon_state)
		add_overlay(toppaper.overlays)
	if(haspen)
		add_overlay("clipboard_pen")
	add_overlay("clipboard_over")


/obj/item/weapon/clipboard/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/paper))
		if(!user.unEquip(W))
			return
		W.loc = src
		toppaper = W
		user << "<span class='notice'>You clip the paper onto \the [src].</span>"
		update_icon()
	else if(toppaper)
		toppaper.attackby(user.get_active_held_item(), user)
		update_icon()


/obj/item/weapon/clipboard/attack_self(mob/user)
	var/dat = "<title>Clipboard</title>"
	if(haspen)
		dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. You can't organise contents directly in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/weapon/paper/P = toppaper
		dat += "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR><HR>"

		for(P in src)
			if(P == toppaper)
				continue
			dat += "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A> <A href='?src=\ref[src];top=\ref[P]'>Move to top</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	add_fingerprint(usr)


/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained())
		return

	if(usr.contents.Find(src))

		if(href_list["pen"])
			if(haspen)
				haspen.loc = usr.loc
				usr.put_in_hands(haspen)
				haspen = null

		if(href_list["addpen"])
			if(!haspen)
				var/obj/item/held = usr.get_active_held_item()
				if(istype(held, /obj/item/weapon/pen))
					var/obj/item/weapon/pen/W = held
					if(!usr.unEquip(W))
						return
					W.loc = src
					haspen = W
					usr << "<span class='notice'>You slot [W] into [src].</span>"

		if(href_list["write"])
			var/obj/item/P = locate(href_list["write"])
			if(istype(P) && P.loc == src)
				if(usr.get_active_held_item())
					P.attackby(usr.get_active_held_item(), usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(istype(P) && P.loc == src)
				P.loc = usr.loc
				usr.put_in_hands(P)
				if(P == toppaper)
					toppaper = null
					var/obj/item/weapon/paper/newtop = locate(/obj/item/weapon/paper) in src
					if(newtop && (newtop != P))
						toppaper = newtop
					else
						toppaper = null

		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if(istype(P) && P.loc == src)
				usr.examinate(P)

		if(href_list["top"])
			var/obj/item/P = locate(href_list["top"])
			if(istype(P) && P.loc == src)
				toppaper = P
				usr << "<span class='notice'>You move [P.name] to the top.</span>"

		//Update everything
		attack_self(usr)
		update_icon()