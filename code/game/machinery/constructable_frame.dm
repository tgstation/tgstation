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
	var/list/req_component_names = null // user-friendly names of components
	var/state = 1

// unfortunately, we have to instance the objects really quickly to get the names
// fortunately, this is only called once when the board is added and the items are immediately GC'd
// and none of the parts do much in their constructors
/obj/machinery/constructable_frame/proc/update_namelist()
	if(!req_components)
		return

	req_component_names = new()
	for(var/tname in req_components)
		var/path = tname
		var/obj/O = new path()
		req_component_names[tname] = O.name

/obj/machinery/constructable_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

// update description of required components remaining
/obj/machinery/constructable_frame/proc/update_req_desc()
	if(!req_components || !req_component_names)
		return

	var/hasContent = 0
	desc = "Requires"
	for(var/i = 1 to req_components.len)
		var/tname = req_components[i]
		var/amt = req_components[tname]
		if(amt == 0)
			continue
		var/use_and = i == req_components.len
		desc += "[(hasContent ? (use_and ? ", and" : ",") : "")] [amt] [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
		hasContent = 1

	if(!hasContent)
		desc = "Does not require any more components."
	else
		desc += "."

/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/P, mob/user, params)
	if(P.crit_fail)
		user << "<span class='warning'>This part is faulty, you cannot add this to the machine!</span>"
		return
	switch(state)
		if(1)
			if(istype(P, /obj/item/weapon/circuitboard))
				user << "<span class='warning'>The frame needs wiring first!</span>"
				return
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start to add cables to the frame...</span>"
					if(do_after(user, 20, target = src))
						if(C.get_amount() >= 5 && state == 1)
							C.use(5)
							user << "<span class='notice'>You add cables to the frame.</span>"
							state = 2
							icon_state = "box_1"
				else
					user << "<span class='warning'>You need five length of cable to wire the frame!</span>"
					return
			if(istype(P, /obj/item/weapon/screwdriver) && !anchored)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] disassembles the frame.</span>", \
									"<span class='notice'>You start to disassemble the frame...</span>", "You hear banging and clanking.")
				if(do_after(user, 40, target = src))
					if(state == 1)
						user << "<span class='notice'>You disassemble the frame.</span>"
						var/obj/item/stack/sheet/metal/M = new (loc, 5)
						M.add_fingerprint(user)
						qdel(src)
			if(istype(P, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				if(do_after(user, 40, target = src))
					if(state == 1)
						user << "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>"
						anchored = !anchored

		if(2)
			if(istype(P, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				if(do_after(user, 40, target = src))
					user << "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>"
					anchored = !anchored

			if(istype(P, /obj/item/weapon/circuitboard))
				if(!anchored)
					user << "<span class='warning'>The frame needs to be secured first!</span>"
					return
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "machine")
					if(!user.drop_item())
						return
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You add the circuit board to the frame.</span>"
					circuit = P
					P.loc = src
					icon_state = "box_2"
					state = 3
					components = list()
					req_components = circuit.req_components.Copy()
					update_namelist()
					update_req_desc()
				else
					user << "<span class='warning'>This frame does not accept circuit boards of this type!</span>"
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "<span class='notice'>You remove the cables.</span>"
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5

		if(3)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				state = 2
				circuit.loc = src.loc
				components.Remove(circuit)
				circuit = null
				if(components.len == 0)
					user << "<span class='notice'>You remove the circuit board.</span>"
				else
					user << "<span class='notice'>You remove the circuit board and other components.</span>"
					for(var/atom/movable/A in components)
						A.loc = src.loc
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"

			if(istype(P, /obj/item/weapon/screwdriver))
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					var/obj/machinery/new_machine = new src.circuit.build_path(src.loc, 1)
					new_machine.construction()
					for(var/obj/O in new_machine.component_parts)
						qdel(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						O.loc = null
						new_machine.component_parts += O
					circuit.loc = null
					new_machine.RefreshParts()
					qdel(src)

			if(istype(P, /obj/item/weapon/storage/part_replacer) && P.contents.len && get_req_components_amt())
				var/obj/item/weapon/storage/part_replacer/replacer = P
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/weapon/stock_parts/co in replacer)
					part_list += co
				//Sort the parts. This ensures that higher tier items are applied first.
				part_list = sortTim(part_list, /proc/cmp_rped_sort)

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						if(!part.crit_fail)
							added_components[part] = path
							replacer.remove_from_storage(part, src)
							req_components[path]--
							part_list -= part

				for(var/obj/item/weapon/stock_parts/part in added_components)
					components += part
					user << "<span class='notice'>[part.name] applied.</span>"
				replacer.play_rped_sound()

				update_req_desc()
				return

			if(istype(P, /obj/item) && get_req_components_amt())
				var/success
				for(var/I in req_components)
					if(istype(P, I) && (req_components[I] > 0))
						if(!user.drop_item())
							return
						success=1
						if(istype(P, /obj/item/stack/cable_coil))
							var/obj/item/stack/cable_coil/CP = P
							if (CP.get_amount() < 1)
								user << "<span class='warning'>You need more cable!</span>"
								return
							var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(src, 1, CP.item_color)
							if(CP.use(1))
								components += CC
								req_components[I]--
								update_req_desc()
							break
						P.loc = src
						components += P
						req_components[I]--
						update_req_desc()
						return 1
				if(!success)
					user << "<span class='warning'>You cannot add that to the machine!</span>"
					return 0


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/

/obj/item/weapon/circuitboard/vendor
	name = "circuit board (Booze-O-Mat Vendor)"
	build_path = /obj/machinery/vending/boozeomat
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/vending_refill/boozeomat = 3)

	var/list/names_paths = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp",
							/obj/machinery/vending/cola = "Robust Softdrinks",
							/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
							/obj/machinery/vending/autodrobe = "AutoDrobe")

/obj/item/weapon/circuitboard/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		set_type(pick(names_paths), user)


/obj/item/weapon/circuitboard/vendor/proc/set_type(typepath, mob/user)
		build_path = typepath
		name = "circuit board ([names_paths[build_path]] Vendor)"
		user << "<span class='notice'>You set the board to [names_paths[build_path]].</span>"
		req_components = list(text2path("/obj/item/weapon/vending_refill/[copytext("[build_path]", 24)]") = 3)       //Never before has i used a method as horrible as this one, im so sorry

/obj/item/weapon/circuitboard/smes
	name = "circuit board (SMES)"
	build_path = /obj/machinery/power/smes
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/cell = 5,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/emitter
	name = "circuit board (Emitter)"
	build_path = /obj/machinery/power/emitter
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/power_compressor
	name = "circuit board (Power Compressor)"
	build_path = /obj/machinery/power/compressor
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=5;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/manipulator = 6)

