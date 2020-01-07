#define SEC_BODY_CAM_SOUND list('sound/machines/beep.ogg')
#define SEC_BODY_CAM_SOUND_DENY list('sound/machines/buzz-two.ogg')
#define SEC_BODY_CAM_REG_DELAY 1 SECONDS
#define SEC_BODY_CAM_COOLDOWN 2 SECONDS

/obj/item/clothing/under/rank/security/Initialize()
	. = ..()
	builtInCamera = new (src)
	builtInCamera.internal_light = FALSE

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/auto_register_bodycam)

	addtimer(CALLBACK(src, /obj/item/clothing/under/rank/security.proc/auto_register_bodycam, null, ITEM_SLOT_ICLOTHING), SEC_BODY_CAM_REG_DELAY)

/obj/item/clothing/under/rank/security/proc/auto_register_bodycam(mob/user, slot)
	if(!builtInCamera)
		return
	if(slot != ITEM_SLOT_ICLOTHING)
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
		register_body_camera(I, user)

/obj/item/clothing/under/rank/security/attackby(obj/item/W, mob/user, params)
	. = ..()
	var/obj/item/card/id/I
	if (istype(W, /obj/item/card/id))
		I = W
	else if (istype(W, /obj/item/pda))
		var/obj/item/pda/P = W
		I = P.id

	if(!I)
		to_chat(user, "<span class='warning'>No ID detected for body camera registration.</span>")
		return

	if(!builtInCamera)
		to_chat(user, "<span class='warning'>No body camera detected for registration.</span>")
		return

	if(check_access(I))
		register_body_camera(I, user)
	else
		to_chat(user, "<span class='warning'>ID is not authorized for registration with this uniform's body camera.</span>")
		camera_sound(FALSE)

/obj/item/clothing/under/rank/security/proc/register_body_camera(obj/item/card/id/I, mob/user)
	if(!I) //Sanity check
		return
	var/id_name = I.registered_name
	if(id_name == registrant) //If already registered to the same person swiping the ID, we will 'toggle off' registration and unregister the body camera.
		unregister_body_camera(I, user)
		return

	registrant = id_name
	builtInCamera.network = list("sec_bodycameras")
	var/cam_name = "-Body Camera: [id_name] ([I.assignment])"
	for(var/obj/machinery/camera/matching_camera in GLOB.cameranet.cameras)
		if(cam_name == matching_camera.c_tag)
			to_chat(user, "<span class='notice'>Matching registration found. Unregistering previously registered body camera.</span>")
			var/obj/item/clothing/under/rank/security/S = matching_camera.loc
			if(S)
				S.unregister_body_camera(I, user, FALSE)
			break

	builtInCamera.c_tag = "[cam_name]"

	camera_sound()
	if(user)
		to_chat(user, "<span class='notice'>Security uniform body camera successfully registered to [id_name]</span>")


/obj/item/clothing/under/rank/security/proc/unregister_body_camera(obj/item/card/id/I, mob/user, message=TRUE)
	builtInCamera.network = list()
	builtInCamera.c_tag = null
	registrant = null
	if(user && message)
		camera_sound()
		to_chat(user, "<span class='notice'>Security uniform body camera successfully unregistered from [I.registered_name]</span>")



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

/obj/item/clothing/under/rank/security/proc/camera_sound(accepted = TRUE)
	if(world.time - sound_time_stamp > SEC_BODY_CAM_COOLDOWN)
		if(accepted)
			playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)
		else
			playsound(loc, SEC_BODY_CAM_SOUND_DENY, get_clamped_volume(), TRUE, -1)
		sound_time_stamp = world.time

/obj/item/clothing/under/rank/security/emp_act()
	. = ..()
	camera_toggle()


/obj/item/clothing/under/rank/security/examine(mob/user)
	. = ..()
	if(builtInCamera)
		if(camera_on)
			. += "Its body camera appears to be <b>active</b>."
		else
			. += "Its body camera appears to be <b>inactive</b>."
		if(registrant)
			. += "The body camera is registered to <b>[registrant]</b>."

/obj/machinery/computer/security/proc/check_bodycamera_unlock(user)
	if(allowed(user))
		network += "sec_bodycameras" //We can tap into the body camera network with appropriate access
	else
		network -= "sec_bodycameras"

