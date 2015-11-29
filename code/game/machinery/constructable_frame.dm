//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = 0
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null
	var/list/components_in_use = null
	var/build_state = 1

	// For pods
	var/list/connected_parts = list()
	var/pattern_idx=0
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/constructable_frame/proc/update_desc()
	var/D
	if(req_components)
		D = "Requires "
		var/first = 1
		for(var/I in req_components)
			if(req_components[I] > 0)
				D += "[first?"":", "][num2text(req_components[I])] [req_component_names[I]]"
				first = 0
		if(first) // nothing needs to be added, then
			D += "nothing"
		D += "."
	desc = D

/obj/machinery/constructable_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/P as obj, mob/user as mob)
	if(P.crit_fail)
		to_chat(user, "<span class='warning'>This part is faulty, you cannot add this to the machine!</span>")
		return
	switch(build_state)
		if(1)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.amount >= 5)
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, src, 20))
						if(C && C.amount >= 5) // Check again
							C.use(5)
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							set_build_state(2)
			else if(istype(P, /obj/item/stack/sheet/glass/glass))
				var/obj/item/stack/sheet/glass/glass/G=P
				if(G.amount<1)
					to_chat(user, "<span class='warning'>How...?</span>")
					return
				G.use(1)
				to_chat(user, "<span class='notice'>You add the glass to the frame.</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				new /obj/structure/displaycase_frame(src.loc)
				qdel(src)
				return
			else
				if(istype(P, /obj/item/weapon/wrench))
					playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
					to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
					//new /obj/item/stack/sheet/metal(src.loc, 5)
					var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, src.loc)
					M.amount = 5
					qdel(src)
		if(2)
			if(!..())
				if(istype(P, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/B = P
					if(B.board_type == "machine")
						playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
						circuit = P
						user.drop_item(B, src)
						set_build_state(3)
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						req_component_names = circuit.req_components.Copy()
						/* Are you fucking kidding me
						for(var/A in req_components)
							var/cp = text2path(A)
							var/obj/ct = new cp() // have to quickly instantiate it get name
							req_component_names[A] = ct.name
							del(ct)*/
						for(var/A in req_components)
							var/atom/path = text2path(A)
							req_component_names[A] = initial(path.name)
						if(circuit.frame_desc)
							desc = circuit.frame_desc
						else
							update_desc()
						to_chat(user, desc)
					else
						to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				else
					if(istype(P, /obj/item/weapon/wirecutters))
						playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You remove the cables.</span>")
						set_build_state(1)
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
						A.amount = 5

		if(3)
			if(!..())
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					set_build_state(2)
					circuit.loc = src.loc
					circuit = null
					if(components.len == 0)
						to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
					else
						to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
						for(var/obj/item/weapon/W in components)
							W.loc = src.loc
					desc = initial(desc)
					req_components = null
					components = null
				else
					if(istype(P, /obj/item/weapon/screwdriver))
						var/component_check = 1
						for(var/R in req_components)
							if(req_components[R] > 0)
								component_check = 0
								break
						if(component_check)
							playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
							var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
							for(var/obj/O in new_machine.component_parts)
								returnToPool(O)
							new_machine.component_parts = list()
							for(var/obj/O in src)
								if(circuit.contain_parts) // things like disposal don't want their parts in them
									O.loc = components_in_use
								else
									O.loc = null
								new_machine.component_parts += O
							if(circuit.contain_parts)
								circuit.loc = components_in_use
							else
								circuit.loc = null
							new_machine.RefreshParts()
							components = null
							qdel(src)
					else
						if(istype(P, /obj/item/weapon/storage/bag/gadgets/part_replacer) && P.contents.len && get_req_components_amt())
							var/obj/item/weapon/storage/bag/gadgets/part_replacer/replacer = P
							var/list/added_components = list()
							var/list/part_list = replacer.contents.Copy()

							//Sort the parts. This ensures that higher tier items are applied first.
							part_list = sortTim(part_list, /proc/cmp_rped_sort)

							for(var/path in req_components)
								while(req_components[path] > 0 && (locate(text2path(path)) in part_list))
									var/obj/item/part = (locate(text2path(path)) in part_list)
									if(!part.crit_fail)
										added_components[part] = path
										replacer.remove_from_storage(part, src)
										req_components[path]--
										part_list -= part

							for(var/obj/item/weapon/stock_parts/part in added_components)
								components += part
								to_chat(user, "<span class='notice'>[part.name] applied.</span>")
							replacer.play_rped_sound()

							update_desc()

						else
							if(istype(P, /obj/item/weapon) || istype(P, /obj/item/stack))
								for(var/I in req_components)
									if(istype(P, text2path(I)) && (req_components[I] > 0))
										playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
										if(istype(P, /obj/item/stack))
											var/obj/item/stack/CP = P
											if(CP.amount >= req_components[I])
												var/camt = min(CP.amount, req_components[I]) // amount of the stack to take, idealy amount required, but limited by amount provided
												var/obj/item/stack/CC = getFromPool(text2path(I), src)
												CC.amount = camt
												CC.update_icon()
												CP.use(camt)
												components += CC
												req_components[I] -= camt
												update_desc()
												break
											else
												to_chat(user, "<span class='warning'>You do not have enough [P]!</span>")

										user.drop_item(P, src)
										components += P
										req_components[I]--
										update_desc()
										break
								to_chat(user, desc)

								if(P && P.loc != src && !istype(P, /obj/item/stack/cable_coil))
									to_chat(user, "<span class='warning'>You cannot add that component to the machine!</span>")

/obj/machinery/constructable_frame/machine_frame/proc/set_build_state(var/state)
	build_state = state
	switch(state)
		if(1)
			icon_state = "box_0"
		if(2)
			icon_state = "box_1"
		if(3)
			icon_state = "box_2"

//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/

/obj/item/weapon/circuitboard/blank
	name = "unprinted circuitboard"
	desc = "A blank circuitboard ready for design."
	icon = 'icons/obj/module.dmi'
	icon_state = "blank_mod"
	//var/datum/circuits/local_fuses = null
	var/list/allowed_boards = list("autolathe"=/obj/item/weapon/circuitboard/autolathe,"intercom"=/obj/item/weapon/intercom_electronics,"conveyor"=/obj/item/weapon/circuitboard/conveyor,"air alarm"=/obj/item/weapon/circuitboard/air_alarm,"fire alarm"=/obj/item/weapon/circuitboard/fire_alarm,"airlock"=/obj/item/weapon/circuitboard/airlock,"APC"=/obj/item/weapon/circuitboard/power_control,"vendomat"=/obj/item/weapon/circuitboard/vendomat,"microwave"=/obj/item/weapon/circuitboard/microwave)
	var/soldering = 0 //Busy check

/obj/item/weapon/circuitboard/blank/New()
	..()
	//local_fuses = new(src)

/obj/item/weapon/circuitboard/blank/attackby(obj/item/O as obj, mob/user as mob)
	/*if(ismultitool(O))
		var/boardType = local_fuses.assigned_boards["[local_fuses.localbit]"] //Localbit is an int, but this is an associative list organized by strings
		if(boardType)
			if(ispath(boardType))
				to_chat(user, "<span class='notice'>The multitool pings softly.</span>")
				new boardType(get_turf(src))
				qdel(src)
				return
			else
				to_chat(user, "<span class='warning'>A fatal error with the board type occurred. Report this message.</span>")
		else
			to_chat(user, "<span class='warning'>The multitool flashes red briefly.</span>")
	else */if(!soldering&&issolder(O))
		//local_fuses.Interact(user)
		var/t = input(user, "Which board should be designed?") as null|anything in allowed_boards
		if(!t) return
		var/obj/item/weapon/solder/S = O
		if(!S.remove_fuel(4,user)) return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		soldering = 1
		if(do_after(user, src,40))
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
			var/boardType = allowed_boards[t]
			var/obj/item/I = new boardType(get_turf(user))
			qdel(src)
			user.put_in_hands(I)
		soldering = 0
	else if(iswelder(O))
		var/obj/item/weapon/weldingtool/WT = O
		if(WT.remove_fuel(1,user))
			var/obj/item/stack/sheet/glass/glass/new_item = new /obj/item/stack/sheet/glass/glass(src.loc)
			new_item.add_to_stacks(user)
			returnToPool(src)
			return
	else
		return ..()

/obj/item/weapon/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = "/obj/machinery/r_n_d/destructive_analyzer"
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=3"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/obj/item/weapon/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	build_path = "/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	build_path = "/obj/machinery/r_n_d/fabricator/protolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=3"
	frame_desc = "Requires 2 Matter Bins, 2 Manipulators, and 2 Beakers."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2)

/obj/item/weapon/circuitboard/conveyor
	name = "Circuit board (Conveyor)"
	build_path = "/obj/machinery/conveyor"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires nothing."
	req_components = list()


/obj/item/weapon/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = "/obj/machinery/r_n_d/fabricator/circuit_imprinter"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, and 2 Beakers."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2)

/obj/item/weapon/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman"
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;plasmatech=3;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Micro-Laser, and 1 Capacitor."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/super"
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/weapon/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"

/obj/item/weapon/circuitboard/air_alarm
	name = "Circuit board (Air Alarm)"
	board_type="other"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	//origin_tech = "programming=2"

/obj/item/weapon/circuitboard/fire_alarm
	name = "Circuit board (Fire Alarm)"
	board_type="other"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	//origin_tech = "programming=2"

/obj/item/weapon/circuitboard/airlock
	name = "Circuit board (Airlock)"
	board_type="other"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	//origin_tech = "programming=2"

obj/item/weapon/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = "/obj/machinery/r_n_d/server"
	board_type = "machine"
	origin_tech = "programming=3"
	frame_desc = "Requires 2 Capacitors and 1 Scanning Module."
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = "/obj/machinery/r_n_d/fabricator/mech"
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/podfab
	name = "Circuit board (Spacepod Fabricator)"
	build_path = "/obj/machinery/r_n_d/fabricator/pod"
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 3 Matter Bins, 2 Manipulators, and 2 Micro-Lasers."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2)

/obj/item/weapon/circuitboard/defib_recharger
	name = "Circuit Board (Defib Recharger)"
	build_path = "/obj/machinery/recharger/defibcharger/wallcharger"
	board_type = "machine"
	origin_tech = "programming=3;biotech=4;engineering=2;powerstorage=2"
	frame_desc = "Requires 1 micro-laser, 2 matter bins, 2 manipulator, 1 console screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/smes
	name = "Circuit Board (SMES)"
	build_path = "/obj/machinery/power/battery/smes"
	board_type = "machine"
	origin_tech = "powerstorage=4;engineering=4;programming=4"
	frame_desc = "Requires 4 capacitors, 4 micro-lasers, and 2 console screens."
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 4,
							"/obj/item/weapon/stock_parts/micro_laser" = 4,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/port_smes
	name = "Circuit Board (Portable SMES)"
	build_path = "/obj/machinery/power/battery/portable"
	board_type = "machine"
	origin_tech = "powerstorage=5;engineering=4;programming=4"
	frame_desc = "Requires 4 capacitors, 4 micro-lasers, and 2 console screens."
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 4,
							"/obj/item/weapon/stock_parts/micro_laser" = 4,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/battery_port
	name = "Circuit Board (SMES Port)"
	build_path = "/obj/machinery/power/battery_port"
	board_type = "machine"
	origin_tech = "powerstorage=5;engineering=4;programming=4"
	frame_desc = "Requires 3 capacitors and 1 console screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/treadmill
	name = "Circuit Board (Treadmill Generator)"
	build_path = "/obj/machinery/power/treadmill"
	board_type = "machine"
	origin_tech = "engineering=2;powerstorage=4"
	frame_desc = "Requires 4 capacitors and 1 console screen."
	req_components = list (
							"/obj/item/weapon/stock_parts/capacitor" = 4,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/chem_dispenser
	name = "Circuit Board (Chemistry Dispenser)"
	build_path = "/obj/machinery/chem_dispenser"
	board_type = "machine"
	origin_tech = "programming=3;biotech=5;engineering=4"
	frame_desc = "Requires 2 manipulators, 2 scanning modules, 3 micro-lasers, and 1 console screen."
	req_components = list (
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/chem_dispenser/brewer
	name = "Circuit Board (Brewer)"
	build_path = "/obj/machinery/chem_dispenser/brewer"

/obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser
	name = "Circuit Board (Soda Dispenser)"
	build_path = "/obj/machinery/chem_dispenser/soda_dispenser"

/obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser
	name = "Circuit Board (Booze Dispenser)"
	build_path = "/obj/machinery/chem_dispenser/booze_dispenser"

/obj/item/weapon/circuitboard/chemmaster3000
	name = "Circuit Board (ChemMaster 3000)"
	build_path = "/obj/machinery/chem_master"
	board_type = "machine"
	origin_tech = "engineering=3;biotech=4"
	frame_desc = "Requires 1 manipulator, 2 scanning modules, 2 micro-lasers, and 2 console screens."
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/condimaster
	name = "Circuit Board (CondiMaster)"
	build_path = "/obj/machinery/chem_master/condimaster"
	board_type = "machine"
	origin_tech = "engineering=3;biotech=4"
	frame_desc = "Requires 1 manipulator, 3 scanning modules, 2 micro-lasers, and 2 console screens."
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 3,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/snackbar_machine
	name = "Circuit Board (SnackBar Machine)"
	build_path = "/obj/machinery/chem_master/snackbar_machine"
	board_type = "machine"
	origin_tech = "engineering=3;biotech=4"
	frame_desc = "Requires 2 manipulator, 2 scanning modules, 2 micro-lasers, and 2 console screens."
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/recharge_station
	name = "Circuit Board (Cyborg Recharging Station)"
	build_path = "/obj/machinery/recharge_station"
	board_type = "machine"
	origin_tech = "powerstorage=4;programming=3"
	frame_desc = "Requires 2 capacitors, 1 manipulator, and 1 matter bin."
	req_components = list (
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/matter_bin" = 1)

/obj/item/weapon/circuitboard/heater
	name = "Circuit Board (Heater)"
	build_path = "/obj/machinery/atmospherics/unary/heat_reservoir/heater"
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=5;biotech=4"
	frame_desc = "Requires 3 micro-lasers and 1 console screen."
	req_components = list (
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/freezer
	name = "Circuit Board (Freezer)"
	build_path = "/obj/machinery/atmospherics/unary/cold_sink/freezer"
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=4;biotech=4"
	frame_desc = "Requires 3 micro-lasers and 1 console screen."
	req_components = list (
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/photocopier
	name = "Circuit Board (Photocopier)"
	build_path = "/obj/machinery/photocopier"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 2 manipulators, 2 scanning modules, 1 micro-laser, and 2 console screens."
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 2,)

/obj/item/weapon/circuitboard/cryo
	name = "Circuit Board (Cryo)"
	build_path = "/obj/machinery/atmospherics/unary/cryo_cell"
	board_type = "machine"
	origin_tech = "programming=3;biotech=3;engineering=2"
	frame_desc = "Requires 3 Manipulators, 2 Scanning Modules, and 1 Console Screen."
	req_components = list (
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = "/obj/machinery/cloning/clonepod"
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	frame_desc = "Requires 2 Manipulator, 2 Scanning Module, and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = "/obj/machinery/dna_scannernew"
	board_type = "machine"
	origin_tech = "programming=3;biotech=2"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, 1 Micro-Laser, and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/fullbodyscanner
	name = "Circuit board (Full Body Scanner)"
	build_path = "/obj/machinery/bodyscanner"
	board_type = "machine"
	origin_tech = "biotech=2"
	frame_desc = "Requires 3 Scanning Module."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 3)

/obj/item/weapon/circuitboard/sleeper
	name = "Circuit board (Sleeper)"
	build_path = "/obj/machinery/sleeper"
	board_type = "machine"
	origin_tech = "biotech=2"
	frame_desc = "Requires 1 Scanning Module, 2 Manipulator."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/biogenerator
	name = "Circuit Board (Biogenerator)"
	build_path = "/obj/machinery/biogenerator"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3"
	frame_desc = "Requires 2 Manipulators, 2 Matter Bins, 3 Micro-Lasers, 2 Scanning Modules,2 Console Screens, and 1 Large Beaker.   "
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker/large" = 1)

/obj/item/weapon/circuitboard/seed_extractor
	name = "Circuit Board (Seed Extractor)"
	build_path = "/obj/machinery/seed_extractor"
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 2 Manipulators, 1 Matter Bins, 1 Micro-Lasers, 1 Scanning Modules, and 1 Console Screens.   "
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/microwave
	name = "Circuit Board (Microwave)"
	build_path = "/obj/machinery/microwave"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;magnets=3"
	frame_desc = "Requires 1 Micro-Laser, 1 Scanning Module, and 1 Console Screens.   "
	req_components = list(
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/reagentgrinder
	name = "Circuit Board (All-In-One Grinder)"
	build_path = "/obj/machinery/reagentgrinder"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2"
	frame_desc = "Requires 2 Matter Bins, 1 Micro-Lasers, 1 Scanning Modules, and 1 Large Beaker.   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker/large" = 1)

/obj/item/weapon/circuitboard/smartfridge
	name = "Circuit Board (SmartFridge)"
	build_path = "/obj/machinery/smartfridge"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2"
	frame_desc = "Requires 2 Manipulators, 4 Matter Bins, ,1 Scanning Module, and 2 Console Screens.   "
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 4,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/smartfridge/medbay
	name = "Circuit Board (Medbay SmartFridge)"
	build_path = "/obj/machinery/smartfridge/secure/medbay"

/obj/item/weapon/circuitboard/smartfridge/chemistry
	name = "Circuit Board (Chemical SmartFridge)"
	build_path = "/obj/machinery/smartfridge/chemistry"

/obj/item/weapon/circuitboard/smartfridge/extract
	name = "Circuit Board (Extract SmartFridge)"
	build_path = "/obj/machinery/smartfridge/extract"

/obj/item/weapon/circuitboard/smartfridge/seeds
	name = "Circuit Board (Megaseed Servitor)"
	build_path = "/obj/machinery/smartfridge/seeds"

/obj/item/weapon/circuitboard/smartfridge/drinks
	name = "Circuit Board (Drinks Showcase)"
	build_path = "/obj/machinery/smartfridge/drinks"

/obj/item/weapon/circuitboard/hydroponics
	name = "Circuit Board (Hydroponics Tray)"
	build_path = "/obj/machinery/portable_atmospherics/hydroponics"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 2 Matter Bins, 1 Scanning Module, 2 Beakers, 1 Capacitor, and 1 Console Screen.   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/gibber
	name = "Circuit Board (Gibber)"
	build_path = "/obj/machinery/gibber"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 2 Matter Bins, 2 Capacitors, 2 Scanning Module, 4 Manipulator and 4 High Powered Micro-Lasers   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 4,
							"/obj/item/weapon/stock_parts/micro_laser/high" = 4)

/obj/item/weapon/circuitboard/processor
	name = "Circuit Board (Food Processor)"
	build_path = "/obj/machinery/processor"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 1 Scanning Module and 2 Manipulators   "
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/egg_incubator
	name = "Circuit Board (Egg Incubator)"
	build_path = "/obj/machinery/egg_incubator"
	board_type = "machine"
	origin_tech = "biotech=3"
	frame_desc = "Requires 1 Matter Bin and 2 Capacitors   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/monkey_recycler
	name = "Circuit Board (Monkey Recycler)"
	build_path = "/obj/machinery/monkey_recycler"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 1 Matter Bin, 2 Manipulators and 1 Micro-Laser   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/*
/obj/item/weapon/circuitboard/hydroseeds
	name = "Circuit Board (MegaSeed Servitor)"
	build_path = "/obj/machinery/vending/hydroseeds"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 2 Matter Bins, 1 Capacitors, 2 Scanning Module, and 2 Manipulators   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/hydronutrients
	name = "Circuit Board (Nutrimax)"
	build_path = "/obj/machinery/vending/hydronutrients"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 2 Matter Bins, 1 Capacitors, 2 Scanning Module, and 2 Manipulators   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)
*/

/obj/item/weapon/circuitboard/pipedispenser
	name = "Circuit Board (Pipe Dispenser)"
	build_path = "/obj/machinery/pipedispenser"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 2 Matter Bins, 1 Capacitors, 2 Scanning Module, and 2 Manipulators   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/pipedispenser/disposal
	name = "Circuit Board (Disposal Pipe Dispenser)"
	build_path = "/obj/machinery/pipedispenser/disposal"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3;powerstorage=2"
	frame_desc = "Requires 2 Matter Bins, 1 Capacitors, 2 Scanning Module, and 2 Manipulators   "
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)




//Teleporter
/obj/item/weapon/circuitboard/telehub
	name = "Circuit Board (Teleporter Hub)"
	build_path = "/obj/machinery/teleport/hub"
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;bluespace=3"
	frame_desc = "Requires 2 Phasic Scanning Modules, 3 Super Capacitors, 2 Subspace Ansibles, 2 Hyperwave filters, 1 Subspace Treatment Disc, 2 Ansible Crystals, and 4 Subspace Transmitters."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module/phasic" = 2,
							"/obj/item/weapon/stock_parts/capacitor/super" = 3,
							"/obj/item/weapon/stock_parts/subspace/ansible" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 2,
							"/obj/item/weapon/stock_parts/subspace/treatment" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 4)

/obj/item/weapon/circuitboard/telestation
	name = "Circuit Board (Teleporter Station)"
	build_path = "/obj/machinery/teleport/station"
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;bluespace=3"
	frame_desc = "Requires 2 Phasic Scanning Modules, 2 Super Capacitors, 2 Subspace Ansibles, and 4 Subspace Wavelength Analyzers."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module/phasic" = 2,
							"/obj/item/weapon/stock_parts/capacitor/super" = 2,
							"/obj/item/weapon/stock_parts/subspace/ansible" = 2,
							"/obj/item/weapon/stock_parts/subspace/analyzer" = 4)

// Telecomms circuit boards:

/obj/item/weapon/circuitboard/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	build_path = "/obj/machinery/telecomms/receiver"
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;bluespace=2"
	frame_desc = "Requires 1 Subspace Ansible, 1 Hyperwave Filter, 2 Manipulators, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/weapon/stock_parts/subspace/ansible" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/obj/item/weapon/circuitboard/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	build_path = "/obj/machinery/telecomms/hub"
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filter."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 2)

/obj/item/weapon/circuitboard/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	build_path = "/obj/machinery/telecomms/relay"
	board_type = "machine"
	origin_tech = "programming=3;engineering=4;bluespace=3"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filters."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 2)

/obj/item/weapon/circuitboard/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	build_path = "/obj/machinery/telecomms/bus"
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1)

