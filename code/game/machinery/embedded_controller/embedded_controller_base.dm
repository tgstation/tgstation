/obj/machinery/embedded_controller
	var/datum/computer/file/embedded_program/program

	name = "Embedded Controller"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_build0"
	anchored = 1

	var/on = 1

	var/build=2        // Build state
	var/boardtype=null // /obj/item/weapon/circuitboard/ecb
	var/obj/item/weapon/circuitboard/_circuitboard
	machine_flags = MULTITOOL_MENU
/obj/machinery/embedded_controller/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir

		//src.tdir = dir		// to fix Vars bug
		//dir = SOUTH

		pixel_x = (dir & 3)? 0 : (dir == 4 ? 24 : -24)
		pixel_y = (dir & 3)? (dir ==1 ? 24 : -24) : 0

		build=0
		stat |= MAINT
		src.update_icon()

/obj/machinery/embedded_controller/attackby(var/obj/item/W as obj, var/mob/user as mob)
	. = ..()
	if(.)
		return .
	if(type==/obj/machinery/embedded_controller)
		switch(build)
			if(0) // Empty hull
				if(istype(W, /obj/item/weapon/screwdriver))
					to_chat(usr, "You begin removing screws from \the [src] backplate...")
					if(do_after(user, src, 50))
						to_chat(usr, "<span class='notice'>You unscrew \the [src] from the wall.</span>")
						playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
						new /obj/item/mounted/frame/airlock_controller(get_turf(src))
						del(src)
					return 1
				if(istype(W, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/C=W
					if(C.board_type!="embedded controller")
						to_chat(user, "<span class='warning'>You cannot install this type of board into an embedded controller.</span>")
						return
					to_chat(usr, "You begin to insert \the [C] into \the [src].")
					if(do_after(user, src, 10))
						to_chat(usr, "<span class='notice'>You secure \the [C]!</span>")
						user.drop_item(C, src)
						_circuitboard=C
						playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
						build++
						update_icon()
					return 1
			if(1) // Circuitboard installed
				if(istype(W, /obj/item/weapon/crowbar))
					to_chat(usr, "You begin to pry out \the [W] into \the [src].")
					if(do_after(user, src, 10))
						playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
						build--
						update_icon()
						var/obj/item/weapon/circuitboard/C
						if(_circuitboard)
							_circuitboard.loc=get_turf(src)
							C=_circuitboard
							_circuitboard=null
						else
							C=new boardtype(get_turf(src))
						user.visible_message(\
							"<span class='warning'>[user.name] has removed \the [C]!</span>",\
							"You remove \the [C].")
					return 1
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C=W
					to_chat(user, "You start adding cables to \the [src]...")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, src, 20) && C.amount >= 10)
						C.use(5)
						build++
						update_icon()
						user.visible_message(\
							"<span class='warning'>[user.name] has added cables to \the [src]!</span>",\
							"You add cables to \the [src].")
			if(2) // Circuitboard installed, wired.
				if(istype(W, /obj/item/weapon/wirecutters))
					to_chat(usr, "You begin to remove the wiring from \the [src].")
					if(do_after(user, src, 50))
						new /obj/item/stack/cable_coil(loc,5)
						user.visible_message(\
							"<span class='warning'>[user.name] cut the cables.</span>",\
							"You cut the cables.")
						build--
						update_icon()
					return 1
				if(istype(W, /obj/item/weapon/screwdriver))
					to_chat(user, "You begin to complete \the [src]...")
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
					if(do_after(user, src, 20))
						if(!_circuitboard)
							_circuitboard=new boardtype(src)
						var/obj/machinery/embedded_controller/EC=new _circuitboard.build_path(get_turf(src))
						EC.dir=dir
						EC.pixel_x=pixel_x
						EC.pixel_y=pixel_y
						user.visible_message(\
							"<span class='warning'>[user.name] has finished \the [src]!</span>",\
							"You finish \the [src].")
						del(src)
					return 1
	if(build<2)
		return ..()

/obj/machinery/embedded_controller/proc/post_signal(datum/signal/signal, comm_line)
	return 0

/obj/machinery/embedded_controller/receive_signal(datum/signal/signal, receive_method, receive_param)
	if(!signal || signal.encryption) return

	if(program)
		program.receive_signal(signal, receive_method, receive_param)
			//spawn(5) program.process() //no, program.process sends some signals and machines respond and we here again and we lag -rastaf0

/obj/machinery/embedded_controller/process()
	if(program)
		program.process()

	update_icon()
	src.updateDialog()


/obj/machinery/embedded_controller/attack_ai(mob/user as mob)
	if(build<2) return 1
	src.ui_interact(user)

/obj/machinery/embedded_controller/attack_paw(mob/user as mob)
	attack_hand(user)
	return

/obj/machinery/embedded_controller/attack_hand(mob/user as mob)
	if(!user.dexterity_check())
		to_chat(user, "You do not have the dexterity to use this.")
		return
	if(build<2) return 1
	src.ui_interact(user)

/obj/machinery/embedded_controller/ui_interact()
	return

