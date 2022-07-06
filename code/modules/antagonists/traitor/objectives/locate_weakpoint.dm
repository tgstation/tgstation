/datum/traitor_objective_category/locate_weakpoint
	name = "Locate And Destroy Weakpoint"
	objectives = list(
		/datum/traitor_objective/locate_weakpoint = 1,
	)

/datum/traitor_objective/locate_weakpoint
	name = "Triangulate station's structural weakpoint and detonate an explosive charge nearby."
	description = "You will be given a handheld device that you'll need to use in %AREA1% and %AREA2% in order to triangulate the station's structural weakpoint and detonate an explosive charge there. Warning: Once you start scanning either one of the areas, station's AI will be alerted."

	progression_minimum = 45 MINUTES
	progression_reward = list(15 MINUTES, 20 MINUTES)
	telecrystal_reward = list(3, 5)

	var/progression_objectives_minimum = 20 MINUTES

	/// Reference to the weakpoint locator(if we sent one)
	var/obj/item/weakpoint_locator/locator
	/// Reference to the ES8 explosive (if we sent one)
	var/obj/item/grenade/c4/es8/shatter_charge
	/// Have we located the weakpoint yet?
	var/weakpoint_found = FALSE
	/// Weakpoint scan areas and the weakpoint itself
	var/list/weakpoint_areas

/datum/traitor_objective/locate_weakpoint/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(handler.get_completion_progression(/datum/traitor_objective) < progression_objectives_minimum)
		return FALSE

	if(SStraitor.taken_objectives_by_type[/datum/traitor_objective/locate_weakpoint])
		for(var/datum/traitor_objective/locate_weakpoint/weakpoint_objective in SStraitor.taken_objectives_by_type[type])
			if(weakpoint_objective.objective_state == OBJECTIVE_STATE_COMPLETED)
				return FALSE

			if(weakpoint_areas)
				continue

			weakpoint_areas = weakpoint_objective.weakpoint_areas.Copy()
			for(var/weakpoint in weakpoint_areas)
				weakpoint_areas[weakpoint] = TRUE

	if(!weakpoint_areas)
		weakpoint_areas = list()
		/// List of high-security areas that we pick required ones from
		var/list/allowed_areas = typecacheof(list(/area/station/command,
			/area/station/cargo/qm,
			/area/station/comms,
			/area/station/engineering,
			/area/station/science,
			/area/station/security,
		))

		var/list/blacklisted_areas = typecacheof(list(/area/station/engineering/hallway,
			/area/station/engineering/lobby,
			/area/station/engineering/storage,
			/area/station/science/lobby,
			/area/station/science/ordnance/bomb,
			/area/station/security/prison,
		))

		var/list/possible_areas = GLOB.the_station_areas.Copy()
		for(var/area/possible_area as anything in possible_areas)
			if(!is_type_in_typecache(possible_area, allowed_areas) || initial(possible_area.outdoors) || is_type_in_typecache(possible_area, blacklisted_areas))
				possible_areas -= possible_area

		for(var/i in 1 to 3)
			weakpoint_areas[pick_n_take(possible_areas)] = TRUE

	var/area/weakpoint_area1 = weakpoint_areas[1]
	var/area/weakpoint_area2 = weakpoint_areas[2]
	replace_in_name("%AREA1%", initial(weakpoint_area1.name))
	replace_in_name("%AREA2%", initial(weakpoint_area2.name))
	RegisterSignal(generating_for, COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED, .proc/on_global_obj_completed)
	return TRUE

/datum/traitor_objective/locate_weakpoint/proc/on_global_obj_completed(datum/source, datum/traitor_objective/objective)
	SIGNAL_HANDLER
	if(istype(objective, /datum/traitor_objective/locate_weakpoint))
		fail_objective()

/datum/traitor_objective/locate_weakpoint/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!locator)
		buttons += add_ui_button("", "Pressing this will materialize a weakpoint locator in your hand.", "globe", "locator")
	if(weakpoint_found && !shatter_charge)
		buttons += add_ui_button("", "Pressing this will materialize an ES8 explosive charge in your hand.", "bomb", "shatter_charge")
	return buttons

