/* commented out for now until reworked

/datum/traitor_objective/ultimate/wizard
	name = "Go to %AREA% and invoke a rune of power."
	description = "Go to %AREA% and draw a rune of power with the provided impliment. Then, invoke the rune to gain great magical power."

	///Area where the rune must be drawn
	var/area/area_of_power
	///Have we sent our spraycan yet
	var/spraycan_sent = FALSE

/datum/traitor_objective/ultimate/wizard/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	var/list/extra_blacklisted_areas = list(/area/station/hallway, /area/station/security, /area/station/ai_monitored)
	for(var/area/possible_area as anything in possible_areas)
		if(is_type_in_list(possible_area, (TRAITOR_OBJECTIVE_BLACKLISTED_AREAS + extra_blacklisted_areas)) || initial(possible_area.outdoors))
			possible_areas -= possible_area

	if(!length(possible_areas))
		return FALSE

	area_of_power = pick(possible_areas)
	replace_in_name("%AREA%", initial(area_of_power.name))
	return TRUE

/datum/traitor_objective/ultimate/wizard/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!spraycan_sent)
		buttons += add_ui_button("", "Pressing this will materialize an enchanted spraycan in your hand.", "wifi", "spraycan")
	return buttons

/datum/traitor_objective/ultimate/wizard/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("spraycan")
			if(spraycan_sent)
				return

			spraycan_sent = TRUE
			var/obj/item/traitor_spraycan/enchanted/spray = new(user.drop_location())
			spray.owning_mind = WEAKREF(user.mind)
			user.put_in_hands(spray)
			spray.balloon_alert(user, "\The [spray] materializes in your hand.")

//the spraycan

/obj/item/traitor_spraycan
	///Is our rune multi stage
	var/multi_stage = TRUE

/obj/item/traitor_spraycan/enchanted
	name = "enchanted seditious spraycan"
	desc = "An enchanted spraycan able to draw a single rune of power."
	multi_stage = FALSE
	///Weakref to the mind that owns this spraycan, used for transfer to the rune
	var/datum/weakref/owning_mind

/obj/item/traitor_spraycan/enchanted/try_draw_new_rune(mob/living/user, turf/target_turf)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(isindestructiblewall(nearby_turf) || is_type_in_typecache(nearby_turf, no_draw_turfs))
			user.balloon_alert(user, "Invalid floor!")
			return

	draw_rune(user, target_turf)

/obj/item/traitor_spraycan/enchanted/draw_rune(mob/living/user, turf/target_turf)
	drawing_rune = TRUE
	target_turf.balloon_alert(user, "Drawing rune...")
	var/obj/effect/temp_visual/wizard_rune/traitor_drawing/draw_effect = new(target_turf)
	if(!do_after(user, 4 SECONDS, target_turf))
		target_turf.balloon_alert(user, "Interrupted!")
		drawing_rune = FALSE
		qdel(draw_effect)
		new /obj/effect/temp_visual/wizard_rune/failed(target_turf)
		return

	var/evaporated_obstacles = FALSE
	for(var/atom/possible_obstacle in range(1, target_turf))
		if(!possible_obstacle.density)
			continue
		evaporated_obstacles = TRUE
		new /obj/effect/temp_visual/emp/pulse(possible_obstacle)

		if(iswallturf(possible_obstacle))
			var/turf/closed/wall/wall = possible_obstacle
			wall.dismantle_wall(devastated = TRUE)
			continue
		possible_obstacle.atom_destruction("magic")

	if(evaporated_obstacles)
		playsound(target_turf, 'sound/magic/blind.ogg', 100, TRUE)

	target_turf.balloon_alert(user, "Rune created.")
	var/obj/effect/grand_rune/traitor/new_rune = new(target_turf)
	new_rune.owning_mind = WEAKREF(owning_mind?.resolve())
	expended = TRUE
	desc = "A very suspicious looking spraycan, it's empty."
	drawing_rune = FALSE
//the rune

#define TRAITOR_RUNE_INVOKE_TIME 30 SECONDS //you just have to invoke it once but it takes a while to channel
#define TRAITOR_GRAND_RUNE_INVOKES_TO_COMPLETE 1

/obj/effect/grand_rune/traitor
	name = "suspicious rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, it has an odd red tint."
	icon = 'monkestation/icons/effects/96x96.dmi'
	icon_state = "traitor_wizard_rune"
	spell_colour = "#780000"
	invoke_time = TRAITOR_RUNE_INVOKE_TIME
	invokes_needed = TRAITOR_GRAND_RUNE_INVOKES_TO_COMPLETE

/obj/effect/grand_rune/traitor/get_invoke_time()
	return invoke_time

/obj/effect/grand_rune/traitor/on_invocation_complete(mob/living/user)
	is_in_use = FALSE
	if(!user.mind) // oh wait, thats a monkey invoking us. Ew
		user.balloon_alert(user, "You are not real, silly!")
		return
	if(user.mind.has_antag_datum(/datum/antagonist/wizard)) // why are you like this?
		user.balloon_alert(user, "Can't be more powerfull!")
		return

	playsound(src,'sound/magic/staff_change.ogg', 75, TRUE)
	icon = 'icons/effects/96x96.dmi'
	flick("activate", src)

	user.mind.set_assigned_role(SSjob.GetJobType(/datum/job/space_wizard))
	user.mind.special_role = ROLE_WIZARD
	user.mind.add_antag_datum(/datum/antagonist/wizard/traitor)

	trigger_side_effects()
	tear_reality()

	addtimer(CALLBACK(src, PROC_REF(remove_rune)), 6)

#undef TRAITOR_RUNE_INVOKE_TIME
#undef TRAITOR_GRAND_RUNE_INVOKES_TO_COMPLETE

//the temp visual for drawing the rune

/obj/effect/temp_visual/wizard_rune/traitor_drawing
	icon = 'monkestation/icons/effects/96x96.dmi'
	icon_state = "traitor_wizard_rune_draw"
	duration = 4 SECONDS

*/
