/**
 * Total cheese goal to sacrifice to [REDACTED] during wizard grand rituals.
 * The easiest way for a wizard to procure cheese is with Summon Cheese spell, which summons 9 per cast.
 * The wizard needs to complete 7 rituals, so let's give them some breathing room with cheese offerings.
 * 7 * 9 = 63, so the wizard can potentially miss two casts worth of cheese if they summon cheese on each rune.
*/
#define CHEESE_SACRIFICE_GOAL 50
/**
 * The Grand Ritual is the Wizard's alternate victory condition
 * and also a tool to make funny distractions and progress the round state.
 *
 * The wizard is assigned a random area to perform the ritual in.
 * This entails travelling to that area, drawing a 3x3 rune, and casting on it for a while.
 * Completing these causes a random event to immediately occur and may cause additional side effects in the area.
 * The more rituals are completed, the more dramatic the events which can be spawned.
 *
 * After passing certain thresholds Grand Ritual completions will begin spawning active and expended Reality Tears.
 * Above a certian threshold, beginning the ritual will alert the crew to your location.
 *
 * The 7th ritual completion is special and allows you to pick a "finale" effect which should be very dramatic.
 * Further completion after that returns to the usual behaviour.
 */
/datum/action/cooldown/grand_ritual
	name = "Grand Ritual"
	desc = "Provides direction to a nexus of power, then draws a rune in that location for completing the Grand Ritual. \
		The ritual process will take longer each time it is completed."
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	cooldown_rounding = 0
	/// Path to area we want to draw in next
	var/area/target_area
	/// Number of times the grand ritual has been completed somewhere by this user
	var/times_completed = 0
	/// If you have drawn your finale rune
	var/drew_finale = FALSE
	/// True while you are drawing a rune, prevents action spamming
	var/drawing_rune = FALSE
	/// Number of cheese sacrificed on previously drawn runes
	var/total_cheese_sacrificed = 0
	/// Whether we have sacrificed enough cheese or not
	var/total_cheese_goal_met = FALSE
	/// Weakref to a rune drawn in the current area, if there is one
	var/datum/weakref/rune

	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(
		/turf/closed/indestructible,
		/turf/open/chasm,
		/turf/open/indestructible,
		/turf/open/lava,
		/turf/open/openspace,
		/turf/open/space,
	))
	/**
	 * Areas where you can place a rune
	 * To be honest if maintenance subtypes didn't exist I could probably have got away with just a blacklist, c'est la vie
	 */
	var/static/list/area_whitelist = typecacheof(list(
		/area/station/cargo,
		/area/station/command,
		/area/station/commons,
		/area/station/construction,
		/area/station/engineering,
		/area/station/maintenance/disposal,
		/area/station/maintenance/radshelter,
		/area/station/maintenance/tram,
		/area/station/medical,
		/area/station/science,
		/area/station/security,
		/area/station/service,
	))
	/// Areas where you can't be tasked to draw a rune, usually because they're too mean
	var/static/list/area_blacklist = typecacheof(list(
		/area/station/cargo/warehouse, // This SHOULD be fine except SOMEBODY gave this area to a kilo structure which is IN SPACE
		/area/station/engineering/supermatter,
		/area/station/engineering/transit_tube,
		/area/station/science/ordnance/bomb,
		/area/station/science/ordnance/burnchamber,
		/area/station/science/ordnance/freezerchamber,
		/area/station/science/server,
		/area/station/security/prison/safe,
	))

