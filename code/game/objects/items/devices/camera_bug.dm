/obj/item/device/camera_bug
	name = "camera bug"
	icon = 'icons/obj/device.dmi'
	icon_state = "mindflash2"
	w_class = 1.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	var/obj/machinery/camera/current

/obj/item/device/camera_bug/attack_self(mob/user as mob)
	var/list/friendly_cameras = new/list()
	var/turf/T = get_turf(loc)
	for (var/obj/machinery/camera/C in cameranet.cameras)
		if (C.bugged && C.status && C.z == T.z)
			friendly_cameras[C.c_tag] = C
	if (friendly_cameras.len == 0)
		user << "\red No bugged functioning cameras found."
		return

	var/target = "Cancel"
	while(target)
		target = input("Select the camera to observe", "Cancel") as null|anything in friendly_cameras + "Cancel"
		var/obj/machinery/camera/C = friendly_cameras[target]
		if ( !C || loc != user || user.stat || user.blinded || !user.canmove )
			user.unset_machine()
			user.reset_view(null)
			return

		T = get_turf(loc)
		if(T.z != C.z)
			user << "\red You've lost the signal."
			current = null
			user.reset_view(null)
			attack_self(user)
			return

		if( !C.can_use() )
			user << "\red Something's wrong with that camera.  You can't get a feed."
		else

			current = C
			user.set_machine(src)
			user.reset_view(C)


/obj/item/device/camera_bug/check_eye(var/mob/user as mob)
	if (user.stat || loc != user || !user.canmove || user.blinded || !current || !current.can_use())
		return null
	return 1