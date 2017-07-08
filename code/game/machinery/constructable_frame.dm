/obj/structure/frame
	name = "frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	max_integrity = 250
	var/obj/item/weapon/circuitboard/circuit = null
	var/state = 1

/obj/structure/frame/examine(user)
	..()
	if(circuit)
		to_chat(user, "It has \a [circuit] installed.")


/obj/structure/frame/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 5)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	qdel(src)


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
			to_chat(user, requires + ".")
		else
			to_chat(user, "It does not require any more components.")

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
				to_chat(user, "<span class='warning'>The frame needs wiring first!</span>")
				return
			else if(istype(P, /obj/item/weapon/circuitboard))
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame...</span>")
					if(do_after(user, 20*P.toolspeed, target = src))
						if(C.get_amount() >= 5 && state == 1)
							C.use(5)
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 2
							icon_state = "box_1"
				else
					to_chat(user, "<span class='warning'>You need five length of cable to wire the frame!</span>")
				return
			if(istype(P, /obj/item/weapon/screwdriver) && !anchored)
				playsound(src.loc, P.usesound, 50, 1)
				user.visible_message("<span class='warning'>[user] disassembles the frame.</span>", \
									"<span class='notice'>You start to disassemble the frame...</span>", "You hear banging and clanking.")
				if(do_after(user, 40*P.toolspeed, target = src))
					if(state == 1)
						to_chat(user, "<span class='notice'>You disassemble the frame.</span>")
						var/obj/item/stack/sheet/metal/M = new (loc, 5)
						M.add_fingerprint(user)
						qdel(src)
				return
			if(istype(P, /obj/item/weapon/wrench))
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				playsound(src.loc, P.usesound, 75, 1)
				if(do_after(user, 40*P.toolspeed, target = src))
					if(state == 1)
						to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
						anchored = !anchored
				return

		if(2)
			if(istype(P, /obj/item/weapon/wrench))
				to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
				playsound(src.loc, P.usesound, 75, 1)
				if(do_after(user, 40*P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
					anchored = !anchored
				return

			if(istype(P, /obj/item/weapon/circuitboard/machine))
				if(!anchored)
					to_chat(user, "<span class='warning'>The frame needs to be secured first!</span>")
					return
				var/obj/item/weapon/circuitboard/machine/B = P
				if(!user.drop_item())
					return
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
				circuit = B
				B.loc = src
				icon_state = "box_2"
				state = 3
				components = list()
				req_components = B.req_components.Copy()
				update_namelist()
				return

			else if(istype(P, /obj/item/weapon/circuitboard))
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return

			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 1
				icon_state = "box_0"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
				A.amount = 5
				return

		if(3)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, P.usesound, 50, 1)
				state = 2
				circuit.loc = src.loc
				components.Remove(circuit)
				circuit = null
				if(components.len == 0)
					to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				else
					to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
					for(var/atom/movable/A in components)
						A.loc = src.loc
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"
				return

			if(istype(P, /obj/item/weapon/screwdriver))
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					playsound(src.loc, P.usesound, 50, 1)
					var/obj/machinery/new_machine = new src.circuit.build_path(src.loc, 1)
					new_machine.on_construction()
					for(var/obj/O in new_machine.component_parts)
						qdel(O)
					new_machine.component_parts = list()
					for(var/obj/O in src)
						O.loc = null
						new_machine.component_parts += O
					circuit.loc = null
					new_machine.RefreshParts()
					qdel(src)
				return

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
					to_chat(user, "<span class='notice'>[part.name] applied.</span>")
				if(added_components.len)
					replacer.play_rped_sound()
				return

			if(isitem(P) && get_req_components_amt())
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
								to_chat(user, "<span class='notice'>You add [P] to [src].</span>")
							return
						if(!user.drop_item())
							break
						to_chat(user, "<span class='notice'>You add [P] to [src].</span>")
						P.forceMove(src)
						components += P
						req_components[I]--
						return 1
				to_chat(user, "<span class='warning'>You cannot add that to the machine!</span>")
				return 0
	if(user.a_intent == INTENT_HARM)
		return ..()


/obj/structure/frame/machine/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(state >= 2)
			new /obj/item/stack/cable_coil(loc , 5)
		for(var/X in components)
			var/obj/item/I = X
			I.forceMove(loc)
	..()



//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/weapon/circuitboard/machine
	var/list/req_components = null
	// Components required by the machine.
	// Example: list(/obj/item/weapon/stock_parts/matter_bin = 5)
	var/list/def_components = null
	// Default replacements for req_components, to be used in apply_default_parts instead of req_components types
	// Example: list(/obj/item/weapon/stock_parts/matter_bin = /obj/item/weapon/stock_parts/matter_bin/super)

/obj/item/weapon/circuitboard/machine/proc/apply_default_parts(obj/machinery/M)
	if(!req_components)
		return

	M.component_parts = list(src) // List of components always contains a board
	loc = null

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(def_components && def_components[comp_path])
			comp_path = def_components[comp_path]

		if(ispath(comp_path, /obj/item/stack))
			M.component_parts += new comp_path(null, comp_amt)
		else
			for(var/i in 1 to comp_amt)
				M.component_parts += new comp_path(null)

	M.RefreshParts()


/obj/item/weapon/circuitboard/machine/abductor
	name = "alien board (Report This)"
	icon_state = "abductor_mod"
	origin_tech = "programming=5;abductor=3"

/obj/item/weapon/circuitboard/machine/clockwork
	name = "clockwork board (Report This)"
	icon_state = "clock_mod"
