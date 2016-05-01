/obj/structure/frame
	name = "frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	var/obj/item/weapon/circuitboard/circuit = null
	var/state = 1

/obj/structure/frame/examine(user)
	..()
	if(circuit)
		user << "It has \a [circuit] installed."

/obj/structure/frame/machine
	name = "machine frame"
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components

/obj/structure/frame/machine/examine(user)
	..()
	if(state == 3 && req_components && req_component_names)
		var/hasContent = 0
		var/requires = "It requires"

		for(var/i = 1 to req_components.len)
			var/tname = req_components[i]
			var/amt = req_components[tname]
			if(amt == 0)
				continue
			var/use_and = i == req_components.len
			requires += "[(hasContent ? (use_and ? ", and" : ",") : "")] [amt] [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
			hasContent = 1

		if(hasContent)
			user << requires + "."
		else
			user << "It does not require any more components."

/obj/structure/frame/machine/proc/update_namelist()
	if(!req_components)
		return

	req_component_names = new()
	for(var/tname in req_components)
		var/obj/O = tname
		req_component_names[tname] = initial(O.name)

/obj/structure/frame/machine/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/structure/frame/machine/attackby(obj/item/P, mob/user, params)
	if(P.crit_fail)
		user << "<span class='warning'>This part is faulty, you cannot add this to the machine!</span>"
		return
	switch(state)
		if(1)
			if(istype(P, /obj/item/weapon/circuitboard/machine))
				user << "<span class='warning'>The frame needs wiring first!</span>"

			else if(istype(P, /obj/item/weapon/circuitboard))
				user << "<span class='warning'>This frame does not accept circuit boards of this type!</span>"

			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					user << "<span class='notice'>You start to add cables to the frame...</span>"
					if(do_after(user, 20/P.toolspeed, target = src))
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
				if(do_after(user, 40/P.toolspeed, target = src))
					if(state == 1)
						user << "<span class='notice'>You disassemble the frame.</span>"
						var/obj/item/stack/sheet/metal/M = new (loc, 5)
						M.add_fingerprint(user)
						qdel(src)
			if(istype(P, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				if(do_after(user, 40/P.toolspeed, target = src))
					if(state == 1)
						user << "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>"
						anchored = !anchored

		if(2)
			if(istype(P, /obj/item/weapon/wrench))
				user << "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>"
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				if(do_after(user, 40/P.toolspeed, target = src))
					user << "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>"
					anchored = !anchored

			if(istype(P, /obj/item/weapon/circuitboard/machine))
				if(!anchored)
					user << "<span class='warning'>The frame needs to be secured first!</span>"
					return
				var/obj/item/weapon/circuitboard/machine/B = P
				if(!user.drop_item())
					return
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "<span class='notice'>You add the circuit board to the frame.</span>"
				circuit = B
				B.loc = src
				icon_state = "box_2"
				state = 3
				components = list()
				req_components = B.req_components.Copy()
				update_namelist()

			else if(istype(P, /obj/item/weapon/circuitboard))
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
				if(added_components.len)
					replacer.play_rped_sound()
				return

			if(istype(P, /obj/item) && get_req_components_amt())
				for(var/I in req_components)
					if(istype(P, I) && (req_components[I] > 0))
						if(istype(P, /obj/item/stack))
							var/obj/item/stack/S = P
							var/used_amt = min(round(S.get_amount()), req_components[I])

							if(used_amt && S.use(used_amt))
								var/obj/item/stack/NS = locate(S.merge_type) in components

								if(!NS)
									NS = new S.merge_type(src, used_amt)
									components += NS
								else
									NS.add(used_amt)

								req_components[I] -= used_amt
								user << "<span class='notice'>You add [P] to [src].</span>"
							return
						if(!user.drop_item())
							break
						user << "<span class='notice'>You add [P] to [src].</span>"
						P.loc = src
						components += P
						req_components[I]--
						return 1
				user << "<span class='warning'>You cannot add that to the machine!</span>"
				return 0


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/weapon/circuitboard/machine
	var/list/req_components = null

/obj/item/weapon/circuitboard/machine/vendor
	name = "circuit board (Booze-O-Mat Vendor)"
	build_path = /obj/machinery/vending/boozeomat
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/vending_refill/boozeomat = 3)

	var/list/names_paths = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp",
							/obj/machinery/vending/cola = "Robust Softdrinks",
							/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
							/obj/machinery/vending/autodrobe = "AutoDrobe")

/obj/item/weapon/circuitboard/machine/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/position = names_paths.Find(build_path)
		position = (position == names_paths.len) ? 1 : (position + 1)
		var/typepath = names_paths[position]

		user << "<span class='notice'>You set the board to \"[names_paths[typepath]]\".</span>"
		set_type(typepath)

/obj/item/weapon/circuitboard/machine/vendor/proc/set_type(var/obj/machinery/vending/typepath)
	build_path = typepath
	name = "circuit board ([names_paths[build_path]] Vendor)"
	req_components = list(initial(typepath.refill_canister) = 3)

