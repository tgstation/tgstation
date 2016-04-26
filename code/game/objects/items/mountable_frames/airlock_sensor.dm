/obj/item/mounted/frame/airlock_sensor
	name = "Airlock Sensor frame"
	desc = "Used for repairing or building airlock sensors"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	flags = FPRINT
	mount_reqs = list("simfloor")

/obj/item/mounted/frame/airlock_sensor/do_build(turf/on_wall, mob/user)
	new /obj/machinery/airlock_sensor(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)