/obj/item/weapon/circuitboard/power_turbine
	name = "circuit board (Power Turbine)"
	build_path = /obj/machinery/power/turbine
	board_type = "machine"
	origin_tech = "programming=4;powerstorage=4;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/capacitor = 6)

/obj/item/weapon/circuitboard/mech_recharger
	name = "circuit board (Mechbay Recharger)"
	build_path = /obj/machinery/mech_bay_recharge_port
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/capacitor = 5)

/obj/item/weapon/circuitboard/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	board_type = "machine"
	origin_tech = "programming=3;engineering=5;bluespace=5;materials=4"
	req_components = list(
							/obj/item/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	board_type = "machine"
	origin_tech = "programming=4;engineering=4;bluespace=4"
	req_components = list(
							/obj/item/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/telesci_pad
	name = "circuit board (Telepad)"
	build_path = /obj/machinery/telepad
	board_type = "machine"
	origin_tech = "programming=4;engineering=3;materials=3;bluespace=4"
	req_components = list(
							/obj/item/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/sleeper
	name = "circuit board (Sleeper)"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 2)

/obj/item/weapon/circuitboard/cryo_tube
	name = "circuit board (Cryotube)"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	board_type = "machine"
	origin_tech = "programming=4;biotech=3;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 4)

/obj/item/weapon/circuitboard/thermomachine
	name = "circuit board (Freezer)"
	desc = "Use screwdriver to switch between heating and cooling modes."
	build_path = /obj/machinery/atmospherics/components/unary/cold_sink/freezer
	board_type = "machine"
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/thermomachine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(build_path == /obj/machinery/atmospherics/components/unary/cold_sink/freezer)
			build_path = /obj/machinery/atmospherics/components/unary/heat_reservoir/heater
			name = "circuit board (Heater)"
			user << "<span class='notice'>You set the board to heating.</span>"
		else
			build_path = /obj/machinery/atmospherics/components/unary/cold_sink/freezer
			name = "circuit board (Freezer)"
			user << "<span class='notice'>You set the board to cooling.</span>"

/obj/item/weapon/circuitboard/biogenerator
	name = "circuit board (Biogenerator)"
	build_path = /obj/machinery/biogenerator
	board_type = "machine"
	origin_tech = "programming=3;biotech=2;materials=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/hydroponics
	name = "circuit board (Hydroponics Tray)"
	build_path = /obj/machinery/hydroponics/constructable
	board_type = "machine"
	origin_tech = "programming=1;biotech=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/microwave
	name = "circuit board (Microwave)"
	build_path = /obj/machinery/microwave
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/gibber
	name = "circuit board (Gibber)"
	build_path = /obj/machinery/gibber
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/processor
	name = "circuit board (Food processor)"
	build_path = /obj/machinery/processor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/recycler
	name = "circuit board (Recycler)"
	build_path = /obj/machinery/recycler
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/seed_extractor
	name = "circuit board (Seed Extractor)"
	build_path = /obj/machinery/seed_extractor
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/smartfridge
	name = "circuit board (Smartfridge)"
	build_path = /obj/machinery/smartfridge
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/smartfridge/New(loc, new_type)
	if(new_type)
		build_path = new_type

/obj/item/weapon/circuitboard/smartfridge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/list/fridges = list(/obj/machinery/smartfridge = "default",
									 /obj/machinery/smartfridge/drinks = "drinks",
									 /obj/machinery/smartfridge/extract = "slimes",
									 /obj/machinery/smartfridge/chemistry = "chems",
									 /obj/machinery/smartfridge/chemistry/virology = "viruses")

		var/position = fridges.Find(build_path, fridges)
		position = (position == fridges.len) ? 1 : (position + 1)
		build_path = fridges[position]
		user << "<span class='notice'>You set the board to [fridges[build_path]].</span>"

/obj/item/weapon/circuitboard/monkey_recycler
	name = "circuit board (Monkey Recycler)"
	build_path = /obj/machinery/monkey_recycler
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/holopad
	name = "circuit board (AI Holopad)"
	build_path = /obj/machinery/hologram/holopad
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/chem_dispenser
	name = "circuit board (Portable Chem Dispenser)"
	build_path = /obj/machinery/chem_dispenser/constructable
	board_type = "machine"
	origin_tech = "materials=4;engineering=4;programming=4;plasmatech=3;biotech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/cell = 1)

/obj/item/weapon/circuitboard/chem_master
	name = "circuit board (Chem Master 2999)"
	build_path = /obj/machinery/chem_master/constructable
	board_type = "machine"
	origin_tech = "materials=2;programming=2;biotech=1"
	req_components = list(
							/obj/item/weapon/reagent_containers/glass/beaker = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/chem_heater
	name = "circuit board (Chemical Heater)"
	build_path = /obj/machinery/chem_heater
	board_type = "machine"
	origin_tech = "materials=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/weapon/circuitboard/experimentor
	name = "circuit board (E.X.P.E.R.I-MENTOR)"
	build_path = /obj/machinery/r_n_d/experimentor
	board_type = "machine"
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2)


/obj/item/weapon/circuitboard/destructive_analyzer
	name = "circuit board (Destructive Analyzer)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/autolathe
	name = "circuit board (Autolathe)"
	build_path = /obj/machinery/autolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 3,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/protolathe
	name = "circuit board (Protolathe)"
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)


/obj/item/weapon/circuitboard/circuit_imprinter
	name = "circuit board (Circuit Imprinter)"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)