/obj/item/weapon/circuitboard/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	build_path = "/obj/machinery/telecomms/processor"
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 3 Manipulators, 1 Hyperwave Filter, 2 Treatment Disks, 1 Wavelength Analyzer, 2 Cable Coils and 1 Subspace Amplifier."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 3,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/subspace/treatment" = 2,
							"/obj/item/weapon/stock_parts/subspace/analyzer" = 1,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1)

/obj/item/weapon/circuitboard/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	build_path = "/obj/machinery/telecomms/server"
	board_type = "machine"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1)

/obj/item/weapon/circuitboard/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	build_path = "/obj/machinery/telecomms/broadcaster"
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil, 1 Hyperwave Filter, 1 Ansible Crystal and 2 High-Powered Micro-Lasers. "
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/micro_laser/high" = 2)

/obj/item/weapon/circuitboard/bioprinter
	name = "Circuit Board (Bioprinter)"
	build_path = "/obj/machinery/bioprinter"
	board_type = "machine"
	origin_tech = "programming=3;engineering=2;biotech=3"
	frame_desc = "Requires 2 Manipulators, 2 Matter Bins, 3 Micro-Lasers, 2 Scanning Modules, 1 Console Screen. "
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/reverse_engine
	name = "Circuit Board (Reverse Engine)"
	build_path = "/obj/machinery/r_n_d/reverse_engine"
	board_type = "machine"
	origin_tech = "materials=6;programming=4;engineering=3;bluespace=3;powerstorage=4"
	frame_desc = "Requires 2 Scanning Modules, 2 Capacitors, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/generalfab
	name = "Circuit Board (General Fabricator)"
	build_path = "/obj/machinery/r_n_d/fabricator/mechanic_fab"
	board_type = "machine"
	origin_tech = "materials=3;engineering=2;programming=3"
	frame_desc = "Requires 2 Manipulators, 2 Matter Bins, and 2 Micro-Lasers."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2)

