// APC HULL

/obj/item/requests_console_frame
	name = "requests console frame"
	desc = "Used for building a request console"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp_frame"
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/requests_console_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wirecutters))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 1 )
		del(src)

/obj/item/requests_console_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	//var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red Console cannot be placed on this spot."
		return
	new /obj/machinery/requests_console(loc, ndir, 1)
	del(src)
