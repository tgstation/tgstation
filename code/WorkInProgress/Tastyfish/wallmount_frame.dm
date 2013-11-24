// a frame for generic wall-mounted things, such as fire alarm, status display..
// combination of apc_frame and machine_frame
/obj/machinery/constructable_frame/wallmount_frame
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "wm_0"
	var/wall_offset = 24
	density = 0

/obj/machinery/constructable_frame/wallmount_frame/New()
	spawn(1)
		if (!istype(loc, /turf/simulated/floor))
			usr << "\red [name] cannot be placed on this spot."
			new/obj/item/stack/sheet/metal(get_turf(src), 2)
			del(src)
			return

		var/turf/obj_ofs = get_step(locate(2,2,1), dir)
		pixel_x = (obj_ofs.x - 2) * wall_offset
		pixel_y = (obj_ofs.y - 2) * wall_offset

		var/turf/T = get_step(usr, dir)
		if(!istype(T, /turf/simulated/wall))
			usr << "\red [name] must be placed on a wall."
			new/obj/item/stack/sheet/metal(get_turf(src), 2)
			del(src)
			return

		dir = get_dir(T, loc)

/obj/machinery/constructable_frame/wallmount_frame/attackby(obj/item/P as obj, mob/user as mob)
	if(P.crit_fail)
		user << "\red This part is faulty, you cannot add this to the machine!"
		return
	switch(state)
		if(1)
			if(istype(P, /obj/item/weapon/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "\blue You start to add cables to the frame."
					if(do_after(user, 20))
						P:amount -= 5
						if(!P:amount) del(P)
						user << "\blue You add cables to the frame."
						state = 2
						icon_state = "wm_1"
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user << "\blue You dismantle the frame"
				new /obj/item/stack/sheet/metal(src.loc, 2)
				del(src)
		if(2)
			if(istype(P, /obj/item/weapon/circuitboard))
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "wallmount")
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "\blue You add the circuit board to the frame."
					circuit = P
					user.drop_item()
					P.loc = src
					icon_state = "wm_2"
					state = 3
					components = list()
					req_components = circuit.req_components.Copy()
					for(var/A in circuit.req_components)
						req_components[A] = circuit.req_components[A]
					req_component_names = circuit.req_components.Copy()
					for(var/A in req_components)
						var/cp = text2path(A)
						var/obj/ct = new cp() // have to quickly instantiate it get name
						req_component_names[A] = ct.name
					if(circuit.frame_desc)
						desc = circuit.frame_desc
					else
						update_desc()
					user << desc
				else
					user << "\red This frame does not accept circuit boards of this type!"
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "\blue You remove the cables."
				state = 1
				icon_state = "wm_0"
				var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
				A.amount = 5

		if(3)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				state = 2
				circuit.loc = src.loc
				circuit = null
				if(components.len == 0)
					user << "\blue You remove the circuit board."
				else
					user << "\blue You remove the circuit board and other components."
					for(var/obj/item/weapon/W in components)
						W.loc = src.loc
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "wm_1"

			if(istype(P, /obj/item/weapon/screwdriver))
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
					new_machine.dir = dir
					if(istype(circuit, /obj/item/weapon/circuitboard/status_display))
						new_machine.pixel_x = pixel_x * 1.33
						new_machine.pixel_y = pixel_y * 1.33
					else
						new_machine.pixel_x = pixel_x
						new_machine.pixel_y = pixel_y
					for(var/obj/O in new_machine.component_parts)
						del(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						if(circuit.contain_parts) // things like disposal don't want their parts in them
							O.loc = new_machine
						else
							O.loc = null
						new_machine.component_parts += O
					if(circuit.contain_parts)
						circuit.loc = new_machine
					else
						circuit.loc = null
					new_machine.RefreshParts()
					del(src)

			if(istype(P, /obj/item/weapon))
				for(var/I in req_components)
					if(istype(P, text2path(I)) && (req_components[I] > 0))
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						if(istype(P, /obj/item/weapon/cable_coil))
							var/obj/item/weapon/cable_coil/CP = P
							if(CP.amount > 1)
								var/camt = min(CP.amount, req_components[I]) // amount of cable to take, idealy amount required, but limited by amount provided
								var/obj/item/weapon/cable_coil/CC = new /obj/item/weapon/cable_coil(src)
								CC.amount = camt
								CC.update_icon()
								CP.use(camt)
								components += CC
								req_components[I] -= camt
								update_desc()
								break
						user.drop_item()
						P.loc = src
						components += P
						req_components[I]--
						update_desc()
						break
				user << desc
				if(P.loc != src && !istype(P, /obj/item/weapon/cable_coil))
					user << "\red You cannot add that component to the machine!"

/obj/item/weapon/circuitboard/firealarm
	name = "Circuit board (Fire Alarm)"
	build_path = "/obj/machinery/firealarm"
	board_type = "wallmount"
	origin_tech = "engineering=2"
	frame_desc = "Requires 1 Scanning Module, 1 Capacitor, and 2 pieces of cable."
	contain_parts = 0
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/cable_coil" = 2)

/obj/item/weapon/circuitboard/alarm
	name = "Circuit board (Atmospheric Alarm)"
	build_path = "/obj/machinery/alarm"
	board_type = "wallmount"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Scanning Module, 1 Console Screen, and 2 pieces of cable."
	contain_parts = 0
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/weapon/cable_coil" = 2)

/* oh right, not a machine :(
/obj/item/weapon/circuitboard/intercom
	name = "Circuit board (Intercom)"
	build_path = "/obj/item/device/radio/intercom"
	board_type = "wallmount"
	origin_tech = "engineering=2"
	frame_desc = "Requires 1 Console Screen, and 2 piece of cable."
	contain_parts = 0
	req_components = list(
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/weapon/cable_coil" = 2)
*/

/* too complex to set up the dept for an RC in a way intuitive for the user
/obj/item/weapon/circuitboard/requests_console
	name = "Circuit board (Requests Console)"
	build_path = "/obj/machinery/requests_console"
	board_type = "wallmount"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 radio, 1 Console Screen, and 1 piece of cable."
	contain_parts = 0
	req_components = list(
							"/obj/item/device/radio" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1
							"/obj/item/weapon/cable_coil" = 1)
*/

/obj/item/weapon/circuitboard/status_display
	name = "Circuit board (Status Display)"
	build_path = "/obj/machinery/status_display"
	board_type = "wallmount"
	origin_tech = "engineering=2,programming=2"
	frame_desc = "Requires 2 Console Screens, and 1 piece of cable."
	contain_parts = 0
	req_components = list(
							"/obj/item/weapon/stock_parts/console_screen" = 2,
							"/obj/item/weapon/cable_coil" = 1)

/obj/item/weapon/circuitboard/light_switch
	name = "Circuit board (Light Switch)"
	build_path = "/obj/machinery/light_switch"
	board_type = "wallmount"
	origin_tech = "engineering=2"
	frame_desc = "Requires 2 pieces of cable."
	contain_parts = 0
	req_components = list(
							"/obj/item/weapon/cable_coil" = 2)