/obj/item/weapon/circuitboard/flatpacker
	name = "Circuit Board (Flatpack Fabricator)"
	build_path = "/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker"
	board_type = "machine"
	origin_tech = "materials=5;engineering=4;powerstorage=3;programming=3"
	frame_desc = "Requires 2 Manipulators, 2 Matter Bins, 2 Micro-Lasers, 2 Scanning Modules, and 1 Beaker."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 1)

/obj/item/weapon/circuitboard/blueprinter
	name = "Circuit Board (Blueprint Printer)"
	build_path = "/obj/machinery/r_n_d/blueprinter"
	board_type = "machine"
	origin_tech = "engineering=3;programming=3"
	frame_desc = "Requires 2 Matter Bins, 1 Scanning Module, and 1 Manipulator."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/vendomat
	name = "Circuit Board (Vending Machine)"
	build_path = "/obj/machinery/vending"
	board_type = "machine"
	origin_tech = "materials=1;engineering=1;powerstorage=1"
	frame_desc = "Requires 1 Matter Bins, 1 Scanning Module, and 1 Manipulator."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/pdapainter
	name = "Circuit Board (PDA Painter)"
	build_path = "/obj/machinery/pdapainter"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 1 Manipulator, 2 Micro-Lasers, 2 Scanning Modules, and 1 Console Screen. "
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/incubator
	name = "Circuit Board (Pathogenic Incubator)"
	build_path = "/obj/machinery/disease2/incubator"
	board_type = "machine"
	origin_tech = "materials=4;biotech=5;magnets=3"
	frame_desc = "Requires 1 Matter Bin, 2 Scanning Modules, 2 Micro-Lasers, and 1 Beaker."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 1)

