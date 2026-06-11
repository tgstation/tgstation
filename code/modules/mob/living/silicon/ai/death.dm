/mob/living/silicon/ai/death(gibbed, drop_mmi = TRUE)
	if(stat == DEAD)
		return

	if(!gibbed)
		INVOKE_ASYNC(src, PROC_REF(emote), "dead")

	if(!isnull(deployed_shell))
		disconnect_shell()

	. = ..()

	cut_overlays()

	var/base = display_icon_override || "ai"
	var/dead_state = "[base]_dead"
	var/screen_state
	var/lights_state = "lights_dead"

	if(icon_exists(icon, dead_state))
		screen_state = dead_state
	else
		screen_state = "ai_dead"

	if(!icon_exists(icon, lights_state))
		lights_state = "lights_active"

	set_light(0.2, 0.2, LIGHT_COLOR_FAINT_CYAN)

	if(icon_exists(icon, lights_state))
		var/mutable_appearance/lights_overlay = mutable_appearance(icon, lights_state)
		lights_overlay.layer = FLOAT_LAYER
		lights_overlay.appearance_flags = RESET_COLOR | KEEP_APART
		add_overlay(lights_overlay)

		add_overlay(emissive_appearance(icon, lights_state, src))

	if(icon_exists(icon, screen_state))
		var/mutable_appearance/screen_overlay = mutable_appearance(icon, screen_state)
		screen_overlay.layer = FLOAT_LAYER + 0.1
		screen_overlay.appearance_flags = RESET_COLOR | KEEP_APART
		add_overlay(screen_overlay)

		add_overlay(emissive_appearance(icon, screen_state, src))

	if(is_anchored)
		flip_anchored()

	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
		set_eyeobj_visible(FALSE)

	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()

	ShutOffDoomsdayDevice()

	if(gibbed && drop_mmi)
		var/obj/item/mmi/loose_cpu = make_mmi(get_turf(src))
		mind?.transfer_to(loose_cpu.brainmob)

	if(explodes_on_death)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), loc, 3, 6, 12, null, 15), 1 SECONDS)

	SSblackbox.ReportDeath(src)

/mob/living/silicon/ai/proc/ShutOffDoomsdayDevice()
	nuking = FALSE
	QDEL_NULL(doomsday_device)
