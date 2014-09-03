// APC HULL

/obj/item/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_type=RECYK_METAL

/obj/item/apc_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)

/obj/item/apc_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red APC cannot be placed on this spot."
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "\red APC cannot be placed in this area."
		return
	if (A.get_apc())
		usr << "\red This area already has an APC."
		return //only one APC per area
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			usr << "\red There is another network terminal here."
			return
		else
			var/obj/item/weapon/cable_coil/C = new /obj/item/weapon/cable_coil(loc)
			C.amount = 10
			usr << "You cut the cables and disassemble the unused power terminal."
			del(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	del(src)

///////////////
// TY OSAIFH
///////////////


/obj/item/intercom_frame
	name = "Intercom frame"
	desc = "Used for repairing or building intercoms"
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom_frame"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_type=RECYK_METAL

/obj/item/intercom_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)

/obj/item/intercom_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red Intercom cannot be placed on this spot."
		return
	if (A.requires_power == 0 || A.name == "Space")
		usr << "\red Air Alarm cannot be placed in this area."
		return

	if(gotwallitem(loc, ndir))
		usr << "\red There's already an item on this wall!"
		return
	new /obj/item/device/radio/intercom(loc, ndir, 1)
	del(src)