/datum/traitor_objective/locate_weakpoint/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("locator")
			if(locator)
				return
			locator = new(user.drop_location())
			user.put_in_hands(locator, weakpoint_areas[1], weakpoint_areas[2])
			locator.balloon_alert(user, "the weakpoint locator materializes in your hand")

		if("shatter_charge")
			if(shatter_charge)
				return
			shatter_charge = new(user.drop_location())
			user.put_in_hands(shatter_charge)
			shatter_charge.balloon_alert(user, "the ES8 charge materializes in your hand")

/datum/traitor_objective/locate_weakpoint/proc/weakpoint_located()
	description = "Structural weakpoint has been located in %AREA%. Detonate an ES8 explosive charge there to create a shockwave that will severely damage the station."
	var/area/weakpoint_area = weakpoint_areas[3]
	replace_in_name("%AREA%", initial(weakpoint_area.name))
	weakpoint_found = TRUE

/datum/traitor_objective/locate_weakpoint/proc/create_shockwave(center_x, center_y, center_z)
	var/severity = list(EXPLODE_LIGHT, EXPLODE_LIGHT, EXPLODE_LIGHT, EXPLODE_LIGHT, EXPLODE_HEAVY, EXPLODE_HEAVY, EXPLODE_DEVASTATE) //Can't use pick_weight because explode defines are numbers
	var/wave_amount = rand(5, 8)
	var/list/bombed_turfs = list()
	for(var/i in 1 to wave_amount)
		var/wave_angle = rand(-10, 10) + 360 / wave_amount * i
		var/wave_distance = rand(17, 25)
		var/turf/tentacle_ending = locate(clamp(center_x + round(cos(wave_angle) * wave_distance), 1, world.maxx), clamp(center_y + round(sin(wave_angle) * wave_distance), 1, world.maxy), center_z)
		if(!tentacle_ending) //WUT
			continue

		var/turf/epicenter = locate(center_x, center_y, center_z)
		for(var/turf/line_turf in get_line(epicenter, tentacle_ending))
			for(var/turf/bomb_turf in range(1, line_turf))
				if((bomb_turf in bombed_turfs) || bomb_turf == epicenter)
					continue
				bombed_turfs += bomb_turf
				var/turf_severity = pick(severity)
				EX_ACT(line_turf, turf_severity)
				for(var/atom/victim in line_turf)
					EX_ACT(victim, turf_severity - 1)

		explosion(tentacle_ending, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, explosion_cause = src)

	priority_announce(
				"Attention crew, it appears that a high-power explosive charge has been detonated in your station's weakpoint, causing severe structural damage.",
				"[command_name()] High-Priority Update"
				)

	succeed_objective()

/obj/item/weakpoint_locator
	name = "structural weakpoint locator"
	desc = "A device that can triangulate station's structural weakpoint. It has to be used in %AREA1% and %AREA2% in order to triangulate the weakpoint. Warning: station's AI will be notified as soon as the process starts!"
	icon = 'icons/obj/device.dmi'
	icon_state = "weakpoint_locator"
	inhand_icon_state = "weakpoint_locator"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5

/obj/item/weakpoint_locator/Initialize(mapload, area/area1, area/area2)
	. = ..()
	desc = replacetext(desc, "%AREA1%", initial(area1.name))
	desc = replacetext(desc, "%AREA2%", initial(area2.name))

