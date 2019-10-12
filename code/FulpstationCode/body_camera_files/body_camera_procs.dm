#define SEC_BODY_CAM_SOUND list('sound/machines/beep.ogg')

/obj/item/clothing/under/rank/security/Initialize()
	. = ..()
	builtInCamera = new (src)
	builtInCamera.network = list("sec_bodycameras")
	builtInCamera.internal_light = FALSE

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/auto_register_bodycam)


/obj/item/clothing/under/rank/security/proc/auto_register_bodycam(datum/source, mob/user, slot)
	if(!builtInCamera)
		return
	if(slot != SLOT_W_UNIFORM)
		return
	if(!user)
		if(ismob(loc))
			user = loc
		else
			return
	var/obj/item/card/id/I = user.get_idcard(TRUE)
	if(!istype(I))
		return
	if(check_access(I))
		var/id_name = I.registered_name
		builtInCamera.c_tag = "*Body Camera: [I.assignment] [id_name]"
		camera_sound()
		to_chat(user, "<span class='notice'>Security uniform body camera automatically registered to [id_name]</span>")

/obj/item/clothing/under/rank/security/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(!builtInCamera)
		to_chat(user, "<span class='warning'>No body camera detected.</span>")
		return

	var/obj/item/card/id/I
	if (istype(W, /obj/item/card/id))
		I = W
	else if (istype(W, /obj/item/pda))
		var/obj/item/pda/P = W
		I = P.id

	if(!I)
		to_chat(user, "<span class='warning'>No ID detected for body camera registration.</span>")
		return

	if(check_access(I))
		var/id_name = I.registered_name
		builtInCamera.c_tag = "-Body Camera: [id_name] ([I.assignment])"
		camera_sound()
		to_chat(user, "<span class='notice'>Security uniform body camera manually registered with ID to [id_name]</span>")
	else
		to_chat(user, "<span class='warning'>ID is not authorized for registration with this uniform's body camera.</span>")

/obj/item/clothing/under/rank/security/verb/toggle_camera()
	set name = "Toggle Body Camera"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	camera_toggle(usr)


/obj/item/clothing/under/rank/security/proc/camera_toggle()
	var/message = "<span class='notice'>There's no camera!</span>"

	if(builtInCamera)
		if(camera_on)
			camera_on = FALSE
			builtInCamera.status = 0
			message = "<span class='notice'>You toggle the body camera off.</span>"
		else
			camera_on = TRUE
			builtInCamera.status = 1
			message = "<span class='notice'>You toggle the body camera on.</span>"

	if(ismob(loc))
		var/mob/user = loc
		if(user)
			camera_sound()
			to_chat(user, "[message]")

/obj/item/clothing/under/rank/security/proc/camera_sound()
	if(world.time - sound_time_stamp > 20)
		playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)
		sound_time_stamp = world.time

/obj/item/clothing/under/rank/security/emp_act()
	. = ..()
	camera_toggle()

/obj/machinery/computer/security/proc/check_bodycamera_unlock(user)
	if(allowed(user))
		network += "sec_bodycameras" //We can tap into the body camera network with appropriate access
	else
		network -= "sec_bodycameras"
