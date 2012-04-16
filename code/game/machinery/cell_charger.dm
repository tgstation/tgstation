/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/cell))
		if(charging)
			user << "There is already a cell in the charger."
			return
		else
			user.drop_item()
			W.loc = src
			charging = W
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER)) )

		var/newlevel = 	round( charging.percent() * 4.0 / 99 )
		//world << "nl: [newlevel]"

		if(chargelevel != newlevel)

			overlays = null
			overlays += image('power.dmi', "ccharger-o[newlevel]")

			chargelevel = newlevel
	else
		overlays = null

/obj/machinery/cell_charger/attack_hand(mob/user)

	if(charging)
		usr.put_in_hand(charging)
		charging.add_fingerprint(user)
		charging.updateicon()

		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/process()
	//world << "ccpt [charging] [stat]"
	if(!charging || (stat & (BROKEN|NOPOWER)) )
		return

	var/added = charging.give(500)
	use_power(added / CELLRATE)

	updateicon()