/obj/item/weapon/circuitboard/diseaseanalyser
	name = "Circuit Board (Disease Analyser)"
	build_path = "/obj/machinery/disease2/diseaseanalyser"
	board_type = "machine"
	origin_tech = "engineering=3;biotech=3;programming=3"
	frame_desc = "Requires 1 Micro-Laser, 1 Manipulator, and 3 Scanning Modules."
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 3)

/obj/item/weapon/circuitboard/centrifuge
	name = "Circuit Board (Isolation Centrifuge)"
	build_path = "/obj/machinery/centrifuge"
	board_type = "machine"
	origin_tech = "biotech=3"
	frame_desc = "Requires 2 Manipulators"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/mech_bay_power_port
	name = "Circuit Board (Power Port)"
	build_path = "/obj/machinery/mech_bay_recharge_port"
	board_type = "machine"
	origin_tech = "engineering=2;powerstorage=3"
	frame_desc = "Requires 2 Micro-Lasers, and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/mech_bay_recharge_station
	name = "Circuit Board (Recharge Station)"
	build_path = "/obj/machinery/mech_bay_recharge_floor"
	board_type = "machine"
	origin_tech = "materials=2;powerstorage=3"
	frame_desc = "Requires 1 Scanning Module and 2 Capacitors."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/prism
	name = "Circuit Board (Prism)"
	build_path = "/obj/machinery/prism"
	board_type = "machine"
	origin_tech = "programming=3;engineering=3;powerstorage=3"
	frame_desc = "Requires 3 High-powered Micro-Lasers, and 6 Capacitors."
	req_components = list(
							"/obj/item/weapon/stock_parts/micro_laser/high" = 3,
							"/obj/item/weapon/stock_parts/capacitor" = 6)

