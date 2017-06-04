/obj/machinery/launchpad
	name = "bluespace launchpad"
	desc = "A bluespace pad able to thrust matter through bluespace, teleporting it to or from nearby locations."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle"
	var/icon_teleport = "lpad-beam"
	anchored = TRUE
	use_power = TRUE
	idle_power_usage = 200
	active_power_usage = 2500
	var/stationary = TRUE //to prevent briefcase pad deconstruction and such
	var/display_name = "Launchpad"
	var/teleport_speed = 35
	var/range = 5
	var/teleporting = FALSE //if it's in the process of teleporting
	var/power_efficiency = 1
	var/x_offset = 0
	var/y_offset = 0

/obj/machinery/launchpad/Initialize()
	. = ..()
	var/obj/item/weapon/circuitboard/machine/launchpad/B = new
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/launchpad
	name = "Bluespace Launchpad (Machine Board)"
	build_path = /obj/machinery/launchpad
	origin_tech = "programming=3;engineering=3;plasmatech=2;bluespace=3"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/launchpad/RefreshParts()
	var/E = -1 //to make default parts have the base value
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	range = initial(range)
	range += E

/obj/machinery/launchpad/attackby(obj/item/I, mob/user, params)
	if(stationary)
		if(default_deconstruction_screwdriver(user, "lpad-idle-o", "lpad-idle", I))
			return

		if(panel_open)
			if(istype(I, /obj/item/device/multitool))
				var/obj/item/device/multitool/M = I
				M.buffer = src
				to_chat(user, "<span class='notice'>You save the data in the [I.name]'s buffer.</span>")
				return 1

		if(exchange_parts(user, I))
			return

		if(default_deconstruction_crowbar(I))
			return

	return ..()

/obj/machinery/launchpad/proc/isAvailable()
	if(stat & NOPOWER)
		return FALSE
	if(panel_open)
		return FALSE
	return TRUE

/obj/machinery/launchpad/proc/doteleport(mob/user, sending)
	if(teleporting)
		to_chat(user, "<span class='warning'>ERROR: Launchpad busy.</span>")
		return

	var/target_x = x + x_offset
	var/target_y = y + y_offset
	var/turf/target = locate(target_x, target_y, z)
	var/area/A = get_area(target)

	flick(icon_teleport, src)
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
	teleporting = TRUE


	sleep(teleport_speed)

	if(QDELETED(src) || !isAvailable())
		return

	teleporting = FALSE

	// use a lot of power
	use_power(1000)

	var/turf/source = target
	var/turf/dest = get_turf(src)
	var/list/log_msg = list()
	log_msg += ": [key_name(user)] has teleported "

	if(sending)
		source = dest
		dest = target

	playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, 1)
	for(var/atom/movable/ROI in source)
		if(ROI == src)
			continue
		// if it's anchored, don't teleport
		if(ROI.anchored)
			if(isliving(ROI))
				var/mob/living/L = ROI
				if(L.buckled)
					// TP people on office chairs
					if(L.buckled.anchored)
						continue

					log_msg += "[key_name(L)] (on a chair), "
				else
					continue
			else if(!isobserver(ROI))
				continue
		if(ismob(ROI))
			var/mob/T = ROI
			log_msg += "[key_name(T)], "
		else
			log_msg += "[ROI.name]"
			if (istype(ROI, /obj/structure/closet))
				var/obj/structure/closet/C = ROI
				log_msg += " ("
				for(var/atom/movable/Q as mob|obj in C)
					if(ismob(Q))
						log_msg += "[key_name(Q)], "
					else
						log_msg += "[Q.name], "
				if (dd_hassuffix(log_msg, "("))
					log_msg += "empty)"
				else
					log_msg = dd_limittext(log_msg, length(log_msg) - 2)
					log_msg += ")"
			log_msg += ", "
		do_teleport(ROI, dest)

	if (dd_hassuffix(log_msg, ", "))
		log_msg = dd_limittext(log_msg, length(log_msg) - 2)
	else
		log_msg += "nothing"
	log_msg += " [sending ? "to" : "from"] [target_x], [target_y], [z] ([A ? A.name : "null area"])"
	investigate_log(log_msg.Join(), INVESTIGATE_TELESCI)
	updateDialog()

//Starts in the briefcase. Don't spawn this directly, or it will runtime when closing.
/obj/machinery/launchpad/briefcase
	name = "briefcase launchpad"
	desc = "A portable bluespace pad able to thrust matter through bluespace, teleporting it to or from nearby locations. Controlled via remote."
	icon_state = "blpad-idle"
	icon_teleport = "blpad-beam"
	anchored = FALSE
	use_power = FALSE
	idle_power_usage = 0
	active_power_usage = 0
	teleport_speed = 20
	range = 3
	stationary = FALSE
	var/closed = TRUE
	var/obj/item/briefcase_launchpad/briefcase

/obj/machinery/launchpad/briefcase/Initialize()
	. = ..()
	if(istype(loc, /obj/item/briefcase_launchpad))
		briefcase = loc
	else
		log_game("[src] has been spawned without a briefcase.")
		qdel(src)

/obj/machinery/launchpad/briefcase/Destroy()
	if(!QDELETED(briefcase))
		qdel(briefcase)
	briefcase = null
	return ..()

/obj/machinery/launchpad/briefcase/isAvailable()
	if(closed)
		return FALSE
	return ..()