/obj/item/weapon/circuitboard/machine/announcement_system
	name = "circuit board (Announcement System)"
	build_path = /obj/machinery/announcement_system
	origin_tech = "programming=3;bluespace=2"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/smes
	name = "circuit board (SMES)"
	build_path = /obj/machinery/power/smes
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/cell = 5,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/emitter
	name = "circuit board (Emitter)"
	build_path = /obj/machinery/power/emitter
	origin_tech = "programming=4;powerstorage=5;engineering=5"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/power_compressor
	name = "circuit board (Power Compressor)"
	build_path = /obj/machinery/power/compressor
	origin_tech = "programming=4;powerstorage=5;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/manipulator = 6)

/obj/item/weapon/circuitboard/machine/power_turbine
	name = "circuit board (Power Turbine)"
	build_path = /obj/machinery/power/turbine
	origin_tech = "programming=4;powerstorage=4;engineering=5"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/capacitor = 6)

/obj/item/weapon/circuitboard/machine/mech_recharger
	name = "circuit board (Mechbay Recharger)"
	build_path = /obj/machinery/mech_bay_recharge_port
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/capacitor = 5)

/obj/item/weapon/circuitboard/machine/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	origin_tech = "programming=3;engineering=5;bluespace=5;materials=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/machine/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	origin_tech = "programming=4;engineering=4;bluespace=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/telesci_pad
	name = "circuit board (Telepad)"
	build_path = /obj/machinery/telepad
	origin_tech = "programming=4;engineering=3;materials=3;bluespace=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/sleeper
	name = "circuit board (Sleeper)"
	build_path = /obj/machinery/sleeper
	origin_tech = "programming=3;biotech=2;engineering=3;materials=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 2)

/obj/item/weapon/circuitboard/machine/cryo_tube
	name = "circuit board (Cryotube)"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	origin_tech = "programming=4;biotech=3;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 4)

/obj/item/weapon/circuitboard/machine/thermomachine
	name = "circuit board (Thermomachine)"
	desc = "You can use a screwdriver to switch between heater and freezer."
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/thermomachine/attackby(obj/item/I, mob/user, params)
	var/obj/item/weapon/circuitboard/machine/freezer = /obj/item/weapon/circuitboard/machine/thermomachine/freezer
	var/obj/item/weapon/circuitboard/machine/heater = /obj/item/weapon/circuitboard/machine/thermomachine/heater
	var/obj/item/weapon/circuitboard/machine/newtype

	if(istype(I, /obj/item/weapon/screwdriver))
		var/new_setting = "Heater"
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(build_path == initial(heater.build_path))
			newtype = freezer
			new_setting = "Freezer"
		else
			newtype = heater
		name = initial(newtype.name)
		build_path = initial(newtype.build_path)
		user << "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>"

/obj/item/weapon/circuitboard/machine/thermomachine/freezer
	name = "circuit board (Freezer)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer

/obj/item/weapon/circuitboard/machine/thermomachine/heater
	name = "circuit board (Heater)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/heater

/obj/item/weapon/circuitboard/machine/space_heater
	name = "circuit board (Space Heater)"
	build_path = /obj/machinery/space_heater
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 3)

/obj/item/weapon/circuitboard/machine/biogenerator
	name = "circuit board (Biogenerator)"
	build_path = /obj/machinery/biogenerator
	origin_tech = "programming=3;biotech=2;materials=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/hydroponics
	name = "circuit board (Hydroponics Tray)"
	build_path = /obj/machinery/hydroponics/constructable
	origin_tech = "programming=1;biotech=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/microwave
	name = "circuit board (Microwave)"
	build_path = /obj/machinery/microwave
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/gibber
	name = "circuit board (Gibber)"
	build_path = /obj/machinery/gibber
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/tesla_coil
	name = "circuit board (Tesla Coil)"
	build_path = /obj/machinery/power/tesla_coil
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/grounding_rod
	name = "circuit board (Grounding Rod)"
	build_path = /obj/machinery/power/grounding_rod
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/processor
	name = "circuit board (Food processor)"
	build_path = /obj/machinery/processor
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/recycler
	name = "circuit board (Recycler)"
	build_path = /obj/machinery/recycler
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/seed_extractor
	name = "circuit board (Seed Extractor)"
	build_path = /obj/machinery/seed_extractor
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/smartfridge
	name = "circuit board (Smartfridge)"
	build_path = /obj/machinery/smartfridge
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/machine/smartfridge/New(loc, new_type)
	if(new_type)
		build_path = new_type

/obj/item/weapon/circuitboard/machine/smartfridge/attackby(obj/item/I, mob/user, params)
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

/obj/item/weapon/circuitboard/machine/monkey_recycler
	name = "circuit board (Monkey Recycler)"
	build_path = /obj/machinery/monkey_recycler
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/holopad
	name = "circuit board (AI Holopad)"
	build_path = /obj/machinery/hologram/holopad
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/chem_dispenser
	name = "circuit board (Portable Chem Dispenser)"
	build_path = /obj/machinery/chem_dispenser/constructable
	origin_tech = "materials=4;engineering=4;programming=4;plasmatech=3;biotech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/cell = 1)

