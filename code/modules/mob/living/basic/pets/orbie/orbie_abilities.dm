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
	var/obj/item/camera/ability_camera

/datum/action/cooldown/mob_cooldown/capture_photo/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	ability_camera = new(owner)
	ability_camera.print_picture_on_snap = FALSE
	RegisterSignal(ability_camera, COMSIG_PREQDELETED, PROC_REF(on_camera_delete))

/datum/action/cooldown/mob_cooldown/capture_photo/Activate(atom/target)
	if(isnull(ability_camera))
		return FALSE
	ability_camera.captureimage(target, owner)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/capture_photo/proc/on_camera_delete(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(ability_camera, COMSIG_PREQDELETED)
	ability_camera = null

/datum/action/cooldown/mob_cooldown/capture_photo/Destroy()
	QDEL_NULL(ability_camera)
	return ..()