/obj/item/weapon/circuitboard/pacman
	name = "circuit board (PACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman
	board_type = "machine"
	origin_tech = "programming=3;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/pacman/super
	name = "circuit board (SUPERPACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/weapon/circuitboard/pacman/mrs
	name = "circuit board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"

obj/item/weapon/circuitboard/rdserver
	name = "circuit board (R&D Server)"
	build_path = /obj/machinery/r_n_d/server
	board_type = "machine"
	origin_tech = "programming=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/item/weapon/circuitboard/mechfab
	name = "circuit board (Exosuit Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/clonepod
	name = "circuit board (Clone Pod)"
	build_path = /obj/machinery/clonepod
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/clonescanner
	name = "circuit board (Cloning Scanner)"
	build_path = /obj/machinery/dna_scannernew
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2,)

/obj/item/weapon/circuitboard/cyborgrecharger
	name = "circuit board (Cyborg Recharger)"
	build_path = /obj/machinery/recharge_station
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/cell = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,)

// Telecomms circuit boards:

/obj/item/weapon/circuitboard/telecomms/receiver
	name = "circuit board (Subspace Receiver)"
	build_path = /obj/machinery/telecomms/receiver
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	req_components = list(
							/obj/item/weapon/stock_parts/subspace/ansible = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/telecomms/hub
	name = "circuit board (Hub Mainframe)"
	build_path = /obj/machinery/telecomms/hub
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/telecomms/relay
	name = "circuit board (Relay Mainframe)"
	build_path = /obj/machinery/telecomms/relay
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/telecomms/bus
	name = "circuit board (Bus Mainframe)"
	build_path = /obj/machinery/telecomms/bus
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/telecomms/processor
	name = "circuit board (Processor Unit)"
	build_path = /obj/machinery/telecomms/processor
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 3,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/treatment = 2,
							/obj/item/weapon/stock_parts/subspace/analyzer = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1)

/obj/item/weapon/circuitboard/telecomms/server
	name = "circuit board (Telecommunication Server)"
	build_path = /obj/machinery/telecomms/server
	board_type = "machine"
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/telecomms/broadcaster
	name = "circuit board (Subspace Broadcaster)"
	build_path = /obj/machinery/telecomms/broadcaster
	board_type = "machine"
	origin_tech = "programming=2;engineering=2;bluespace=1"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/micro_laser/high = 2)
/obj/item/weapon/circuitboard/ore_redemption
	name = "circuit board (Ore Redemption)"
	build_path = /obj/machinery/mineral/ore_redemption
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/device/assembly/igniter = 1)

/obj/item/weapon/circuitboard/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	board_type = "machine"
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 3)
