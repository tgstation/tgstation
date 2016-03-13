/obj/item/mounted/frame/driver_button
	name = "mass driver button frame"
	desc = "Used for repairing or building mass driver buttons."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt_frame"
	flags = FPRINT
	mount_reqs = list("simfloor")

/obj/item/mounted/frame/driver_button/do_build(turf/on_wall, mob/user)
	new /obj/machinery/driver_button(get_turf(user), get_dir(user, on_wall))
	qdel(src)

/obj/item/mounted/frame/driver_button/signaler_button
	name = "signaler button frame"
	desc = "Used for building signaler buttons."
	var/code = 30
	var/frequency = 1457

/obj/item/mounted/frame/driver_button/signaler_button/do_build(turf/on_wall, mob/user)
	var/obj/item/device/assembly/signaler/signaler_button/I = new (get_turf(user), get_dir(user, on_wall))
	I.code = src.code
	I.frequency = src.frequency
	qdel(src)

/obj/item/mounted/frame/driver_button/signaler_button/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		new /obj/item/stack/sheet/metal(get_turf(src.loc))
		var/obj/item/device/assembly/signaler/I = new (get_turf(src.loc))
		I.code = src.code
		I.frequency = src.frequency
		qdel(src)
