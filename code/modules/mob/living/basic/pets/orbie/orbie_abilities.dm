/datum/action/cooldown/mob_cooldown/lights
	name = "Toggle Lights"
	button_icon = 'icons/mob/simple/pets.dmi'
	button_icon_state = "orbie_light_action"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/lights/Activate()
	owner.set_light_on(!owner.light_on)
	return TRUE


/datum/action/cooldown/mob_cooldown/capture_photo
	name = "Camera"
	button_icon = 'icons/mob/simple/pets.dmi'
	button_icon_state = "orbie_light_action"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"
	cooldown_time = 30 SECONDS
	///camera we use to take photos
	var/obj/item/camera/internal_camera

/datum/action/cooldown/mob_cooldown/capture_photo/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	internal_camera = new(owner)
	internal_camera.print_picture_on_snap = FALSE
	internal_camera.cooldown = 1 SECONDS
	RegisterSignal(internal_camera, COMSIG_PREQDELETED, PROC_REF(on_camera_delete))

/datum/action/cooldown/mob_cooldown/capture_photo/Activate(atom/target)
	if(isnull(internal_camera))
		return FALSE
	INVOKE_ASYNC(internal_camera, TYPE_PROC_REF(/obj/item/camera, attempt_picture), target, owner)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/capture_photo/proc/on_camera_delete(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(internal_camera, COMSIG_PREQDELETED)
	internal_camera = null

/datum/action/cooldown/mob_cooldown/capture_photo/Destroy()
	QDEL_NULL(internal_camera)
	return ..()
