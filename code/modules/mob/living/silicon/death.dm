/mob/living/silicon/spawn_gibs()
	new /obj/effect/gibspawner/robot(drop_location(), src)

/mob/living/silicon/spawn_dust(just_ash)
	if(just_ash)
		return ..()

	var/obj/effect/decal/remains/robot/robones = new(loc)
	robones.pixel_z = -6
	robones.pixel_w = rand(-1, 1)

/mob/living/silicon/set_stat(new_stat)
	. = ..()
	if(. != DEAD)
		return
	// Clean up hud element used for the death sequence
	for(var/atom/movable/screen/cyborg_death/deathhud in hud_used?.always_visible_inventory)
		hud_used.always_visible_inventory -= deathhud
		qdel(deathhud)

/mob/living/silicon/death(gibbed)
	diag_hud_set_status()
	diag_hud_set_health()
	update_health_hud()
	. = ..()
	// Runs an animation on the player's HUD
	if(!gibbed && hud_used)
		death_sequence()

/mob/living/silicon/get_visible_suicide_message()
	return "[src] is powering down. It looks like [p_theyre()] trying to commit suicide."

/mob/living/silicon/get_blind_suicide_message()
	return "You hear a long, hissing electronic whine."

/// Plays an animation of the player's hud flavored about their death somewhat
/mob/living/silicon/proc/death_sequence()
	var/cause_of_death
	if(getBruteLoss() + getFireLoss() > 100)
		cause_of_death = "Critical damage sustained."
	if(getOxyLoss() > 100)
		cause_of_death = "Critically low power."

	var/atom/movable/screen/cyborg_death/deathhud = new(null, hud_used, cause_of_death)
	hud_used.always_visible_inventory += deathhud
	hud_used.show_hud(hud_used.hud_version)
	deathhud.run_animation()

/atom/movable/screen/cyborg_death
	screen_loc = "WEST,CENTER+7"
	maptext_width = 300
	maptext_height = 1000
	maptext_y = 0

	var/list/messages = list(
		"Running emergency diagnostics...",
		"Running emergency diagnostics...",
		"ERROR: Diagnostic module offline.",
		"Attemping repair procedures...",
		"ERROR: Module 1 offline.",
		"ERROR: Module 2 offline.",
		"ERROR: Module 3 offline.",
		"ERROR: Repair procedure unavailable.",
		"Calculating route to safest location...",
		"Route calculated.",
		"Relocating chassis...",
		"ERROR: Mobility offline.",
		"WARNING: Unable to sustain core power.",
		"WARNING: Unable to sustain core power.",
		"WARNING: Shutdown imminent.",
		"Executing 'last words' process.",
		"ERROR: Vocal interface offline.",
		"ERROR: Vocal interface offline.",
		"ERROR: Vocal interface offline.",
		"ERROR: Vocal interface offline.",
		"WARNING: Shutdown imminent.",
		"WARNING: Shutdown imminent.",
		"WARNING: Shutdown imminent.",
		"WARNING: Shutdown imminent.",
		"WARNING: Shutdown imminent.",
		"WARNING: Shu-",
		"WARNI-",
	)

/atom/movable/screen/cyborg_death/Initialize(mapload, datum/hud/hud_owner, cause_of_death = "Unknown malfunction.")
	. = ..()
	messages.Insert(1, "WARNING: [cause_of_death]")

/atom/movable/screen/cyborg_death/proc/run_animation()
	set waitfor = FALSE

	if(prob(1))
		messages[length(messages)] = "<font color='cyan'>[pick("I don't want to go.", "I don't feel good.", "I don't want to die.")]</font>"

	var/mob/cyborg = hud.mymob
	var/atom/movable/screen/staticy = cyborg.overlay_fullscreen(type, /atom/movable/screen/fullscreen/static_vision/cyborg)
	animate(staticy, alpha = 200, time = length(messages) * 0.15 SECONDS)

	for(var/msg in messages)
		var/wait = 0.2 SECONDS
		var/msg_formatted = MAPTEXT_PIXELLARI(msg)
		if(findtext(msg, "ERROR"))
			msg_formatted = "<font color='red'>[msg_formatted]</font>"
		else if(findtext(msg, "WARN"))
			msg_formatted = "<font color='yellow'>[msg_formatted]</font>"
		else if(!findtext(msg, "font"))
			msg_formatted = "<font color='green'>[msg_formatted]</font>"
			wait *= 2
		msg_formatted += "<br>"
		maptext += msg_formatted
		maptext_y -= 14
		sleep(wait)
		if(QDELETED(src))
			if(!QDELETED(cyborg))
				cyborg.clear_fullscreen(type)
			return

	sleep(1 SECONDS)
	if(!QDELETED(src))
		animate(src, alpha = 0, time = 2 SECONDS)
	if(!QDELETED(cyborg))
		cyborg.clear_fullscreen(type)
