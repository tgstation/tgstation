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
		if(ispath(tname, /obj/item/stack))
			var/obj/item/stack/S = tname
			var/singular_name = initial(S.singular_name)
			if(singular_name)
				req_component_names[tname] = singular_name
			else
				req_component_names[tname] = initial(S.name)
		else
			var/obj/O = tname
			req_component_names[tname] = initial(O.name)

/obj/structure/frame/machine/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/structure/frame/machine/attackby(obj/item/P, mob/user, params)
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

/obj/item/weapon/circuitboard/machine/proc/apply_default_parts(obj/machinery/M)
	if(!req_components)
		return

	M.component_parts = list(src)
	loc = null

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(ispath(comp_path, /obj/item/stack))
			M.component_parts += new comp_path(null, comp_amt)
		else
			for(var/i in 1 to comp_amt)
				M.component_parts += new comp_path(null)

	M.RefreshParts()


/obj/item/weapon/circuitboard/machine/smes
	name = "circuit board (SMES)"
	build_path = /obj/machinery/power/smes
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/weapon/stock_parts/cell = 5,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/teleporter_hub
	name = "circuit board (Teleporter Hub)"
	build_path = /obj/machinery/teleport/hub
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)

/obj/item/weapon/circuitboard/machine/teleporter_station
	name = "circuit board (Teleporter Station)"
	build_path = /obj/machinery/teleport/station
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/chem_dispenser
	name = "circuit board (Portable Chem Dispenser)"
	build_path = /obj/machinery/chem_dispenser/constructable
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/weapon/stock_parts/cell = 1)

/obj/item/weapon/circuitboard/machine/telesci_pad
	name = "circuit board (Telepad)"
	build_path = /obj/machinery/telepad
	origin_tech = "programming=4;engineering=3;plasmatech=4;bluespace=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/deep_fryer
	name = "circuit board (Deep Fryer)"
	build_path = /obj/machinery/deepfryer
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1)
