// APC HULL

/obj/item/apc_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		var/obj/item/weapon/sheet/metal/M = new /obj/item/weapon/sheet/metal( src.loc )
		M.amount = 2
		del(src)

/obj/item/apc_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf_loc(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red APC cannot be placed on this spot."
		return
	for(var/area/RA in A.related)
		for(var/obj/machinery/power/apc/FINDME in RA)
			usr << "\red This area already has APC."
			return //only one APC per area
	if (A.requires_power == 0)
		usr << "\red APC cannot be placed in this area."
		return
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			usr << "\red There is another network terminal here."
			return
		else
			var/obj/item/weapon/cable_coil/C = new /obj/item/weapon/cable_coil(loc)
			C.amount = 10
			usr << "You cut cables and disassemble the unused power terminal."
			del(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	del(src)