/obj/item/weapon/circuitboard/cell_charger
	name = "Circuit Board (Cell Charger)"
	build_path = "/obj/machinery/cell_charger"
	board_type = "machine"
	origin_tech = "materials=2;engineering=2;powerstorage=3"
	frame_desc = "Requires 1 Scanning Module and 2 Capacitors."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/washing_machine
	name = "Circuit Board (Washing Machine)"
	build_path = "/obj/machinery/washing_machine"
	board_type = "machine"
	origin_tech = "materials=1"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1)

/obj/item/weapon/circuitboard/sorting_machine
	name = "Circuit Board (Sorting Machine)"
	board_type = "machine"
	origin_tech = "materials=2;engineering=2;programming=3"
	frame_desc = "Requires 3 Matter Bins and 1 Capacitor" //Matter bins because it's moving matter, I guess, and a capacitor because else the recipe is boring.
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/sorting_machine/recycling
	name = "Circuit Board (Recycling Sorting Machine)"
	build_path = "/obj/machinery/sorting_machine/recycling"

/obj/item/weapon/circuitboard/sorting_machine/destination
	name = "Circuit Board (Destinations Sorting Machine)"
	build_path = "/obj/machinery/sorting_machine/destination"

/obj/item/weapon/circuitboard/processing_unit
	name = "Circuit Board (Ore Processor)"
	build_path = "/obj/machinery/mineral/processing_unit"
	board_type = "machine"
	origin_tech = "materials=3;engineering=2;programming=2"
	frame_desc = "Requires 2 Matter Bins and 2 Micro-lasers"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2)

