/obj/machinery/coatrack/attack_hand(mob/user as mob)
	switch(alert("What do you want from the coat rack?",,"Coat","Hat"))
		if("Coat")
			if(coat)
				if(!user.get_active_hand())
					user.put_in_hand(coat)
				else
					coat.loc = get_turf(user)
				coat = null
				if(!hat)
					icon_state = "coatrack0"
				else
					icon_state = "coatrack1"
				return
			else
				user << "\blue There is no coat to take!"
				return
		if("Hat")
			if(hat)
				if(!user.get_active_hand())
					user.put_in_hand(hat)
				else
					hat.loc = get_turf(user)
				hat = null
				if(!coat)
					icon_state = "coatrack0"
				else
					icon_state = "coatrack2"
				return
			else
				user << "\blue There is no hat to take!"
				return
	user << "Something went wrong."
	return

/obj/machinery/coatrack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/obj/item/I = user.equipped()
	if ( istype(I,/obj/item/clothing/head/det_hat) && !hat)
		user.drop_item()
		I.loc = src
		hat = I
		if(!coat)
			icon_state = "coatrack1"
		else
			icon_state = "coatrack3"
		for(var/mob/M in viewers(src, null))
			if(M.client)
				M.show_message(text("\blue [user] puts his hat onto the rack."), 2)
		return
	if ( istype(I,/obj/item/clothing/suit/storage/det_suit) && !coat)
		user.drop_item()
		I.loc = src
		coat = I
		if(!hat)
			icon_state = "coatrack2"
		else
			icon_state = "coatrack3"
		for(var/mob/M in viewers(src, null))
			if(M.client)
				M.show_message(text("\blue [user] puts his coat onto the rack."), 2)
		return
	if ( istype(I,/obj/item/clothing/head/det_hat) && hat)
		user << "There's already a hat on the rack!"
		return ..()
	if ( istype(I,/obj/item/clothing/suit/storage/det_suit) && coat)
		user << "There's already a coat on the rack!"
		return ..()
	user << "The coat rack wants none of what you offer."
	return ..()


/obj/machinery/coatrack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if ( istype(mover,/obj/item/clothing/head/det_hat) && !hat)
		mover.loc = src
		hat = mover
		if(!coat)
			icon_state = "coatrack1"
		else
			icon_state = "coatrack3"
		for(var/mob/M in viewers(src, null))
			if(M.client)
				M.show_message(text("\blue The hat lands perfectly atop its hanger!"), 2)
		return 0
	if ( istype(mover,/obj/item/clothing/suit/storage/det_suit) && !coat)
		mover.loc = src
		coat = mover
		if(!hat)
			icon_state = "coatrack2"
		else
			icon_state = "coatrack3"
		for(var/mob/M in viewers(src, null))
			if(M.client)
				M.show_message(text("\blue The coat lands perfectly atop its hanger!"), 2)
		return 0
	else
		return 0