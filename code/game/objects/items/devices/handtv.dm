/obj/item/device/handtv
	name = "handheld tv"
	desc = "A handheld tv meant for remote viewing."
	icon_state = "handtv"
	w_class = 1
	var/obj/machinery/camera/current = null

/obj/item/device/handtv/attack_self(mob/usr as mob)
	var/list/cameras = new/list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		if (C.hasbug && C.status)
			cameras.Add(C)
	if (length(cameras) == 0)
		usr << "\red No bugged functioning cameras found."
		return

	var/list/friendly_cameras = new/list()

	for (var/obj/machinery/camera/C in cameras)
		friendly_cameras.Add(C.c_tag)

	var/target = input("Select the camera to observe", null) as null|anything in friendly_cameras
	if (!target)
		usr.unset_machine()
		usr.reset_view(usr)
		return
	for (var/obj/machinery/camera/C in cameras)
		if (C.c_tag == target)
			target = C
			break
	if (usr.stat == 2) return
	if(target)
		usr.client.eye = target
		usr.set_machine(src)
		src.current = target
	else
		usr.unset_machine()
		return

/obj/item/device/handtv/check_eye(var/mob/usr as mob)
	if ( src.loc != usr || usr.get_active_hand() != src|| !usr.canmove || usr.blinded || !current || !current.status )
		return null
	usr.reset_view(current)
	return 1