/obj/item/weapon/circuitboard/processing_unit/recycling
	name = "Circuit Board (Recycling Furnace)"
	build_path = "/obj/machinery/mineral/processing_unit/recycle"

/obj/item/weapon/circuitboard/stacking_unit
	name = "Circuit Board (Stacking Machine)"
	build_path = "/obj/machinery/mineral/stacking_machine"
	board_type = "machine"
	origin_tech = "materials=3;engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins and 1 Capacitor" //Matter bins because it's moving matter, I guess, and a capacitor because else the recipe is boring.
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/fax
	name = "Circuit Board (Fax Machine)"
	build_path = "/obj/machinery/faxmachine"
	board_type = "machine"
	origin_tech = "materials=2;bluespace=2"
	frame_desc = "Requires 1 ansible and 1 scanning module."
	req_components = list(
							"/obj/item/weapon/stock_parts/subspace/ansible" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/*
 * Xenobotany
*/

/obj/item/weapon/circuitboard/botany_centrifuge
	name = "Circuit Board (Lysis-Isolation Centrifuge)"
	build_path = "/obj/machinery/botany/extractor"
	board_type = "machine"
	origin_tech = "engineering=3;biotech=3"
	frame_desc = "Requires 1 manipulator, 2 scanning modules, 2 micro-lasers, 1 matter bin, and 2 console screens."
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 3,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 1)

