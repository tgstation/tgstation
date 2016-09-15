/obj/item/weapon/computer_hardware/transponder
	name = "RFID transponder"
	desc = "Portable module allowing the device to interact with IDs at close range."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	device_type = "RFID"

	w_class = 1	// w_class limits which devices can contain this component.
	// 1: PDAs/Tablets, 2: Laptops, 3-4: Consoles only

	power_usage = 0 			//Passive by default

/obj/item/weapon/computer_hardware/transponder/proc/get_access()