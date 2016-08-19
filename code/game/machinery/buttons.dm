/obj/machinery/button
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	var/skin = "doorctrl"
	power_channel = ENVIRON
	var/obj/item/device/assembly/device
	var/obj/item/weapon/electronics/airlock/board
	var/device_type = null
	var/id = null

	anchored = 1
	use_power = 1
	idle_power_usage = 2


/obj/machinery/button/New(loc, ndir = 0, built = 0)
	..()
	if(built)
		dir = ndir
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		panel_open = 1
		update_icon()

	if(id && !built && !device && device_type)
		device = new device_type(src)

	src.check_access(null)

	if(req_access.len || req_one_access.len)
		board = new(src)
		if(req_access.len)
			board.conf_access = req_access
		else
			board.use_one_access = 1
			board.conf_access = req_one_access

	if(id && istype(device, /obj/item/device/assembly/control))
		var/obj/item/device/assembly/control/A = device
		A.id = id


/obj/machinery/button/update_icon()
	overlays.Cut()
	if(panel_open)
		icon_state = "button-open"
		if(device)
			overlays += "button-device"
		if(board)
			overlays += "button-board"

	else
		if(stat & (NOPOWER|BROKEN))
			icon_state = "[skin]-p"
		else
			icon_state = skin

/obj/machinery/button/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/detective_scanner))
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(panel_open || allowed(user))
			default_deconstruction_screwdriver(user, "button-open", "[skin]",W)
			update_icon()
		else
			user << "<span class='danger'>Maintenance Access Denied</span>"
			flick("[skin]-denied", src)
		return

	if(panel_open)
		if(!device && istype(W, /obj/item/device/assembly))
			if(!user.unEquip(W))
				user << "<span class='warning'>\The [W] is stuck to you!</span>"
				return
			W.loc = src
			device = W
			user << "<span class='notice'>You add [W] to the button.</span>"

		if(!board && istype(W, /obj/item/weapon/electronics/airlock))
			if(!user.unEquip(W))
				user << "<span class='warning'>\The [W] is stuck to you!</span>"
				return
			W.loc = src
			board = W
			if(board.use_one_access)
				req_one_access = board.conf_access
			else
				req_access = board.conf_access
			user << "<span class='notice'>You add [W] to the button.</span>"

		if(!device && !board && istype(W, /obj/item/weapon/wrench))
			user << "<span class='notice'>You start unsecuring the button frame...</span>"
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user, 40, target = src))
				user << "<span class='notice'>You unsecure the button frame.</span>"
				transfer_fingerprints_to(new /obj/item/wallframe/button(get_turf(src)))
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				qdel(src)

		update_icon()
		return

	return src.attack_hand(user)

/obj/machinery/button/emag_act(mob/user)
	req_access = list()
	req_one_access = list()
	playsound(src.loc, "sparks", 100, 1)

/obj/machinery/button/attack_ai(mob/user)
	if(!panel_open)
		return attack_hand(user)

/obj/machinery/button/attack_hand(mob/user)
	src.add_fingerprint(user)
	if(panel_open)
		if(device || board)
			if(device)
				device.loc = get_turf(src)
				device = null
			if(board)
				board.loc = get_turf(src)
				req_access = list()
				req_one_access = list()
				board = null
			update_icon()
			user << "<span class='notice'>You remove electronics from the button frame.</span>"

		else
			if(skin == "doorctrl")
				skin = "launcher"
			else
				skin = "doorctrl"
			user << "<span class='notice'>You change the button frame's front panel.</span>"
		return

	if((stat & (NOPOWER|BROKEN)))
		return

	if(device && device.cooldown)
		return

	if(!allowed(user))
		user << "<span class='danger'>Access Denied</span>"
		flick("[skin]-denied", src)
		return

	use_power(5)
	icon_state = "[skin]1"

	if(device)
		device.pulsed()

	spawn(15)
		update_icon()

/obj/machinery/button/power_change()
	..()
	update_icon()



/obj/machinery/button/door
	name = "door button"
	desc = "A door remote control switch."
	var/normaldoorcontrol = 0
	var/specialfunctions = OPEN // Bitflag, see assembly file

/obj/machinery/button/door/New(loc, ndir = 0, built = 0)
	if(id && !built && !device)
		if(normaldoorcontrol)
			var/obj/item/device/assembly/control/airlock/A = new(src)
			device = A
			A.specialfunctions = specialfunctions
		else
			device = new /obj/item/device/assembly/control(src)
	..()


/obj/machinery/button/massdriver
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon_state = "launcher"
	skin = "launcher"
	device_type = /obj/item/device/assembly/control/massdriver

/obj/machinery/button/ignition
	name = "ignition switch"
	desc = "A remote control switch for a mounted igniter."
	icon_state = "launcher"
	skin = "launcher"
	device_type = /obj/item/device/assembly/control/igniter

/obj/machinery/button/flasher
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon_state = "launcher"
	skin = "launcher"
	device_type = /obj/item/device/assembly/control/flasher

/obj/machinery/button/crematorium
	name = "crematorium igniter"
	desc = "Burn baby burn!"
	icon_state = "launcher"
	skin = "launcher"
	device_type = /obj/item/device/assembly/control/crematorium
	req_access = list(access_crematorium)
	id = 1

/obj/item/wallframe/button
	name = "button frame"
	desc = "Used for building buttons."
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "button_frame"
	result_path = /obj/machinery/button
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)