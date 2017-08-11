//File with the circuitboard and circuitboard/machine class definitions and procs


// Circuitboard

/obj/item/weapon/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	origin_tech = "programming=2"
	materials = list(MAT_GLASS=1000)
	w_class = WEIGHT_CLASS_SMALL
	var/build_path = null

/obj/item/weapon/circuitboard/proc/apply_default_parts(obj/machinery/M)
	return

// Circuitboard/machine
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/weapon/circuitboard/machine
	var/list/req_components // Components required by the machine.
							// Example: list(/obj/item/weapon/stock_parts/matter_bin = 5)

	var/list/def_components // Default replacements for req_components, to be used in apply_default_parts instead of req_components types
							// Example: list(/obj/item/weapon/stock_parts/matter_bin = /obj/item/weapon/stock_parts/matter_bin/super)

// Applies the default parts defined by the circuit board when the machine is created
/obj/item/weapon/circuitboard/machine/apply_default_parts(obj/machinery/M)
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