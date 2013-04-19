// APC HULL

/obj/item/part/frame/apc
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/part/frame/apc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/part/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)

/obj/item/part/frame/apc/proc/try_build(turf/on_wall)
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
	if (A.requires_power == 0 || A.name == "Space")
		usr << "\red APC cannot be placed in this area."
		return
	if (A.get_apc())
		usr << "\red This area already has APC."
		return //only one APC per area
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			usr << "\red There is another network terminal here."
			return
		else
			var/obj/item/part/cable_coil/C = new /obj/item/part/cable_coil(loc)
			C.amount = 10
			usr << "You cut the cables and disassemble the unused power terminal."
			del(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	del(src)