/datum/action/cooldown/grand_ritual/IsAvailable(feedback)
	. = ..()
	if (!.)
		return

	if(!isturf(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "can't reach the floor!")
		return FALSE
	return TRUE

/datum/action/cooldown/grand_ritual/Activate(trigger_flags)
	. = ..()
	validate_area()
	if (istype(get_area(owner), target_area))
		start_drawing_rune()
	else
		pinpoint_area()

/datum/action/cooldown/grand_ritual/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	if (!target_area)
		set_new_area()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/grand_ritual/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/// If the target area doesn't exist or has been invalidated somehow, pick another one
/datum/action/cooldown/grand_ritual/proc/validate_area()
	if (!target_area || !length(get_area_turfs(target_area)))
		set_new_area()
		return FALSE
	return TRUE

/// Finds a random station area to place our rune in
/datum/action/cooldown/grand_ritual/proc/set_new_area()
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for (var/area/possible_area as anything in possible_areas)
		if (initial(possible_area.outdoors) \
			|| !is_type_in_typecache(possible_area, area_whitelist) \
			|| is_type_in_typecache(possible_area, area_blacklist))
			possible_areas -= possible_area

	target_area = pick(possible_areas)
	if (validate_area()) // Well this is risky but probably not every area on the station is going to get deleted, right?
		to_chat(owner, span_alert("The next nexus of power lies within [initial(target_area.name)]"))

/// Checks if you're actually able to draw a rune here
/datum/action/cooldown/grand_ritual/proc/start_drawing_rune()
	var/atom/existing_rune = rune?.resolve()
	if (existing_rune)
		owner.balloon_alert(owner, "rune already exists!")
		return

	var/turf/target_turf = get_turf(owner)
	for (var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if (!is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			continue
		owner.balloon_alert(owner, "invalid floor!")
		return

	if (locate(/obj/effect/grand_rune) in range(3, target_turf))
		owner.balloon_alert(owner, "rune too close!")
		return

	if (drawing_rune)
		owner.balloon_alert(owner, "already drawing!")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), target_turf)

/// Draws the ritual rune
/datum/action/cooldown/grand_ritual/proc/draw_rune(turf/target_turf)
	drawing_rune = TRUE
	var/next_rune_typepath = get_appropriate_rune_typepath()
	target_turf.balloon_alert(owner, "conjuring rune...")
	var/draw_effect_typepath = /obj/effect/temp_visual/wizard_rune/drawing
	if(next_rune_typepath == /obj/effect/grand_rune/finale/cheesy)
		draw_effect_typepath = /obj/effect/temp_visual/wizard_rune/drawing/cheese
	var/obj/effect/temp_visual/wizard_rune/drawing/draw_effect = new draw_effect_typepath(target_turf)
	if(!do_after(owner, 4 SECONDS, target_turf))
		target_turf.balloon_alert(owner, "interrupted!")
		drawing_rune = FALSE
		qdel(draw_effect)
		var/fail_effect_typepath = /obj/effect/temp_visual/wizard_rune/failed
		if(next_rune_typepath == /obj/effect/grand_rune/finale/cheesy)
			fail_effect_typepath = /obj/effect/temp_visual/wizard_rune/failed/cheese
		new fail_effect_typepath(target_turf)
		return

	var/evaporated_obstacles = FALSE
	for (var/atom/possible_obstacle in range(1, target_turf))
		if (!possible_obstacle.density)
			continue
		evaporated_obstacles = TRUE
		new /obj/effect/temp_visual/emp/pulse(possible_obstacle)

		if (iswallturf(possible_obstacle))
			var/turf/closed/wall/wall = possible_obstacle
			wall.dismantle_wall(devastated = TRUE)
			continue
		possible_obstacle.atom_destruction("magic")

	if (evaporated_obstacles)
		playsound(target_turf, 'sound/effects/magic/blind.ogg', 100, TRUE)

	target_turf.balloon_alert(owner, "rune created")
	var/obj/effect/grand_rune/new_rune = new next_rune_typepath(target_turf, times_completed)
	if(istype(new_rune, /obj/effect/grand_rune/finale))
		drew_finale = TRUE
	rune = WEAKREF(new_rune)
	RegisterSignal(new_rune, COMSIG_GRAND_RUNE_COMPLETE, PROC_REF(on_rune_complete))
	drawing_rune = FALSE
	StartCooldown(2 MINUTES) // To put a damper on wizards who have 5 ranks of Teleport

/// The seventh rune we spawn is special
/datum/action/cooldown/grand_ritual/proc/get_appropriate_rune_typepath()
	if (times_completed < GRAND_RITUAL_FINALE_COUNT - 1)
		return /obj/effect/grand_rune
	if (drew_finale)
		return /obj/effect/grand_rune
	if (total_cheese_sacrificed >= CHEESE_SACRIFICE_GOAL)
		return /obj/effect/grand_rune/finale/cheesy
	return /obj/effect/grand_rune/finale

/// Called when you finish invoking a rune you drew, get ready for another one.
/datum/action/cooldown/grand_ritual/proc/on_rune_complete(atom/source, cheese_sacrificed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_GRAND_RUNE_COMPLETE)
	total_cheese_sacrificed += cheese_sacrificed
	if(total_cheese_sacrificed >= CHEESE_SACRIFICE_GOAL)
		if(!total_cheese_goal_met)
			total_cheese_goal_met = TRUE
			to_chat(owner, span_revenbignotice("YES! CHEESE! CHEESE FOR EVERYONE! SUCH A GRAND FEAST! YOU SHALL HAVE YOUR PRIZE, MY CHAMPION!!"))
		else
			to_chat(owner, span_revennotice("You hear maddening laughter as you are hit with an overwhelming odor of fine cheddar..."))
	else if (total_cheese_sacrificed)
		to_chat(owner, span_revendanger("You please me, mortal. Do continue to send cheese, my feast still needs <b>[CHEESE_SACRIFICE_GOAL - total_cheese_sacrificed]</b> more to be magnificent..."))
	rune = null
	times_completed++
	set_new_area()
	switch (times_completed)
		if (GRAND_RITUAL_RUNES_WARNING_POTENCY)
			to_chat(owner, span_warning("Your collected power is growing, \
				but further rituals will alert your enemies to your position."))
		if (GRAND_RITUAL_IMMINENT_FINALE_POTENCY)
			var/message = "You are overflowing with power! \
				Your next Grand Ritual will allow you to choose a powerful effect, and grant you victory."
			if(total_cheese_sacrificed >= CHEESE_SACRIFICE_GOAL)
				message = "You are overflowing with chaotic energies! \
					Your next Grand Ritual will conjure a powerful artefact for your use, and grant you victory."
			to_chat(owner, span_warning(message))
		if (GRAND_RITUAL_FINALE_COUNT)
			SEND_SIGNAL(src, COMSIG_GRAND_RITUAL_FINAL_COMPLETE)

/// Pinpoints the ritual area
/datum/action/cooldown/grand_ritual/proc/pinpoint_area()
	var/area/area_turf = pick(get_area_turfs(target_area)) // Close enough probably
	var/area/our_turf = get_turf(owner)
	owner.balloon_alert(owner, get_pinpoint_text(area_turf, our_turf))

/**
 * Compare positions and output information.
 * Similar to heretic target locating.
 * But simplified because we shouldn't be able to target locations on lavaland or the gateway anyway.
 */
/datum/action/cooldown/grand_ritual/proc/get_pinpoint_text(area/area_turf, area/our_turf)
	var/area_z = area_turf?.z
	var/our_z = our_turf?.z
	var/balloon_message = "something went wrong!"

	// Either us or the location is somewhere it shouldn't be
	if (!our_z || !area_z)
		// "Hell if I know"
		balloon_message = "on another plane!"
	// It's not on the same z-level as us
	else if (our_z != area_z)
		// It's on the station
		if (is_station_level(area_z))
			// We're on a multi-z station
			if (is_station_level(our_z))
				if (our_z > area_z)
					balloon_message = "below you!"
				else
					balloon_message = "above you!"
			// We're off station, it's not
			else
				balloon_message = "on station!"
	// It's on the same z-level as us!
	else
		var/dist = get_dist(our_turf, area_turf)
		var/dir = get_dir(our_turf, area_turf)
		switch(dist)
			if (0 to 15)
				balloon_message = "very near, [dir2text(dir)]!"
			if (16 to 31)
				balloon_message = "near, [dir2text(dir)]!"
			if (32 to 127)
				balloon_message = "far, [dir2text(dir)]!"
			else
				balloon_message = "very far!"

	return balloon_message

/// Abstract holder for shared animation behaviour
/obj/effect/temp_visual/wizard_rune
	icon = 'icons/effects/96x96.dmi'
	icon_state = null
	pixel_x = -33
	pixel_y = 16
	pixel_z = -48
	anchored = TRUE
	layer = SIGIL_LAYER
	plane = GAME_PLANE
	duration = 0 SECONDS

/obj/effect/temp_visual/wizard_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "wizard_rune", silicon_image)

/// Animates drawing a cool rune
/obj/effect/temp_visual/wizard_rune/drawing
	icon_state = "wizard_rune_draw"
	duration = 4 SECONDS

/// Displayed if you stop drawing it
/obj/effect/temp_visual/wizard_rune/failed
	icon_state = "wizard_rune_fail"
	duration = 0.5 SECONDS

/// Cheese drawing
/obj/effect/temp_visual/wizard_rune/drawing/cheese
	icon_state = "wizard_rune_cheese_draw"

/// Cheese fail
/obj/effect/temp_visual/wizard_rune/failed/cheese
	icon_state = "wizard_rune_cheese_fail"

#undef CHEESE_SACRIFICE_GOAL
