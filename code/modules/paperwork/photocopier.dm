/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	var/opened = 0
	var/obj/item/weapon/paper/copy = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!

	attack_ai(mob/user as mob)
		src.add_hiddenprint(user)
		return attack_hand(user)

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		user.set_machine(src)

		var/dat = "Photocopier<BR><BR>"
		if(copy || photocopy)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><BR>"
			if(toner)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\paperwork\photocopier.dm:32: dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
				dat += {"<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>
					Printing: [copies] copies.
					<a href='byond://?src=\ref[src];min=1'>-</a>
					<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"}
				// END AUTOFIX
		else if(toner)
			dat += "Please insert paper to copy.<BR><BR>"
		dat += "Current toner level: [toner]"
		if(!toner)
			dat +="<BR>Please insert a new toner cartridge!"
		user << browse(dat, "window=copier")
		onclose(user, "copier")
		return

	Topic(href, href_list)
		if(href_list["copy"])
			if(copy)
				for(var/i = 0, i < copies, i++)
					if(toner > 0)
						var/obj/item/weapon/paper/c = new /obj/item/weapon/paper (loc)
						if(toner > 10)	//lots of toner, make it dark
							c.info = "<font color = #101010>"
						else			//no toner? shitty copies for you!
							c.info = "<font color = #808080>"
						var/copied = html_decode(copy.info)
						copied = replacetext(copied, "<font face=\"[c.deffont]\" color=", "<font face=\"[c.deffont]\" nocolor=")	//state of the art techniques in action
						copied = replacetext(copied, "<font face=\"[c.crayonfont]\" color=", "<font face=\"[c.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
						c.info += copied
						c.info += "</font>"
						c.name = copy.name // -- Doohl
						c.fields = copy.fields
						c.updateinfolinks()
						toner--
						sleep(15)
					else
						break
				updateUsrDialog()
			else if(photocopy)
				for(var/i = 0, i < copies, i++)
					if(toner > 0)
						var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
						var/icon/I = icon(photocopy.icon, photocopy.icon_state)
						var/icon/img = icon(photocopy.img)
						if(toner > 10)	//plenty of toner, go straight greyscale
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))		//I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
						else			//not much toner left, lighten the photo
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
						p.icon = I
						p.img = img
						p.name = photocopy.name
						p.desc = photocopy.desc
						p.scribble = photocopy.scribble
						toner -= 5	//photos use a lot of ink!
						sleep(15)
					else
						break
				updateUsrDialog()
		else if(href_list["remove"])
			if(copy)
				copy.loc = usr.loc
				usr.put_in_hands(copy)
				usr << "<span class='notice'>You take the paper out of \the [src].</span>"
				copy = null
				updateUsrDialog()
			else if(photocopy)
				photocopy.loc = usr.loc
				usr.put_in_hands(photocopy)
				usr << "<span class='notice'>You take the photo out of \the [src].</span>"
				photocopy = null
				updateUsrDialog()
		else if(href_list["min"])
			if(copies > 1)
				copies--
				updateUsrDialog()
		else if(href_list["add"])
			if(copies < maxcopies)
				copies++
				updateUsrDialog()

	attackby(obj/item/O as obj, mob/user as mob)
		if(istype(O, /obj/item/weapon/paper))
			if(!copy && !photocopy)
				user.drop_item()
				copy = O
				O.loc = src
				user << "<span class='notice'>You insert the paper into \the [src].</span>"
				flick("bigscanner1", src)
				updateUsrDialog()
			else
				user << "<span class='notice'>There is already something in \the [src].</span>"
		else if(istype(O, /obj/item/weapon/photo))
			if(!copy && !photocopy)
				user.drop_item()
				photocopy = O
				O.loc = src
				user << "<span class='notice'>You insert the photo into \the [src].</span>"
				flick("bigscanner1", src)
				updateUsrDialog()
			else
				user << "<span class='notice'>There is already something in \the [src].</span>"
		else if(istype(O, /obj/item/device/toner))
			if(toner == 0)
				user.drop_item()
				del(O)
				toner = 30
				user << "<span class='notice'>You insert the toner cartridge into \the [src].</span>"
				updateUsrDialog()
			else
				user << "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>"
		else if(istype(O, /obj/item/weapon/wrench))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			user << "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>"
		else if(istype(O, /obj/item/weapon/screwdriver))
			if(anchored)
				user << "[src] needs to be unanchored."
				return
			if(!opened)
				src.opened = 1
				//src.icon_state = "photocopier_t"
				user << "You open the maintenance hatch of [src]."
			else
				src.opened = 0
				//src.icon_state = "photocopier"
				user << "You close the maintenance hatch of [src]."
			return 1
		if(opened)
			if(istype(O, /obj/item/weapon/crowbar))
				user << "You begin to remove the circuits from the [src]."
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user, 50))
					var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
					M.state = 2
					M.icon_state = "box_1"
					for(var/obj/I in component_parts)
						if(I.reliability != 100 && crit_fail)
							I.crit_fail = 1
						I.loc = src.loc
					del(src)
					return 1
		return

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
			if(2.0)
				if(prob(50))
					del(src)
				else
					if(toner > 0)
						new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
						toner = 0
			else
				if(prob(50))
					if(toner > 0)
						new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
						toner = 0
		return

	blob_act()
		if(prob(50))
			del(src)
		else
			if(toner > 0)
				new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
				toner = 0
		return

/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