/obj/item/weapon/circuitboard/botany_bioballistic
	name = "Circuit Board (Bioballistic Delivery System)"
	build_path = "/obj/machinery/botany/editor"
	board_type = "machine"
	origin_tech = "engineering=3;biotech=3"
	frame_desc = "Requires 1 manipulator, 2 scanning modules, 2 micro-lasers, and 1 console screen."
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 3,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1,)
/*
 * Xenoarcheology
*/

/obj/item/weapon/circuitboard/anom
	name = "Circuit Board (Fourier Transform Spectroscope)"
	build_path = "/obj/machinery/anomaly/fourier_transform"
	board_type = "machine"
	origin_tech = "programming=4"
	frame_desc = "Requires 3 scanning modules."
	req_components = list (
							"/obj/item/weapon/stock_parts/scanning_module" = 3)

/obj/item/weapon/circuitboard/anom/accelerator
	name = "Circuit Board (Accelerator Spectrometer)"
	build_path = "/obj/machinery/anomaly/accelerator"

/obj/item/weapon/circuitboard/anom/gas
	name = "Circuit Board (Gas Chromatography Spectrometer)"
	build_path = "/obj/machinery/anomaly/gas_chromatography"

/obj/item/weapon/circuitboard/anom/hyper
	name = "Circuit Board (Hyperspectral Imager)"
	build_path = "/obj/machinery/anomaly/hyperspectral"

/obj/item/weapon/circuitboard/anom/ion
	name = "Circuit Board (Ion Mobility Spectrometer)"
	build_path = "/obj/machinery/anomaly/ion_mobility"

/obj/item/weapon/circuitboard/anom/iso
	name = "Circuit Board (Isotope Ratio Spectrometer)"
	build_path = "/obj/machinery/anomaly/isotope_ratio"
