/datum/traitor_objective/ultimate/dark_matteor
	name = "Summon a dark matter singularity to consume the station."
	description = "Go to %AREA%, and receive the smuggled satellites + emag. Set up and emag the satellites, \
	after enough have been recalibrated by the emag, IT COMES. Warning: The dark matter singularity will hunt all creatures, you included."

	//this is a prototype so this progression is for all basic level kill objectives

	///area type the objective owner must be in to receive the satellites
	var/area/satellites_spawnarea_type
	///checker on whether we have sent the satellites yet.
	var/sent_satellites = FALSE

/datum/traitor_objective/ultimate/dark_matteor/can_generate_objective(generating_for, list/possible_duplicates)
	. = ..()
	if(!.)
		return FALSE
	if(SSmapping.is_planetary())
		return FALSE //meteors can't spawn on planets
	return TRUE

/datum/traitor_objective/ultimate/dark_matteor/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(!ispath(possible_area, /area/station/maintenance/solars) && !ispath(possible_area, /area/station/solars))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	satellites_spawnarea_type = pick(possible_areas)
	replace_in_name("%AREA%", initial(satellites_spawnarea_type.name))
	return TRUE

/datum/traitor_objective/ultimate/dark_matteor/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_satellites)
		buttons += add_ui_button("", "Pressing this will call down a pod with the smuggled satellites.", "satellite", "satellite")
	return buttons

/datum/traitor_objective/ultimate/dark_matteor/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("satellite")
			if(sent_satellites)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != satellites_spawnarea_type)
				to_chat(user, span_warning("You must be in [initial(satellites_spawnarea_type.name)] to receive the smuggled satellites."))
				return
			sent_satellites = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = /datum/pod_style/syndicate,
				"spawn" = /obj/structure/closet/crate/engineering/smuggled_meteor_shields,
			))

/obj/structure/closet/crate/engineering/smuggled_meteor_shields

/obj/structure/closet/crate/engineering/smuggled_meteor_shields/PopulateContents()
	..()
	for(var/i in 1 to 11)
		new /obj/machinery/satellite/meteor_shield(src)
	new /obj/item/card/emag/meteor_shield_recalibrator(src)
	new /obj/item/paper/dark_matteor_summoning(src)

/obj/item/paper/dark_matteor_summoning
	name = "notes - dark matter meteor summoning"
	default_raw_text = {"
		Summoning a dark matter meteor.<br>
		<br>
		<br>
		Operative, this crate contains 10+1 spare meteor shield satellites stolen from NT’s supply lines. Your mission is to
		deploy them in space near the station and recalibrate them with the provided emag. Be careful: you need a 30 second
		cooldown between each hack, and NT will detect your interference after seven recalibrations. That means you
		have at least 5 minutes of work and 1 minute of resistance.<br>
		<br>
		This is a high-risk operation. You’ll need backup, fortification, and determination. The reward?
		A spectacular dark matter singularity that will wipe out the station.<br>
		<br>
		<b>**Death to Nanotrasen.**</b>
"}

/obj/item/card/emag/meteor_shield_recalibrator
	name = "cryptographic satellite recalibrator"
	desc = "It's a cryptographic sequencer that has been tuned to recalibrate meteor shields quicker and with less risk of frying them."
