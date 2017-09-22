/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/obj/item/pen/haspen		//The stored pen.
	var/obj/item/paper/toppaper	//The topmost piece of paper.
	slot_flags = SLOT_BELT
	resistance_flags = FLAMMABLE

/obj/item/clipboard/Initialize()
	update_icon()
	. = ..()

/obj/item/clipboard/Destroy()
	QDEL_NULL(haspen)
	QDEL_NULL(toppaper)	//let movable/Destroy handle the rest
	return ..()

/obj/item/clipboard/update_icon()
	cut_overlays()
	if(toppaper)
		add_overlay(toppaper.icon_state)
		copy_overlays(toppaper)
	if(haspen)
		add_overlay("clipboard_pen")
	add_overlay("clipboard_over")


/obj/item/clipboard/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/paper))
		if(!user.transferItemToLoc(W, src))
			return
		toppaper = W
		to_chat(user, "<span class='notice'>You clip the paper onto \the [src].</span>")
		update_icon()
	else if(toppaper)
		toppaper.attackby(user.get_active_held_item(), user)
		update_icon()


/obj/item/clipboard/attack_self(mob/user)
	var/dat = "<title>Clipboard</title>"
	if(haspen)
		dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. You can't organise contents directly in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/paper/P = toppaper
		dat += "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR><HR>"

		for(P in src)
			if(P == toppaper)
				continue
			dat += "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A> <A href='?src=\ref[src];top=\ref[P]'>Move to top</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	add_fingerprint(usr)


/obj/item/clipboard/Topic(href, href_list)
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
				if(istype(held, /obj/item/pen))
					var/obj/item/pen/W = held
					if(!usr.transferItemToLoc(W, src))
						return
					haspen = W
					to_chat(usr, "<span class='notice'>You slot [W] into [src].</span>")

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
					var/obj/item/paper/newtop = locate(/obj/item/paper) in src
					if(newtop && (newtop != P))
						toppaper = newtop
					else
						toppaper = null

		if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if(istype(P) && P.loc == src)
				usr.examinate(P)

		if(href_list["top"])
			var/obj/item/P = locate(href_list["top"])
			if(istype(P) && P.loc == src)
				toppaper = P
				to_chat(usr, "<span class='notice'>You move [P.name] to the top.</span>")

		//Update everything
		attack_self(usr)
		update_icon()
