// Copypasta from APC HULL

/obj/item/mounted/frame/airlock_controller
	name = "Airlock Controller frame"
	desc = "Used for repairing or building airlock controllers"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_build0"
	mount_reqs = list("simfloor")
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/mounted/frame/airlock_controller/do_build(turf/on_wall, mob/user)
	new /obj/machinery/embedded_controller(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)

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
