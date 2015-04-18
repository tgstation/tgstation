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
	var/obj/item/weapon/stock_parts/cell/charging = null
	var/chargelevel = -1

/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER)))
		var/newlevel = 	round(charging.percent() * 4 / 100)

		if(chargelevel != newlevel)
			chargelevel = newlevel

			overlays.Cut()
			overlays += "ccharger-o[newlevel]"

	else
		overlays.Cut()

/obj/machinery/cell_charger/examine(mob/user)
	..()
	user << "There's [charging ? "a" : "no"] cell in the charger."
	if(charging)
		user << "Current charge: [round(charging.percent(), 1)]%"

/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user, params)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/stock_parts/cell) && anchored)
		if(charging)
			user << "<span class='warning'>There is already a cell in the charger!</span>"
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				user << "<span class='warning'>The [name] blinks red as you try to insert the cell!</span>"
				return

			user.drop_item()
			W.loc = src
			charging = W
			user.visible_message("<span class='notice'>[user] inserts a cell into the charger.</span>", "<span class='notice'>You insert a cell into the charger.</span>")
			chargelevel = -1
			updateicon()
	else if(istype(W, /obj/item/weapon/wrench))
		if(charging)
			user << "<span class='warning'>Remove the cell first!</span>"
			return

		anchored = !anchored
		user << "<span class='notice'>You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)

/obj/machinery/cell_charger/proc/removecell()
	charging.updateicon()
	charging = null
	chargelevel = -1
	updateicon()

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message("<span class='notice'>[user] removes the cell from the charger.</span>", "<span class='notice'>You remove the cell from the charger.</span>")

	removecell()

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return

	charging.loc = loc
	user << "<span class='notice'>You telekinetically remove [charging] from [src].</span>"

	removecell()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return

	if(charging)
		charging.emp_act(severity)

	..(severity)


/obj/machinery/cell_charger/process()
	if(!charging || !anchored || (stat & (BROKEN|NOPOWER)))
		return

	if(charging.percent() >= 100)
		return

	use_power(200)		//this used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
	charging.give(175)	//inefficiency.

	updateicon()