/obj/machinery/launchpad/briefcase/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!briefcase || !usr.can_hold_items())
			return
		if(usr.incapacitated())
			to_chat(usr, "<span class='warning'>You can't do that right now!</span>")
			return
		usr.visible_message("<span class='notice'>[usr] starts closing [src]...</span>", "<span class='notice'>You start closing [src]...</span>")
		if(do_after(usr, 30, target = usr))
			usr.put_in_hands(briefcase)
			forceMove(briefcase)
			closed = TRUE

/obj/machinery/launchpad/briefcase/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/launchpad_remote))
		var/obj/item/device/launchpad_remote/L = I
		L.pad = src
		to_chat(user, "<span class='notice'>You link [src] to [L].</span>")
	else
		return ..()

//Briefcase item that contains the launchpad.
/obj/item/briefcase_launchpad
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	flags = CONDUCT
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	obj_integrity = 150
	max_integrity = 150
	var/obj/machinery/launchpad/briefcase/pad

/obj/item/briefcase_launchpad/Initialize()
	. = ..()
	pad = new(src)

/obj/item/briefcase_launchpad/Destroy()
	if(!QDELETED(pad))
		qdel(pad)
	pad = null
	return ..()

/obj/item/briefcase_launchpad/attack_self(mob/user)
	if(!isturf(user.loc)) //no setting up in a locker
		return
	add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] starts setting down [src]...", "You start setting up [pad]...")
	if(do_after(user, 30, target = user))
		pad.forceMove(get_turf(src))
		pad.closed = FALSE
		user.transferItemToLoc(src, pad, TRUE)

/obj/item/briefcase_launchpad/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/launchpad_remote))
		var/obj/item/device/launchpad_remote/L = I
		L.pad = src.pad
		to_chat(user, "<span class='notice'>You link [pad] to [L].</span>")
	else
		return ..()

/obj/item/device/launchpad_remote
	name = "\improper Launchpad Control Remote"
	desc = "Used to teleport objects to and from a portable launchpad."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "blpad-remote"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "materials=3;magnets=2;bluespace=4;syndicate=3"
	var/sending = TRUE
	var/obj/machinery/launchpad/briefcase/pad

/obj/item/device/launchpad_remote/ui_interact(mob/user, ui_key = "launchpad_remote", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "launchpad_remote", "Briefcase Launchpad Remote", 550, 400, master_ui, state) //width, height
		ui.set_style("syndicate")
		ui.open()

	ui.set_autoupdate(TRUE)

/obj/item/device/launchpad_remote/ui_data(mob/user)
	var/list/data = list()
	data["has_pad"] = pad ? TRUE : FALSE
	if(pad)
		data["pad_closed"] = pad.closed
	if(!pad || pad.closed)
		return data

	data["pad_name"] = pad.display_name
	data["abs_x"] = abs(pad.x_offset)
	data["abs_y"] = abs(pad.y_offset)
	data["north_south"] = pad.y_offset > 0 ? "N":"S"
	data["east_west"] = pad.x_offset > 0 ? "E":"W"
	return data

/obj/item/device/launchpad_remote/proc/teleport(mob/user, obj/machinery/launchpad/pad)
	if(QDELETED(pad))
		to_chat(user, "<span class='warning'>ERROR: Launchpad not responding. Check launchpad integrity.</span>")
		return
	if(!pad.isAvailable())
		to_chat(user, "<span class='warning'>ERROR: Launchpad not operative. Make sure the launchpad is ready and powered.</span>")
		return
	pad.doteleport(user, sending)

/obj/item/device/launchpad_remote/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("right")
			if(pad.x_offset < pad.range)
				pad.x_offset++
			. = TRUE

		if("left")
			if(pad.x_offset > (pad.range * -1))
				pad.x_offset--
			. = TRUE

		if("up")
			if(pad.y_offset < pad.range)
				pad.y_offset++
			. = TRUE

		if("down")
			if(pad.y_offset > (pad.range * -1))
				pad.y_offset--
			. = TRUE

		if("up-right")
			if(pad.y_offset < pad.range)
				pad.y_offset++
			if(pad.x_offset < pad.range)
				pad.x_offset++
			. = TRUE

		if("up-left")
			if(pad.y_offset < pad.range)
				pad.y_offset++
			if(pad.x_offset > (pad.range * -1))
				pad.x_offset--
			. = TRUE

		if("down-right")
			if(pad.y_offset > (pad.range * -1))
				pad.y_offset--
			if(pad.x_offset < pad.range)
				pad.x_offset++
			. = TRUE

		if("down-left")
			if(pad.y_offset > (pad.range * -1))
				pad.y_offset--
			if(pad.x_offset > (pad.range * -1))
				pad.x_offset--
			. = TRUE

		if("reset")
			pad.y_offset = 0
			pad.x_offset = 0
			. = TRUE

		if("rename")
			. = TRUE
			var/new_name = stripped_input(usr, "How do you want to rename the launchpad?", "Launchpad", pad.display_name, 15) as text|null
			if(!new_name)
				return
			pad.display_name = new_name

		if("remove")
			. = TRUE
			if(usr && alert(usr, "Are you sure?", "Unlink Launchpad", "I'm Sure", "Abort") != "Abort")
				pad = null

		if("launch")
			sending = TRUE
			teleport(usr, pad)
			. = TRUE

		if("pull")
			sending = FALSE
			teleport(usr, pad)
			. = TRUE