/obj/item/weapon/circuitboard/machine/chem_master
	name = "circuit board (Chem Master 2999)"
	build_path = /obj/machinery/chem_master/constructable
	origin_tech = "materials=2;programming=2;biotech=1"
	req_components = list(
							/obj/item/weapon/reagent_containers/glass/beaker = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/chem_heater
	name = "circuit board (Chemical Heater)"
	build_path = /obj/machinery/chem_heater
	origin_tech = "materials=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

//Almost the same recipe as destructive analyzer to give people choices.
/obj/item/weapon/circuitboard/machine/experimentor
	name = "circuit board (E.X.P.E.R.I-MENTOR)"
	build_path = /obj/machinery/r_n_d/experimentor
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2)


/obj/item/weapon/circuitboard/machine/destructive_analyzer
	name = "circuit board (Destructive Analyzer)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/machine/autolathe
	name = "circuit board (Autolathe)"
	build_path = /obj/machinery/autolathe
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 3,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/protolathe
	name = "circuit board (Protolathe)"
	build_path = /obj/machinery/r_n_d/protolathe
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)


/obj/item/weapon/circuitboard/machine/circuit_imprinter
	name = "circuit board (Circuit Imprinter)"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	origin_tech = "engineering=2;programming=2"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/reagent_containers/glass/beaker = 2)

/obj/item/weapon/circuitboard/machine/pacman
	name = "circuit board (PACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman
	origin_tech = "programming=3;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/pacman/super
	name = "circuit board (SUPERPACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/weapon/circuitboard/machine/pacman/mrs
	name = "circuit board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"

obj/item/weapon/circuitboard/machine/rdserver
	name = "circuit board (R&D Server)"
	build_path = /obj/machinery/r_n_d/server
	origin_tech = "programming=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/item/weapon/circuitboard/machine/mechfab
	name = "circuit board (Exosuit Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator
	origin_tech = "programming=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/clonepod
	name = "circuit board (Clone Pod)"
	build_path = /obj/machinery/clonepod
	origin_tech = "programming=3;biotech=3"
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 2,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/clonescanner
	name = "circuit board (Cloning Scanner)"
	build_path = /obj/machinery/dna_scannernew
	origin_tech = "programming=2;biotech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 2,)

/obj/item/weapon/circuitboard/machine/cyborgrecharger
	name = "circuit board (Cyborg Recharger)"
	build_path = /obj/machinery/recharge_station
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/cell = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,)

/obj/item/weapon/circuitboard/machine/recharger
	name = "circuit board (Weapon Recharger)"
	build_path = /obj/machinery/recharger
	origin_tech = "powerstorage=3;engineering=3;materials=4"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1,)

// Telecomms circuit boards:

/obj/item/weapon/circuitboard/machine/telecomms/receiver
	name = "circuit board (Subspace Receiver)"
	build_path = /obj/machinery/telecomms/receiver
	origin_tech = "programming=2;engineering=2;bluespace=1"
	req_components = list(
							/obj/item/weapon/stock_parts/subspace/ansible = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/machine/telecomms/hub
	name = "circuit board (Hub Mainframe)"
	build_path = /obj/machinery/telecomms/hub
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/machine/telecomms/relay
	name = "circuit board (Relay Mainframe)"
	build_path = /obj/machinery/telecomms/relay
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/machine/telecomms/bus
	name = "circuit board (Bus Mainframe)"
	build_path = /obj/machinery/telecomms/bus
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/machine/telecomms/processor
	name = "circuit board (Processor Unit)"
	build_path = /obj/machinery/telecomms/processor
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 3,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/treatment = 2,
							/obj/item/weapon/stock_parts/subspace/analyzer = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/subspace/amplifier = 1)

/obj/item/weapon/circuitboard/machine/telecomms/server
	name = "circuit board (Telecommunication Server)"
	build_path = /obj/machinery/telecomms/server
	origin_tech = "programming=2;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/machine/telecomms/broadcaster
	name = "circuit board (Subspace Broadcaster)"
	build_path = /obj/machinery/telecomms/broadcaster
	origin_tech = "programming=2;engineering=2;bluespace=1"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/subspace/filter = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/micro_laser/high = 2)
/obj/item/weapon/circuitboard/machine/ore_redemption
	name = "circuit board (Ore Redemption)"
	build_path = /obj/machinery/mineral/ore_redemption
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/device/assembly/igniter = 1)

/obj/item/weapon/circuitboard/machine/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	origin_tech = "programming=1;engineering=2"
	req_components = list(
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/matter_bin = 3)

/obj/item/weapon/circuitboard/machine/mining_equipment_vendor/golem
	name = "circuit board (Golem Ship Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/weapon/circuitboard/machine/plantgenes
	name = "circuit board (Plant DNA Manipulator)"
	build_path = /obj/machinery/plantgenes
	origin_tech = "programming=2;biotech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/scanning_module = 1,)