//these are probably broken

/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = 1
	var/on = 0
	var/obj/item/weapon/cell/high/cell = null
	var/use = 5
	var/unlocked = 0
	var/brightness_on = 8		//This time justified in balance. Encumbering but nice lightening

	machine_flags = SCREWTOGGLE

/obj/machinery/floodlight/New()
	src.cell = new(src)
	..()

/obj/machinery/floodlight/proc/updateicon()
	icon_state = "flood[panel_open ? "o" : ""][panel_open && cell ? "b" : ""]0[on]"

/obj/machinery/floodlight/process()
	if(on)
		cell.charge -= use
		if(cell.charge <= 0)
			on = 0
			updateicon()
			SetLuminosity(0)
			src.visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			return

/obj/machinery/floodlight/attack_hand(mob/user as mob)
	if(panel_open && cell)
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hands(cell)
				cell.loc = user.loc
		else
			cell.loc = loc

		cell.add_fingerprint(user)
		cell.updateicon()

		src.cell = null
		user << "You remove the power cell"
		updateicon()
		return

	if (ishuman(user))
		if(on)
			on = 0
			user << "\blue You turn off the light"
			SetLuminosity(0)
		else
			if(!cell)
				return
			if(cell.charge <= 0)
				return
			on = 1
			user << "\blue You turn on the light"
			SetLuminosity(brightness_on)

		updateicon()


/obj/machinery/floodlight/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/crowbar))
		if(unlocked)
			panel_open = !panel_open
			user << "You [panel_open ? "remove" : "crowbar"] the battery panel [!panel_open ? "in place." : "."]"
	if (istype(W, /obj/item/weapon/cell))
		if(panel_open)
			if(cell)
				user << "There is a power cell already installed."
			else
				user.drop_item()
				W.loc = src
				cell = W
				user << "You insert the power cell."
	updateicon()

/obj/machinery/floodlight/togglePanelOpen(var/obj/toggleitem, mob/user)
	if (!panel_open)
		if(unlocked)
			unlocked = 0
			user << "You screw the battery panel in place."
		else
			unlocked = 1
			user << "You unscrew the battery panel."
