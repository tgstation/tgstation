// APC HULL

/obj/item/switch_frame
	name = "switch frame"
	desc = "Used for building a switch"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl-open"
	var/create = /obj/machinery/door_control
	flags = FPRINT | TABLEPASS| CONDUCT
	var/create_name

	attackby(obj/item/weapon/W, mob/user)
		if(..(user))
			return
		src.add_fingerprint(usr)

		if(istype(W, /obj/item/weapon/pen))
			var/t = copytext(stripped_input(user, "Enter a name", src.name, src.name),1,MAX_NAME_LEN)
			if(!t)	return
			if(!in_range(src, usr) && src.loc != usr)	return
			create_name = t
			return

/obj/item/switch_frame/crema
	name = "crematorium switch frame"
	desc = "Used for building a switch"
	create = /obj/machinery/crema_switch

/obj/item/switch_frame/light
	name = "lightswitch frame"
	desc = "Used for building a lightswitch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light-open"
	create = /obj/machinery/light_switch

/obj/item/switch_frame/airlock_console
	icon = 'icons/obj/airlock_console.dmi'
	icon_state = "airlock_control_1"
	name = "airlock console frame"
	desc = "Used for building an airlock console"
	create = /obj/machinery/airlock_console

/obj/item/switch_frame/extinguisher
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_empty"
	name = "fire extinguisher cabinet frame"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	create = /obj/structure/extinguisher_cabinet/created

/obj/item/switch_frame/airlock_sensor
	icon = 'icons/obj/airlock_console.dmi'
	icon_state = "airlock_sensor_open"
	name = "airlock sensor frame"
	desc = "Used for building an airlock sensor"
	create = /obj/machinery/airlock_sensor_wired

	attackby(obj/item/weapon/W, mob/user)
		if(..(user))
			return
		src.add_fingerprint(usr)

		if(istype(W, /obj/item/weapon/pen))
			var/t = copytext(stripped_input(user, "Enter the name for the sensor", src.name, src.name),1,MAX_NAME_LEN)
			if(!t)	return
			if(!in_range(src, usr) && src.loc != usr)	return
			create_name = t
			return

/obj/item/switch_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wirecutters))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 1 )
		del(src)

/obj/item/switch_frame/proc/try_build(turf/on_wall)
	var/new_name = src.create_name
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	//var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		usr << "\red Switch cannot be placed on this spot."
		return
	//if (A.name == "Space")
	//	usr << "\red Switch cannot be placed in this area."
	//	return
	var/obj/machinery/new_obj = new create(loc, ndir, 1)
	if(new_name)
		new_obj.name = new_name
	new_obj.anchored = 1
	del(src)
