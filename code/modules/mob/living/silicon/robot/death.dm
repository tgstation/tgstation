
/mob/living/silicon/robot/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-r")

/mob/living/silicon/robot/dust(just_ash, drop_items, force)
	// You do not get MMI'd if you are dusted
	QDEL_NULL(mmi)
	return ..()

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)
		return
	if(gibbed)
		dump_into_mmi()
	else
		logevent("FATAL -- SYSTEM HALT")
		modularInterface.shutdown_computer()
		eye_flash_timer = addtimer(CALLBACK(src, PROC_REF(flash_headlamp)), 2 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)
	. = ..()

	locked = FALSE //unlock cover

	if(!QDELETED(builtInCamera) && builtInCamera.camera_enabled)
		builtInCamera.toggle_cam(src,0)

	toggle_headlamp(TRUE) //So borg lights are disabled when killed.
	drop_all_held_items() // particularly to ensure sight modes are cleared
	update_icons()
	unbuckle_all_mobs(TRUE)
	SSblackbox.ReportDeath(src)

/mob/living/silicon/robot/proc/flash_headlamp()
	if(eye_lights)
		eye_lights = null
		regenerate_icons()
		return

	eye_lights = new()
	eye_lights.icon_state = "[model.special_light_key ? "[model.special_light_key]":"[model.cyborg_base_icon]"]_e_r"
	eye_lights.color = COLOR_WHITE
	SET_PLANE_EXPLICIT(eye_lights, ABOVE_GAME_PLANE, src)
	eye_lights.icon = icon
	regenerate_icons()
	add_overlay(eye_lights)
