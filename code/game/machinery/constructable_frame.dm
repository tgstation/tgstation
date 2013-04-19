//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = 0
	var/obj/item/part/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/state = 1

/obj/machinery/constructable_frame/machine_frame
	attackby(obj/item/P as obj, mob/user as mob)
		if(P.crit_fail)
			user << "\red This part is faulty, you cannot add this to the machine!"
			return
		switch(state)
			if(1)
				if(istype(P, /obj/item/part/cable_coil))
					var/obj/item/part/cable_coil/C = P
					if(C.amount >= 5)
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						user << "\blue You start to add cables to the frame."
						if(do_after(user, 20))
							if(C)
								C.amount -= 5
								if(!C.amount) del(C)
								user << "\blue You add cables to the frame."
								state = 2
								icon_state = "box_1"
				if(istype(P, /obj/item/tool/wrench))
					playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
					user << "\blue You dismantle the frame"
					new /obj/item/part/stack/sheet/metal(src.loc, 5)
					del(src)
			if(2)
				if(istype(P, /obj/item/part/circuitboard))
					var/obj/item/part/circuitboard/B = P
					if(B.board_type == "machine")
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						user << "\blue You add the circuit board to the frame."
						circuit = P
						user.drop_item()
						P.loc = src
						icon_state = "box_2"
						state = 3
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						if(circuit.frame_desc) desc = circuit.frame_desc
					else
						user << "\red This frame does not accept circuit boards of this type!"
				if(istype(P, /obj/item/part/wirecutters))
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					user << "\blue You remove the cables."
					state = 1
					icon_state = "box_0"
					var/obj/item/part/cable_coil/A = new /obj/item/part/cable_coil( src.loc )
					A.amount = 5

			if(3)
				if(istype(P, /obj/item/tool/crowbar))
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
					icon_state = "box_1"

				if(istype(P, /obj/item/tool/screwdriver))
					var/component_check = 1
					for(var/R in req_components)
						if(req_components[R] > 0)
							component_check = 0
							break
					if(component_check)
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
						var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
						for(var/obj/O in new_machine.component_parts)
							del(O)
						new_machine.component_parts = list()
						for(var/obj/O in src)
							O.loc = new_machine
							new_machine.component_parts += O
						circuit.loc = new_machine
						new_machine.RefreshParts()
						del(src)

				if(istype(P, /obj/item/weapon))
					for(var/I in req_components)
						if(istype(P, text2path(I)) && (req_components[I] > 0))
							if(istype(P, /obj/item/part/cable_coil))
								var/obj/item/part/cable_coil/CP = P
								if(CP.amount > 1)
									var/obj/item/part/cable_coil/CC = new /obj/item/part/cable_coil(src)
									CC.amount = 1
									components += CC
									req_components[I]--
									break
							user.drop_item()
							P.loc = src
							components += P
							req_components[I]--
							break
					if(P.loc != src && !istype(P, /obj/item/part/cable_coil))
						user << "\red You cannot add that component to the machine!"


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/
/obj/item/part/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = "/obj/machinery/r_n_d/destructive_analyzer"
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	frame_desc = "Requires 1 Scanning Module, 1 Manipulator, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/part/basic/scanning_module" = 1,
							"/obj/item/part/basic/manipulator" = 1,
							"/obj/item/part/basic/micro_laser" = 1)

/obj/item/part/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	build_path = "/obj/machinery/autolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							"/obj/item/part/basic/matter_bin" = 3,
							"/obj/item/part/basic/manipulator" = 1,
							"/obj/item/part/basic/console_screen" = 1)

