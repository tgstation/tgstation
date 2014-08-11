// Copypasta from APC HULL

/obj/item/airlock_controller_frame
	name = "Airlock Controller frame"
	desc = "Used for repairing or building airlock controllers"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_build0"
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/airlock_controller_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		del(src)

/obj/item/airlock_controller_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red APC cannot be placed on this spot."
		return
	new /obj/machinery/embedded_controller(loc, ndir, 1)
	del(src)

/////////////////////////////////////////////////////////////
// Embedded Controller Boards
/////////////////////////////////////////////////////////////

/obj/item/weapon/circuitboard/ecb
	board_type="embedded controller"
	icon_state = "mainboard"
	origin_tech = "programming=3"

	name = "Embedded Controller Board (Base)"
	build_path = /obj/machinery/embedded_controller

/obj/item/weapon/circuitboard/ecb/access_controller
	name = "Embedded Controller Board (Access Control)"
	build_path = /obj/machinery/embedded_controller/radio/access_controller
/obj/item/weapon/circuitboard/ecb/airlock_controller
	name = "Embedded Controller Board (Airlock Control)"
	build_path = /obj/machinery/embedded_controller/radio/airlock_controller
/obj/item/weapon/circuitboard/ecb/advanced_airlock_controller
	name = "Embedded Controller Board (Advanced)"
	build_path = /obj/machinery/embedded_controller/radio/advanced_airlock_controller