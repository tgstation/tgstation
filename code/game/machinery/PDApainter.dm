/obj/machinery/pdapainter
		name = "\improper ID and PDA painter"
		desc = "An ID and PDA painting machine. To use, simply insert your ID or PDA and choose the desired preset paint scheme."
		icon = 'icons/obj/pda.dmi'
		icon_state = "pdapainter"
		density = 1
		anchored = 1
		var/obj/item/device/pda/storedpda = null
		var/obj/item/weapon/card/id/storedid = null
		var/list/pdacolorlist = list()
		var/list/idcolorlist = list()
		var/list/idemagcolorlist = list()


/obj/machinery/pdapainter/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda || storedid)
		overlays += "[initial(icon_state)]-closed"

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/New()
	..()
	var/blocked = list(/obj/item/device/pda/ai/pai, /obj/item/device/pda/ai, /obj/item/device/pda/heads,
						/obj/item/device/pda/clear, /obj/item/device/pda/syndicate)

	for(var/P in typesof(/obj/item/device/pda)-blocked)
		var/obj/item/device/pda/D = new P

		//D.name = "PDA Style [colorlist.len+1]" //Gotta set the name, otherwise it all comes up as "PDA"
		D.name = D.icon_state //PDAs don't have unique names, but using the sprite names works.

		src.pdacolorlist += D


	for(var/I in typesof(/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/D = new I
		D.name = D.icon_state
		if(istype(D,/obj/item/weapon/card/id/special) || istype(D,/obj/item/weapon/card/id/syndicate_command) || istype(D,/obj/item/weapon/card/id/syndicate) || istype(D,/obj/item/weapon/card/id/centcom))
			src.idemagcolorlist  += D
		else
			src.idcolorlist += D


/obj/machinery/pdapainter/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		power_change()
		return

	if(istype(I, /obj/item/device/pda))
		if(storedpda)
			user << "<span class='warning'>There is already a PDA inside!</span>"
			return
		else
			var/obj/item/device/pda/P = user.get_active_hand()
			if(istype(P))
				if(!user.drop_item())
					return
				storedpda = P
				P.loc = src
				P.add_fingerprint(user)
				update_icon()
				return

	else if(istype(I, /obj/item/weapon/card/id))
		if(storedid)
			user << "<span class='warning'>There is already an ID inside!</span>"
			return
		else
			var/obj/item/weapon/card/id/D = user.get_active_hand()
			if(istype(D))
				if(!user.drop_item())
					return
				storedid = D
				D.loc = src
				D.add_fingerprint(user)
				update_icon()


/obj/machinery/pdapainter/attack_hand(mob/user)
	..()

	src.add_fingerprint(user)

	if(storedpda)
		var/obj/item/device/pda/P
		P = input(user, "Select your color!", "PDA Painting") as null|anything in pdacolorlist
		if(!P)
			return
		if(!in_range(src, user))
			return
		if(!storedpda)//is the pda still there?
			return
		storedpda.icon_state = P.icon_state
		storedpda.desc = P.desc
		eject(storedpda)

	else if(storedid)
		var/obj/item/weapon/card/id/I
		if(emagged)
			I = input(user, "Select your color!", "ID Painting") as null|anything in (idemagcolorlist + idcolorlist)
		else
			I = input(user, "Select your color!", "ID Painting") as null|anything in idcolorlist
		if(!I)
			return
		if(!in_range(src, user))
			return
		if(!storedid)
			return
		storedid.icon_state = I.icon_state
		storedid.desc = I.desc
		eject(storedid)

	else
		user << "<span class='notice'>The [src] is empty.</span>"



/obj/machinery/pdapainter/proc/eject(var/ejected)
	if(usr.stat || usr.restrained() || !usr.canmove)
		return

	if(!ejected)
		if(!storedpda && !storedid)
			usr << "<span class='notice'>The [src] is empty.</span>"
			return
		if(storedpda)
			storedpda.loc = get_turf(src.loc)
			storedpda = null
		if(storedid)
			storedid.loc = get_turf(src.loc)
			storedid = null

	else if(ejected == storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null

	else if(ejected == storedid)
		storedid.loc = get_turf(src.loc)
		storedid = null

	update_icon()


/obj/machinery/pdapainter/power_change()
	..()
	update_icon()

/obj/machinery/pdapainter/emag_act(mob/user)
	emagged = 1
	user << "<span class='notice'>You short out the [src].</span>"