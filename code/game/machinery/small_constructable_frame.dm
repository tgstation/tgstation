//Copied from the constructable frame code to make this a hell of a lot easier.

/obj/machinery/small_constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'stock_parts.dmi'
	icon_state = "sbox_0"
	density = 1
	anchored = 0
	use_power = 0
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null
	var/state = 1

	proc/update_desc()
		var/D
		if(req_components)
			D = "Requires "
			var/first = 1
			for(var/I in req_components)
				if(req_components[I] > 0)
					D += "[first?"":", "][num2text(req_components[I])] [req_component_names[I]]"
					first = 0
			if(first) // nothing needs to be added, then
				D += "nothing, use a screwdriver to finish it up."
			D += "."
		desc = D

/obj/machinery/small_constructable_frame
	attackby(obj/item/P as obj, mob/user as mob)
		if(P.crit_fail)
			user << "\red This part is faulty, you cannot add this to the machine!"
			return
		switch(state)
			if(1)
				if(istype(P, /obj/item/weapon/wrench))
					if(P:amount >= 5)
						playsound(src.loc, 'Ratchet.ogg', 50, 1)
						user << "\blue You wrench the frame in place."
			if(2)
				if(istype(P, /obj/item/weapon/cable_coil))
					if(P:amount >= 5)
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						user << "\blue You start to add cables to the frame."
						if(do_after(user, 20))
							P:amount -= 5
							if(!P:amount) del(P)
							user << "\blue You add cables to the frame."
							state = 2
							icon_state = "sbox_1"
				if(istype(P, /obj/item/weapon/wrench))
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					user << "\blue You dismantle the frame"
					new /obj/item/stack/sheet/metal(src.loc, 5)
					del(src)
			if(3)
				if(istype(P, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/B = P
					if(B.board_type == "smachine")
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						user << "\blue You add the circuit board to the frame."
						circuit = P
						user.drop_item()
						P.loc = src
						icon_state = "sbox_2"
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
					playsound(src.loc, 'wirecutter.ogg', 50, 1)
					user << "\blue You remove the cables."
					state = 1
					icon_state = "sbox_0"
					var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
					A.amount = 5

			if(4)
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(src.loc, 'Crowbar.ogg', 50, 1)
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
					icon_state = "sbox_1"

				if(istype(P, /obj/item/weapon/screwdriver))
					var/component_check = 1
					for(var/R in req_components)
						if(req_components[R] > 0)
							component_check = 0
							break
					if(component_check)
						playsound(src.loc, 'Screwdriver.ogg', 50, 1)
						var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
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
							playsound(src.loc, 'Deconstruct.ogg', 50, 1)
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


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/

/obj/item/weapon/circuitboard/recharger
	name = "Circuit board (recharger)"
	build_path = "/obj/machinery/recharger"
	board_type = "smachine"
	origin_tech = "engineering=2;powerstorage=3"
	frame_desc = "Requires 1 Manipulator, 2 capacitors, and 1 cable coil"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/cellrecharger
	name = "Circuit board (cell recharger)"
	build_path = "/obj/machinery/cell_charger"
	board_type = "smachine"
	origin_tech = "engineering=2;powerstorage=2"
	frame_desc = "Requires 1 Manipulator, 2 capacitors, and 1 cable coil"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)



