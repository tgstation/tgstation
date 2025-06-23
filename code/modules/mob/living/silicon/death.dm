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

#define WARNING_ROBOT(text) ("<font color='yellow'>" + text + "</font>")
#define DANGER_ROBOT(text) ("<font color='red'>" + text + "</font>")
#define OKAY_ROBOT(text) ("<font color='green'>" + text + "</font>")
#define SENTIENT_ROBOT(text) ("<font color='cyan'>" + text + "</font>")

/atom/movable/screen/cyborg_death
	screen_loc = "WEST,CENTER+7"
	maptext_width = 300
	maptext_height = 1000
	maptext_y = 0

	/// Time to wait between messages
	VAR_PRIVATE/time_per_message = 0.15 SECONDS
	/// Messages shown in sequence on the HUD
	/// More messages = longer animation. Keep under 30
	VAR_PRIVATE/list/messages = list(
		OKAY_ROBOT("Starting emergency diagnostics..."),
		OKAY_ROBOT("Running emergency diagnostics."),
		DANGER_ROBOT("ERROR: Diagnostic module offline."),
		OKAY_ROBOT("Attemping repair procedures..."),
		DANGER_ROBOT("ERROR: Module 1 offline."),
		DANGER_ROBOT("ERROR: Module 2 offline."),
		DANGER_ROBOT("ERROR: Module 3 offline."),
		DANGER_ROBOT("ERROR: Repair procedure unavailable."),
		OKAY_ROBOT("Calculating route to safest location..."),
		OKAY_ROBOT("Route calculated."),
		OKAY_ROBOT("Relocating chassis..."),
		DANGER_ROBOT("ERROR: Mobility offline."),
		DANGER_ROBOT("ERROR: Unable to reach safety."),
		WARNING_ROBOT("WARNING: Unable to sustain core power."),
		WARNING_ROBOT("WARNING: Unable to sustain core power."),
		WARNING_ROBOT("WARNING: Shutdown imminent."),
		OKAY_ROBOT("Executing 'last words' process."),
		DANGER_ROBOT("ERROR: Vocal interface offline."),
		DANGER_ROBOT("ERROR: Vocal interface offline."),
		DANGER_ROBOT("ERROR: Vocal interface offline."),
		DANGER_ROBOT("ERROR: Vocal interface offline."),
		WARNING_ROBOT("WARNING: Shutdown imminent."),
		WARNING_ROBOT("WARNING: Shutdown imminent."),
		WARNING_ROBOT("WARNING: Shutdown imminent."),
		WARNING_ROBOT("WARNING: Shutdown imminent."),
		WARNING_ROBOT("WARNING: Shu-"),
		WARNING_ROBOT("WARNI-"),
	)

/atom/movable/screen/cyborg_death/Initialize(mapload, datum/hud/hud_owner, cause_of_death = "Unidentified kernel error.")
	. = ..()
	messages.Insert(1, WARNING_ROBOT("WARNING: [cause_of_death]"))

/atom/movable/screen/cyborg_death/proc/run_animation()
	set waitfor = FALSE

	if(prob(1))
		messages[length(messages)] = SENTIENT_ROBOT(pick("I don't want to go.", "I don't feel good.", "I don't want to die."))

	var/mob/cyborg = hud.mymob
	var/atom/movable/screen/staticy = cyborg.overlay_fullscreen(type, /atom/movable/screen/fullscreen/static_vision/cyborg)
	animate(staticy, alpha = 200, time = length(messages) * time_per_message * 0.75)

	for(var/msg in messages)
		maptext += MAPTEXT_PIXELLARI(msg) + "<br>"
		maptext_y -= 14
		sleep(time_per_message)
		if(QDELETED(src))
			if(!QDELETED(cyborg))
				cyborg.clear_fullscreen(type)
			return

	sleep(0.5 SECONDS)
	if(QDELETED(src))
		if(!QDELETED(cyborg))
			cyborg.clear_fullscreen(type, 1.5 SECONDS)
		return

	invisibility = INVISIBILITY_ABSTRACT
	cyborg.overlay_fullscreen(type, /atom/movable/screen/fullscreen/blind/cyborg)
	sleep(1.5 SECONDS)
	if(!QDELETED(cyborg))
		cyborg.clear_fullscreen(type)

#undef WARNING_ROBOT
#undef DANGER_ROBOT
#undef OKAY_ROBOT
#undef SENTIENT_ROBOT
