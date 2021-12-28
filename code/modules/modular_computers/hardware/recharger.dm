/obj/item/computer_hardware/recharger
	critical = 1
	enabled = 1
	var/charge_rate = 100
	device_type = MC_CHARGE

/obj/item/computer_hardware/recharger/proc/use_power(amount, charging=0)
	if(charging)
		return TRUE
	return FALSE

/obj/item/computer_hardware/recharger/process()
	..()
	var/obj/item/computer_hardware/battery/battery_module = holder.all_components[MC_CELL]
	if(!holder || !battery_module || !battery_module.battery)
		return

	var/obj/item/stock_parts/cell/cell = battery_module.battery
	if(cell.charge >= cell.maxcharge)
		return

	if(use_power(charge_rate, charging=1))
		holder.give_power(charge_rate JOULES)


/obj/item/computer_hardware/recharger/apc_recharger
	name = "area power connector"
	desc = "A device that wirelessly recharges connected device from nearby APC."
	icon_state = "charger_APC"
	atom_size = WEIGHT_CLASS_SMALL // Can't be installed into tablets/PDAs

/obj/item/computer_hardware/recharger/apc_recharger/use_power(amount, charging=0)
	if(ismachinery(holder.physical))
		var/obj/machinery/M = holder.physical
		if(M.powered())
			M.use_power(amount)
			return TRUE

	else
		var/area/A = get_area(src)
		if(!istype(A))
			return FALSE

		if(A.powered(AREA_USAGE_EQUIP))
			A.use_power(amount, AREA_USAGE_EQUIP)
			return TRUE
	return FALSE

/obj/item/computer_hardware/recharger/wired
	name = "wired power connector"
	desc = "A power connector that recharges connected device from nearby power wire. Incompatible with portable computers."
	icon_state = "charger_wire"
	atom_size = WEIGHT_CLASS_NORMAL

/obj/item/computer_hardware/recharger/wired/can_install(obj/item/modular_computer/install_into, mob/living/user = null)
	if(ismachinery(install_into.physical) && install_into.physical.anchored)
		return ..()
	to_chat(user, span_warning("\The [src] is incompatible with portable computers!"))
	return FALSE

/obj/item/computer_hardware/recharger/wired/use_power(amount, charging=0)
	if(ismachinery(holder.physical) && holder.physical.anchored)
		var/obj/machinery/M = holder.physical
		var/turf/T = M.loc
		if(!T || !istype(T))
			return FALSE

		var/obj/structure/cable/C = T.get_cable_node()
		if(!C || !C.powernet)
			return FALSE

		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net > amount)
			C.powernet.load += amount
			return TRUE
	return FALSE

/// This recharger exists only in borg built-in tablets. I would have tied it to the borg's cell but
/// the program that displays laws should always be usable, and the exceptions were starting to pile.
/obj/item/computer_hardware/recharger/cyborg
	name = "modular interface power harness"
	desc = "A standard connection to power a small computer device from a cyborg's chassis."

/obj/item/computer_hardware/recharger/cyborg/use_power(amount, charging=0)
	return TRUE


// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/computer_hardware/recharger/lambda
	name = "lambda coil"
	desc = "A very complex device that draws power from its own bluespace dimension."
	icon_state = "charger_lambda"
	atom_size = WEIGHT_CLASS_TINY
	charge_rate = 100000

/obj/item/computer_hardware/recharger/lambda/use_power(amount, charging=0)
	return 1

