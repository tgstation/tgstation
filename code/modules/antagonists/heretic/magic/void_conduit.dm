/datum/action/cooldown/spell/conjure/void_conduit
	name = "Void Conduit"
	desc = "Opens a gate to the Void; it quickly lowers the temperature and pressure of the room while siphoning all gasses. \
		The gate releases an intermittent pulse that damages windows and airlocks, \
		applies a stack of void chill to non heretics, \
		Heretics receive a small heal and are granted the cold resistance and low pressure resistance trait."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "icebeam"

	sound = null
	school = SCHOOL_FORBIDDEN
	invocation = "Conduit!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/void_conduit)
	summon_respects_density = TRUE
	summon_respects_prev_spawn_points = TRUE

/datum/action/cooldown/spell/conjure/void_conduit/cast(atom/cast_on)
	. = ..()

/obj/structure/void_conduit
	name = "Void Conduit"
	desc = "An open gate which leads to nothingness. Pulls in air and energy to release pulses."
	icon = 'icons/effects/effects.dmi'
	icon_state = "void_conduit"
	anchored = TRUE
	///Counter for each process goes up by 1, when it's high enough our conduit will pulse
	var/conduit_pulse_counter

/obj/structure/void_conduit/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	declare_effect_radius()

/obj/structure/void_conduit/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/void_conduit/process(seconds_per_tick)
	var/turf/our_turf = get_turf(src)
	var/adjacent_turfs = our_turf.get_atmos_adjacent_turfs(alldir = TRUE)
	for(var/turf/tile in adjacent_turfs)
		do_conduit_freeze(tile)
	conduit_pulse_counter++
	if(conduit_pulse_counter >= 2)
		conduit_pulse_counter = 0
		declare_effect_radius()
		do_conduit_pulse()

///Siphons out and freezes nearby turfs
/obj/structure/void_conduit/proc/do_conduit_freeze(turf/tile)
	var/datum/gas_mixture/environment = tile.return_air()
	environment.temperature = 0
	tile.remove_air(environment.total_moles() * 0.8)

///Pulses out various effects
/obj/structure/void_conduit/proc/do_conduit_pulse()

/obj/structure/void_conduit/proc/declare_effect_radius()
	var/list/affected_atom = list()
	for(var/atom/atom in dview(10, loc))
		var/mutable_appearance/floor_overlay = mutable_appearance('icons/turf/overlays.dmi', "greyOverlay", ABOVE_OPEN_TURF_LAYER)
		floor_overlay.color = COLOR_RED
		floor_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		floor_overlay.alpha = 200
		atom.flick_overlay_view(floor_overlay, 2 SECONDS)
		affected_atom += atom

	for(var/mob/living/affected_mob in affected_atom)
		if(IS_HERETIC(affected_mob))
			affected_mob.apply_status_effect(/datum/status_effect/void_conduit)
		else
			affected_mob.apply_status_effect(/datum/status_effect/void_chill, 1)
	for(var/obj/machinery/door/affected_door in affected_atom)
		affected_door.take_damage(75)
	for(var/obj/structure/door_assembly/affected_assembly in affected_atom)
		affected_door.take_damage(75)
	for(var/obj/structure/window/affected_window in affected_atom)
		affected_window.take_damage(30)


//	for(var/atom/atom in view(10, loc))
//		var/mutable_appearance/floor_overlay = mutable_appearance('icons/turf/overlays.dmi', "greyOverlay", ABOVE_OPEN_TURF_LAYER)
//		floor_overlay.color = COLOR_RED
//		floor_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
//		floor_overlay.alpha = 200
//		atom.flick_overlay_view(floor_overlay, 2 SECONDS)

/datum/status_effect/void_conduit
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/void_conduit/on_apply()
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "void_conduit")
	return TRUE

/datum/status_effect/void_conduit/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "void_conduit")

/*
/proc/atmos_thermal(mob/viewer, range = 5, duration = 10)
	if(!ismob(viewer) || !viewer.client)
		return
	for(var/turf/open in view(range, viewer))
		if(open.blocks_air)
			continue
		var/datum/gas_mixture/environment = open.return_air()
		var/temp = round(environment.return_temperature())
		var/image/pic = image('icons/turf/overlays.dmi', open, "greyOverlay", ABOVE_ALL_MOB_LAYER)
		// Lower than TEMP_SHADE_CYAN should be deep blue
		switch(temp)
			if(-INFINITY to TEMP_SHADE_CYAN)
				pic.color = COLOR_STRONG_BLUE
			// Between TEMP_SHADE_CYAN and TEMP_SHADE_GREEN
			if(TEMP_SHADE_CYAN to TEMP_SHADE_GREEN)
				pic.color = BlendRGB(COLOR_DARK_CYAN, COLOR_LIME, max(round((temp - TEMP_SHADE_CYAN)/(TEMP_SHADE_GREEN - TEMP_SHADE_CYAN), 0.01), 0))
			// Between TEMP_SHADE_GREEN and TEMP_SHADE_YELLOW
			if(TEMP_SHADE_GREEN to TEMP_SHADE_YELLOW)
				pic.color = BlendRGB(COLOR_LIME, COLOR_YELLOW, clamp(round((temp-TEMP_SHADE_GREEN)/(TEMP_SHADE_YELLOW - TEMP_SHADE_GREEN), 0.01), 0, 1))
			// Between TEMP_SHADE_YELLOW and TEMP_SHADE_RED
			if(TEMP_SHADE_YELLOW to TEMP_SHADE_RED)
				pic.color = BlendRGB(COLOR_YELLOW, COLOR_RED, clamp(round((temp-TEMP_SHADE_YELLOW)/(TEMP_SHADE_RED - TEMP_SHADE_YELLOW), 0.01), 0, 1))
			// Over TEMP_SHADE_RED should be red
			if(TEMP_SHADE_RED to INFINITY)
				pic.color = COLOR_RED
		pic.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		pic.alpha = 200
		flick_overlay_global(pic, list(viewer.client), duration)
*/


/*
How many rifts can you have open at once:
like 1

how long do they last?
Forever?

New one replaces the old one

Cooldown: 1 minute

*/






