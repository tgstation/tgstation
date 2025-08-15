/mob/living/silicon/ai/death(gibbed, drop_mmi = TRUE)
	if(stat == DEAD)
		return

	if(!gibbed)
		// Will update all AI status displays with a blue screen of death
		INVOKE_ASYNC(src, PROC_REF(emote), "bsod")

	if(!isnull(deployed_shell))
		disconnect_shell()

	. = ..()

	cut_overlays() //remove portraits
	var/base_icon = icon_state
	if(icon_exists(icon, "[base_icon]_dead"))
		icon_state = "[base_icon]_dead"
	else
		icon_state = "ai_dead"

	if(icon_exists(icon, "[base_icon]_death_transition"))
		flick("[base_icon]_death_transition", src)

	if(is_anchored)
		flip_anchored()

	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
		set_eyeobj_visible(FALSE)

	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()

	ShutOffDoomsdayDevice()

	if(gibbed && drop_mmi)
		make_mmi_drop_and_transfer()

	if(explodes_on_death)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), loc, 3, 6, 12, null, 15), 1 SECONDS)

	SSblackbox.ReportDeath(src)

/mob/living/silicon/ai/proc/ShutOffDoomsdayDevice()
	if(nuking)
		nuking = FALSE
	if(doomsday_device)
		qdel(doomsday_device)
