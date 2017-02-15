/obj/item/weapon/computer_hardware/recharger
	critical = 1
	enabled = 1
	var/charge_rate = 100
	device_type = MC_CHARGE

/obj/item/weapon/computer_hardware/recharger/proc/use_power(amount, charging=0)
	if(charging)
		return 1
	return 0

/obj/item/weapon/computer_hardware/recharger/process()
	..()
	var/obj/item/weapon/computer_hardware/battery/battery_module = holder.all_components[MC_CELL]
	if(!holder || !battery_module || !battery_module.battery)
		return

	var/obj/item/weapon/stock_parts/cell/cell = battery_module.battery
	if(cell.charge >= cell.maxcharge)
		return

	if(use_power(charge_rate, charging=1))
		holder.give_power(charge_rate * CELLRATE)


/obj/item/weapon/computer_hardware/recharger/APC
	name = "area power connector"
	desc = "A device that wirelessly recharges connected device from nearby APC."
	icon_state = "charger_APC"
	w_class = WEIGHT_CLASS_SMALL // Can't be installed into tablets/PDAs
	origin_tech = "programming=2;engineering=2;powerstorage=3"

/obj/item/weapon/computer_hardware/recharger/APC/use_power(amount, charging=0)
	if(istype(holder.physical, /obj/machinery))
		var/obj/machinery/M = holder.physical
		if(M.powered())
			M.use_power(amount)
			return 1

	else
		var/area/A = get_area(src)
		if(!A || !isarea(A) || !A.master)
			return 0

		if(A.master.powered(EQUIP))
			A.master.use_power(amount, EQUIP)
			return 1
	return 0

/obj/item/weapon/computer_hardware/recharger/wired
	name = "wired power connector"
	desc = "A power connector that recharges connected device from nearby power wire. Incompatible with portable computers."
	icon_state = "charger_wire"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "engineering=2;powerstorage=1"

/obj/item/weapon/computer_hardware/recharger/wired/can_install(obj/item/device/modular_computer/M, mob/living/user = null)
	if(istype(M.physical, /obj/machinery) && M.physical.anchored)
		return ..()
	to_chat(user, "<span class='warning'>\The [src] is incompatible with portable computers!</span>")
	return 0

/obj/item/weapon/computer_hardware/recharger/wired/use_power(amount, charging=0)
	if(istype(holder.physical, /obj/machinery) && holder.physical.anchored)
		var/obj/machinery/M = holder.physical
		var/turf/T = M.loc
		if(!T || !istype(T))
			return 0

		var/obj/structure/cable/C = T.get_cable_node()
		if(!C || !C.powernet)
			return 0

		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net > amount)
			C.powernet.load += amount
			return 1

	return 0



// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/weapon/computer_hardware/recharger/lambda
	name = "lambda coil"
	desc = "A very complex device that draws power from its own bluespace dimension."
	icon_state = "charger_lambda"
	w_class = WEIGHT_CLASS_TINY
	charge_rate = 100000

/obj/item/weapon/computer_hardware/recharger/lambda/use_power(amount, charging=0)
	return 1
