/obj/item/weapon/computer_hardware/recharger
	critical = 1
	enabled = 1
	var/charge_rate = 100

/obj/item/weapon/computer_hardware/recharger/proc/use_power(amount, charging=0)
	if(charging)
		return 1
	return 0

/obj/item/weapon/computer_hardware/recharger/process()
	..()
	if(!holder || !holder.battery_module || !holder.battery_module.battery)
		return

	var/obj/item/weapon/stock_parts/cell/cell = holder.battery_module.battery
	if(cell.charge >= cell.maxcharge)
		return

	if(use_power(charge_rate, charging=1))
		holder.give_power(charge_rate * CELLRATE)


/obj/item/weapon/computer_hardware/recharger/APC
	name = "area power connector"
	desc = "A device that wirelessly recharges connected device from nearby APC."
	icon_state = "power_mod"
	w_class = 2 // Can't be installed into tablets/PDAs
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


// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/weapon/computer_hardware/recharger/lambda
	name = "lambda coil"
	desc = "A very complex device that draws power from it's own bluespace dimension."
	icon_state = "charger_lambda"
	w_class = 1
	charge_rate = 100000

/obj/item/weapon/computer_hardware/recharger/lambda/use_power(amount, charging=0)
	return 1