/obj/item/weakpoint_locator/attack_self(mob/living/user, modifiers)
	. = ..()
	if(!istype(user) || loc != user || !user.mind) //No TK cheese
		return

	if(!user.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(user, span_warning("You have zero clue how to use [src]."))
		return

	var/datum/traitor_objective/locate_weakpoint/objective = get_weakpoint_objective(user)
	if(!objective || objective.objective_state == OBJECTIVE_STATE_INACTIVE)
		to_chat(user, span_warning("Your time to use [src] has not come yet."))
		return

	var/area/user_area = get_area(user)
	if(!(user_area.type in objective.weakpoint_areas))
		balloon_alert(user, "invalid area!")
		playsound(user, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return

	if(!objective.weakpoint_areas[user_area.type])
		balloon_alert(user, "already scanned here!")
		playsound(user, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return

	user.visible_message(span_danger("[user] presses a few buttons on [src] and it starts ominously beeping!"), span_notice("You activate [src] and start scanning the area. Do not exit [get_area_name(user, TRUE)] until the scan finishes!"))
	playsound(user, 'sound/machines/triple_beep.ogg', 30, TRUE)
	var/alertstr = span_userdanger("Network Alert: Station network probing attempt detected[user_area?" in [get_area_name(user, TRUE)]":". Unable to pinpoint location"].")
	for(var/mob/living/silicon/ai/ai_player in GLOB.player_list)
		to_chat(ai_player, alertstr)

	if(!do_after(user, 30 SECONDS, src, IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE | IGNORE_HELD_ITEM | IGNORE_INCAPACITATED | IGNORE_SLOWDOWNS, extra_checks = CALLBACK(src, .proc/scan_checks, user, user_area, objective)))
		playsound(user, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return

	playsound(user, 'sound/machines/ding.ogg', 100, TRUE)
	objective.weakpoint_areas[user_area.type] = FALSE
	for(var/area/scan_area in objective.weakpoint_areas)
		if(objective.weakpoint_areas[scan_area])
			say("Next scanning location is [initial(scan_area.name)]")
			return

	var/area/weakpoint_location = objective.weakpoint_areas[3]
	to_chat(user, span_notice("Scan finished. Structural weakpoint located in [initial(weakpoint_location.name)]."))
	objective.weakpoint_located()

/obj/item/weakpoint_locator/proc/scan_checks(mob/living/user, area/user_area, datum/traitor_objective/locate_weakpoint/parent_objective)
	if(get_area(user) != user_area)
		return FALSE

	if(parent_objective.objective_state != OBJECTIVE_STATE_ACTIVE)
		return FALSE

	var/atom/current_loc = loc
	while(!isturf(current_loc) && !ismob(current_loc))
		current_loc = current_loc.loc

	if(current_loc != user)
		return FALSE

	return TRUE

/obj/item/weakpoint_locator/proc/get_weakpoint_objective(mob/living/user)
	if(!user.mind)
		return

	for(var/datum/traitor_objective/locate_weakpoint/weakpoint_objecitve in SStraitor.taken_objectives_by_type[/datum/traitor_objective/locate_weakpoint])
		var/datum/uplink_handler/handler = weakpoint_objecitve.handler
		if(handler.owner != user.mind)
			continue

		return weakpoint_objecitve

/obj/item/grenade/c4/es8
	name = "ES8 explosive charge"
	desc = "A high-power explosive charge designed to create a shockwave in a structural weakpoint of the station."

	icon_state = "plasticx40"
	inhand_icon_state = "plasticx4"
	worn_icon_state = "x4"

	boom_sizes = list(3, 6, 9)

	/// Reference to user's objective
	var/datum/traitor_objective/locate_weakpoint/objective

/obj/item/grenade/c4/es8/Destroy()
	objective = null
	return ..()

/obj/item/grenade/c4/es8/afterattack(atom/movable/target, mob/user, flag)
	if(!user.mind)
		return

	if(!user.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(user, span_warning("You can't seem to find a way to detonate the charge."))
		return

	for(var/datum/traitor_objective/locate_weakpoint/weakpoint_objecitve in SStraitor.taken_objectives_by_type[/datum/traitor_objective/locate_weakpoint])
		var/datum/uplink_handler/handler = weakpoint_objecitve.handler
		if(handler.owner != user.mind)
			continue
		objective = weakpoint_objecitve

	if(!objective || objective.objective_state == OBJECTIVE_STATE_INACTIVE)
		to_chat(user, span_warning("You don't think it would be wise to use [src]."))
		return

	var/area/target_area = get_area(target)
	if (target_area.type != objective.weakpoint_areas[3])
		var/area/weakpoint_area = objective.weakpoint_areas[3]
		to_chat(user, span_warning("[src] can only be detonated in [initial(weakpoint_area.name)]."))
		return

	return ..()

/obj/item/grenade/c4/es8/detonate(mob/living/lanced_by)
	var/area/target_area = get_area(target)
	if (target_area.type != objective.weakpoint_areas[3])
		var/obj/item/grenade/c4/es8/new_bomb = new(target.drop_location())
		new_bomb.balloon_alert_to_viewers("invalid location!")
		target.cut_overlay(plastic_overlay, TRUE)
		qdel(src)
		return

	if(!objective)
		return

	objective.create_shockwave(target.x, target.y, target.z)
	return ..()
