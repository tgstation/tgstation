//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = EQUIP
	var/obj/item/weapon/cell/charging = null
	var/chargelevel = -1
	proc
		updateicon()
			icon_state = "ccharger[charging ? 1 : 0]"

			if(charging && !(stat & (BROKEN|NOPOWER)) )

				var/newlevel = 	round( charging.percent() * 4.0 / 99 )
				//world << "nl: [newlevel]"

				if(chargelevel != newlevel)

					overlays = null
					overlays += image('icons/obj/power.dmi', "ccharger-o[newlevel]")

					chargelevel = newlevel
			else
				overlays = null
	examine()
		set src in oview(5)
		..()
		usr << "There's [charging ? "a" : "no"] cell in the charger."
		if(charging)
			usr << "Current charge: [charging.charge]"

	attackby(obj/item/weapon/W, mob/user)
		if(stat & BROKEN)
			return

		if(istype(W, /obj/item/weapon/cell) && anchored)
			if(charging)
				user << "\red There is already a cell in the charger."
				return
			else
				var/area/a = loc.loc // Gets our locations location, like a dream within a dream
				if(!isarea(a))
					return
				if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
					user << "\red The [name] blinks red as you try to insert the cell!"
					return

				user.drop_item()
				W.loc = src
				charging = W
				user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
				chargelevel = -1
			updateicon()
		else if(istype(W, /obj/item/weapon/wrench))
			if(charging)
				user << "\red Remove the cell first!"
				return

			anchored = !anchored
			user << "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground"
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)

	attack_hand(mob/user)
		if(charging)
			usr.put_in_hands(charging)
			charging.add_fingerprint(user)
			charging.updateicon()

			src.charging = null
			user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
			chargelevel = -1
			updateicon()

	attack_ai(mob/user)
		return

	process()
		//world << "ccpt [charging] [stat]"
		if(!charging || (stat & (BROKEN|NOPOWER)) || !anchored)
			return

		var/added = charging.give(75)
		use_power(added / CELLRATE)

		updateicon()
