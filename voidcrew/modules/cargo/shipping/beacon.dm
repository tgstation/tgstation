/obj/item/supply_beacon
	name = "Supply Pod Beacon"
	desc = "A device linked to a cargo console meant to allow a user to drop pod down cargo freight."
	icon = 'icons/obj/device.dmi'
	icon_state = "supplypod_beacon"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

	///The console the beacon is linked to.
	var/obj/machinery/computer/voidcrew_cargo/cargo_console

/obj/item/supply_beacon/Destroy()
	if(cargo_console)
		cargo_console.beacon = null
	return ..()