/obj/item/part/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	build_path = "/obj/machinery/r_n_d/protolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 2 Matter Bins, 2 Manipulators, and 2 Beakers."
	req_components = list(
							"/obj/item/part/basic/matter_bin" = 2,
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/chem/glass/beaker" = 2)


/obj/item/part/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = "/obj/machinery/r_n_d/circuit_imprinter"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, and 2 Beakers."
	req_components = list(
							"/obj/item/part/basic/matter_bin" = 1,
							"/obj/item/part/basic/manipulator" = 1,
							"/obj/item/chem/glass/beaker" = 2)

/obj/item/part/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman"
	board_type = "machine"
	origin_tech = "programming=3:powerstorage=3;plasmatech=3;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Micro-Laser, 2 Pieces of Cable, and 1 Capacitor."
	req_components = list(
							"/obj/item/part/basic/matter_bin" = 1,
							"/obj/item/part/basic/micro_laser" = 1,
							"/obj/item/part/cable_coil" = 2,
							"/obj/item/part/basic/capacitor" = 1)

/obj/item/part/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/super"
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/part/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"

obj/item/part/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = "/obj/machinery/r_n_d/server"
	board_type = "machine"
	origin_tech = "programming=3"
	frame_desc = "Requires 2 pieces of cable, and 1 Scanning Module."
	req_components = list(
							"/obj/item/part/cable_coil" = 2,
							"/obj/item/part/basic/scanning_module" = 1)

/obj/item/part/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = "/obj/machinery/mecha_part_fabricator"
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							"/obj/item/part/basic/matter_bin" = 2,
							"/obj/item/part/basic/manipulator" = 1,
							"/obj/item/part/basic/micro_laser" = 1,
							"/obj/item/part/basic/console_screen" = 1)

/obj/item/part/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = "/obj/machinery/clonepod"
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	frame_desc = "Requires 2 Manipulator, 2 Scanning Module, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							"/obj/item/part/cable_coil" = 2,
							"/obj/item/part/basic/scanning_module" = 2,
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/basic/console_screen" = 1)

/obj/item/part/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = "/obj/machinery/dna_scannernew"
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 1 Scanning module, 1 Manipulator, 1 Micro-Laser, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							"/obj/item/part/basic/scanning_module" = 1,
							"/obj/item/part/basic/manipulator" = 1,
							"/obj/item/part/basic/micro_laser" = 1,
							"/obj/item/part/basic/console_screen" = 1,
							"/obj/item/part/cable_coil" = 2,)


// Telecomms circuit boards:

/obj/item/part/circuitboard/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	build_path = "/obj/machinery/telecomms/receiver"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	frame_desc = "Requires 1 Subspace Ansible, 1 Hyperwave Filter, 2 Manipulators, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/part/basic/subspace/ansible" = 1,
							"/obj/item/part/basic/subspace/filter" = 1,
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/basic/micro_laser" = 1)

/obj/item/part/circuitboard/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	build_path = "/obj/machinery/telecomms/hub"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filter."
	req_components = list(
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/cable_coil" = 2,
							"/obj/item/part/basic/subspace/filter" = 2)

/obj/item/part/circuitboard/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	build_path = "/obj/machinery/telecomms/relay"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	frame_desc = "Requires 2 Manipulators, 2 Cable Coil and 2 Hyperwave Filters."
	req_components = list(
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/cable_coil" = 2,
							"/obj/item/part/basic/subspace/filter" = 2)

/obj/item/part/circuitboard/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	build_path = "/obj/machinery/telecomms/bus"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/cable_coil" = 1,
							"/obj/item/part/basic/subspace/filter" = 1)

/obj/item/part/circuitboard/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	build_path = "/obj/machinery/telecomms/processor"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 3 Manipulators, 1 Hyperwave Filter, 2 Treatment Disks, 1 Wavelength Analyzer, 2 Cable Coils and 1 Subspace Amplifier."
	req_components = list(
							"/obj/item/part/basic/manipulator" = 3,
							"/obj/item/part/basic/subspace/filter" = 1,
							"/obj/item/part/basic/subspace/treatment" = 2,
							"/obj/item/part/basic/subspace/analyzer" = 1,
							"/obj/item/part/cable_coil" = 2,
							"/obj/item/part/basic/subspace/amplifier" = 1)

/obj/item/part/circuitboard/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	build_path = "/obj/machinery/telecomms/server"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/cable_coil" = 1,
							"/obj/item/part/basic/subspace/filter" = 1)

/obj/item/part/circuitboard/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	build_path = "/obj/machinery/telecomms/broadcaster"
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	frame_desc = "Requires 2 Manipulators, 1 Cable Coil, 1 Hyperwave Filter, 1 Ansible Crystal and 2 High-Powered Micro-Lasers. "
	req_components = list(
							"/obj/item/part/basic/manipulator" = 2,
							"/obj/item/part/cable_coil" = 1,
							"/obj/item/part/basic/subspace/filter" = 1,
							"/obj/item/part/basic/subspace/crystal" = 1,
							"/obj/item/part/basic/micro_laser/high" = 2)