/obj/machinery/embedded_controller/radio
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	power_channel = ENVIRON
	density = 0

	// Setup parameters only
	var/id_tag
	var/tag_exterior_door
	var/tag_interior_door
	var/tag_airpump
	var/tag_chamber_sensor
	var/tag_exterior_sensor
	var/tag_interior_sensor
	var/tag_secure = 0

	var/frequency = 1449 //seems to be the frequency used for all the controllers on /vg/ so why not make it default
	var/datum/radio_frequency/radio_connection
	unacidable = 1

/obj/machinery/embedded_controller/radio/initialize()
	set_frequency(frequency)
	var/datum/computer/file/embedded_program/new_prog = new

	new_prog.id_tag = id_tag
	new_prog.tag_exterior_door = tag_exterior_door
	new_prog.tag_interior_door = tag_interior_door
	new_prog.tag_airpump = tag_airpump
	new_prog.tag_chamber_sensor = tag_chamber_sensor
	new_prog.tag_exterior_sensor = tag_exterior_sensor
	new_prog.tag_interior_sensor = tag_interior_sensor
	new_prog.memory["secure"] = tag_secure

	new_prog.master = src
	program = new_prog

	spawn(10)
		program.signalDoor(tag_exterior_door, "update")		//signals connected doors to update their status
		program.signalDoor(tag_interior_door, "update")

/obj/machinery/embedded_controller/radio/update_icon()
	if(on && program)
		if(program.memory["processing"])
			icon_state = "airlock_control_process"
		else
			icon_state = "airlock_control_standby"
	else
		icon_state = "airlock_control_off"

/obj/machinery/embedded_controller/radio/post_signal(datum/signal/signal)
	signal.transmission_method = TRANSMISSION_RADIO
	if(radio_connection)
		return radio_connection.post_signal(src, signal)
	else
		del(signal)

/obj/machinery/embedded_controller/radio/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/embedded_controller/radio/handle_multitool_topic(var/href, var/list/href_list, var/mob/user)//need to add an override here because this shit is stupidly hardcoded and I don't want to have to revise this code, atleast not right now
	var/obj/item/device/multitool/P = get_multitool(usr)
	if(P && istype(P))
		var/update_mt_menu=0
		var/re_init=0
		if("set_tag" in href_list)
			if(!(href_list["set_tag"] in vars))
				to_chat(usr, "<span class='warning'>Something went wrong: Unable to find [href_list["set_tag"]] in vars!</span>")
				return 1
			var/current_tag = src.vars[href_list["set_tag"]]
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				vars[href_list["set_tag"]] = newid
				re_init=1

		if("unlink" in href_list)
			var/idx = text2num(href_list["unlink"])
			if (!idx)
				return 1

			var/obj/O = getLink(idx)
			if(!O)
				return 1
			if(!canLink(O))
				to_chat(usr, "<span class='warning'>You can't link with that device.</span>")
				return 1

			if(unlinkFrom(usr, O))
				to_chat(usr, "<span class='confirm'>A green light flashes on \the [P], confirming the link was removed.</span>")
			else
				to_chat(usr, "<span class='attack'>A red light flashes on \the [P].  It appears something went wrong when unlinking the two devices.</span>")
			update_mt_menu=1

		if("link" in href_list)
			var/obj/O = P.buffer
			if(!O)
				return 1
			if(!canLink(O,href_list))
				to_chat(usr, "<span class='warning'>You can't link with that device.</span>")
				return 1
			if (isLinkedWith(O))
				to_chat(usr, "<span class='attack'>A red light flashes on \the [P]. The two devices are already linked.</span>")
				return 1

			if(linkWith(usr, O, href_list))
				to_chat(usr, "<span class='confirm'>A green light flashes on \the [P], confirming the link has been created.</span>")
				re_init = 1//this is the only thing different, crappy, I know
			else
				to_chat(usr, "<span class='attack'>A red light flashes on \the [P].  It appears something went wrong when linking the two devices.</span>")
			update_mt_menu=1

		if("buffer" in href_list)
			if(istype(src, /obj/machinery/telecomms))
				if(!hasvar(src, "id"))
					to_chat(usr, "<span class='danger'>A red light flashes and nothing changes.</span>")
					return
			else if(!hasvar(src, "id_tag"))
				to_chat(usr, "<span class='danger'>A red light flashes and nothing changes.</span>")
				return
			P.buffer = src
			to_chat(usr, "<span class='confirm'>A green light flashes, and the device appears in the multitool buffer.</span>")
			update_mt_menu=1

		if("flush" in href_list)
			to_chat(usr, "<span class='confirm'>A green light flashes, and the device disappears from the multitool buffer.</span>")
			P.buffer = null
			update_mt_menu=1

		var/ret = multitool_topic(usr,href_list,P.buffer)
		if(ret == MT_ERROR)
			return 1
		if(ret & MT_UPDATE)
			update_mt_menu=1
		if(ret & MT_REINIT)
			re_init=1

		if(re_init)
			initialize()
		if(update_mt_menu)
			//usr.set_machine(src)
			update_multitool_menu(usr)
			return 1
