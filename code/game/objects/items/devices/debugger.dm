/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/debugger
	icon = 'icons/obj/hacktool.dmi'
	name = "debugger"
	desc = "Used to debug electronic equipment."
	icon_state = "hacktool-g"
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	origin_tech = "magnets=1;engineering=1"
	var/obj/machinery/telecomms/buffer // simple machine buffer for device linkage

/obj/item/device/debugger/is_used_on(obj/O, mob/user)
	if(istype(O, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = O
		if(A.emagged || A.malfhack)
			to_chat(user, "<span class='warning'>There is a software error with the device.</span>")
		else
			to_chat(user, "<span class='notice'>The device's software appears to be fine.</span>")
		return 1
	if(istype(O, /obj/machinery/door))
		var/obj/machinery/door/D = O
		if(D.operating == -1)
			to_chat(user, "<span class='warning'>There is a software error with the device.</span>")
		else
			to_chat(user, "<span class='notice'>The device's software appears to be fine.</span>")
		return 1
	else if(istype(O, /obj/machinery))
		var/obj/machinery/A = O
		if(A.emagged)
			to_chat(user, "<span class='warning'>There is a software error with the device.</span>")
		else
			to_chat(user, "<span class='notice'>The device's software appears to be fine.</span>")
		return 1