/obj/machinery/button
	name = "button"
	desc = "A remote control switch."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	var/skin = "doorctrl"
	power_channel = ENVIRON
	var/obj/item/device/assembly/device
	var/obj/item/electronics/airlock/board
	var/device_type = null
	var/id = null
	var/initialized_button = 0
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 90, acid = 70)
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/machinery/button/New(loc, ndir = 0, built = 0)
	..()
	if(built)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		panel_open = TRUE
		update_icon()


	if(!built && !device && device_type)
		device = new device_type(src)

	src.check_access(null)

	if(req_access.len || req_one_access.len)
		board = new(src)
		if(req_access.len)
			board.accesses = req_access
		else
			board.one_access = 1
			board.accesses = req_one_access


/obj/machinery/button/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "button-open"
		if(device)
			add_overlay("button-device")
		if(board)
			add_overlay("button-board")

	else
		if(stat & (NOPOWER|BROKEN))
			icon_state = "[skin]-p"
		else
			icon_state = skin

/obj/machinery/button/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver))
		if(panel_open || allowed(user))
			default_deconstruction_screwdriver(user, "button-open", "[skin]",W)
			update_icon()
		else
			to_chat(user, "<span class='danger'>Maintenance Access Denied</span>")
			flick("[skin]-denied", src)
		return

	if(panel_open)
		if(!device && istype(W, /obj/item/device/assembly))
			if(!user.transferItemToLoc(W, src))
				to_chat(user, "<span class='warning'>\The [W] is stuck to you!</span>")
				return
			device = W
			to_chat(user, "<span class='notice'>You add [W] to the button.</span>")

		if(!board && istype(W, /obj/item/electronics/airlock))
			if(!user.transferItemToLoc(W, src))
				to_chat(user, "<span class='warning'>\The [W] is stuck to you!</span>")
				return
			board = W
			if(board.one_access)
				req_one_access = board.accesses
			else
				req_access = board.accesses
			to_chat(user, "<span class='notice'>You add [W] to the button.</span>")

		if(!device && !board && istype(W, /obj/item/wrench))
			to_chat(user, "<span class='notice'>You start unsecuring the button frame...</span>")
			playsound(loc, W.usesound, 50, 1)
			if(do_after(user, 40*W.toolspeed, target = src))
				to_chat(user, "<span class='notice'>You unsecure the button frame.</span>")
				transfer_fingerprints_to(new /obj/item/wallframe/button(get_turf(src)))
				playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
				qdel(src)

		update_icon()
		return

	if(user.a_intent != INTENT_HARM && !(W.flags & NOBLUDGEON))
		return src.attack_hand(user)
	else
		return ..()

/obj/machinery/button/emag_act(mob/user)
	if(emagged)
		return
	req_access = null
	req_one_access = null
	playsound(src, "sparks", 100, 1)
	emagged = TRUE

/obj/machinery/button/attack_ai(mob/user)
	if(!panel_open)
		return attack_hand(user)

/obj/machinery/button/proc/setup_device()
	if(id && istype(device, /obj/item/device/assembly/control))
		var/obj/item/device/assembly/control/A = device
		A.id = id
	initialized_button = 1

/obj/machinery/button/attack_hand(mob/user)
	if(!initialized_button)
		setup_device()
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
			to_chat(user, "<span class='notice'>You remove electronics from the button frame.</span>")

		else
			if(skin == "doorctrl")
				skin = "launcher"
			else
				skin = "doorctrl"
			to_chat(user, "<span class='notice'>You change the button frame's front panel.</span>")
		return

	if((stat & (NOPOWER|BROKEN)))
		return

	if(device && device.next_activate > world.time)
		return

	if(!allowed(user))
		to_chat(user, "<span class='danger'>Access Denied</span>")
		flick("[skin]-denied", src)
		return

	use_power(5)
	icon_state = "[skin]1"

	if(device)
		device.pulsed()

	addtimer(CALLBACK(src, .proc/update_icon), 15)

/obj/machinery/button/power_change()
	..()
	update_icon()


/obj/machinery/button/door
	name = "door button"
	desc = "A door remote control switch."
	var/normaldoorcontrol = 0
	var/specialfunctions = OPEN // Bitflag, see assembly file

/obj/machinery/button/door/setup_device()
	if(!device)
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
	req_access = list()
	id = 1

/obj/item/wallframe/button
	name = "button frame"
	desc = "Used for building buttons."
	icon_state = "button"
	result_path = /obj/machinery/button
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
