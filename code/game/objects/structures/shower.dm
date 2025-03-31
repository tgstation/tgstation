#define SHOWER_FREEZING "freezing"
#define SHOWER_FREEZING_TEMP 100
#define SHOWER_NORMAL "normal"
#define SHOWER_NORMAL_TEMP 300
#define SHOWER_BOILING "boiling"
#define SHOWER_BOILING_TEMP 400
/// The volume of its internal reagents the shower applies to everything it sprays.
#define SHOWER_SPRAY_VOLUME 5
/// How much the volume of the shower's spay reagents are amplified by when it sprays something.
#define SHOWER_EXPOSURE_MULTIPLIER 2 // Showers effectively double exposed reagents
/// How long we run in TIMED mode
#define SHOWER_TIMED_LENGTH (15 SECONDS)

/// Run the shower until we run out of reagents.
#define SHOWER_MODE_UNTIL_EMPTY 0
/// Run the shower for SHOWER_TIMED_LENGTH time, or until we run out of reagents.
#define SHOWER_MODE_TIMED 1
/// Run the shower forever, pausing when we run out of liquid, and then resuming later.
#define SHOWER_MODE_FOREVER 2
/// Number of modes to cycle through
#define SHOWER_MODE_COUNT 3

GLOBAL_LIST_INIT(shower_mode_descriptions, list(
	"[SHOWER_MODE_UNTIL_EMPTY]" = "run until empty",
	"[SHOWER_MODE_TIMED]" = "run for 15 seconds or until empty",
	"[SHOWER_MODE_FOREVER]" = "keep running forever and auto turn back on",
))

/obj/machinery/shower
	name = "shower"
	desc = "The HS-452. Installed in the 2550s by the Nanotrasen Hygiene Division, now with 2560 lead compliance! Passively replenishes itself with water when not in use."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	use_power = NO_POWER_USE
	subsystem_type = /datum/controller/subsystem/processing/plumbing
	///Does the user want the shower on or off?
	var/intended_on = FALSE
	///Is the shower actually spitting out water currently
	var/actually_on = FALSE
	///What temperature the shower reagents are set to.
	var/current_temperature = SHOWER_NORMAL
	///What sound will be played on loop when the shower is on and pouring water.
	var/datum/looping_sound/showering/soundloop
	///What reagent should the shower be filled with when initially built.
	var/reagent_id = /datum/reagent/water
	///How much reagent capacity should the shower begin with when built.
	var/reagent_capacity = 200
	///How many units the shower refills every second.
	var/refill_rate = 0.5
	///Does the shower have a water recycler to recollect its water supply?
	var/has_water_reclaimer = TRUE
	///Which mode the shower is operating in.
	var/mode = SHOWER_MODE_UNTIL_EMPTY
	///The cooldown for SHOWER_MODE_TIMED mode.
	COOLDOWN_DECLARE(timed_cooldown)
	///How far to shift the sprite when placing.
	var/pixel_shift = 16

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/shower, (-16))

/obj/machinery/shower/Initialize(mapload, ndir = 0, has_water_reclaimer = null)
	. = ..()

	if(ndir)
		dir = ndir

	if(has_water_reclaimer != null)
		src.has_water_reclaimer = has_water_reclaimer

	switch(dir)
		if(NORTH)
			pixel_x = 0
			pixel_y = -pixel_shift
		if(SOUTH)
			pixel_x = 0
			pixel_y = pixel_shift
		if(EAST)
			pixel_x = -pixel_shift
			pixel_y = 0
		if(WEST)
			pixel_x = pixel_shift
			pixel_y = 0

	create_reagents(reagent_capacity)
	if(src.has_water_reclaimer)
		reagents.add_reagent(reagent_id, reagent_capacity)
	soundloop = new(src, FALSE)
	AddComponent(/datum/component/plumbing/simple_demand, extend_pipe_to_edge = TRUE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/shower/examine(mob/user)
	. = ..()
	. += span_notice("It looks like the thermostat has an adjustment screw.")
	if(has_water_reclaimer)
		. += span_notice("A water recycler is installed. It looks like you could pry it out.")
	. += span_notice("The auto shut-off is programmed to [GLOB.shower_mode_descriptions["[mode]"]].")
	. += span_notice("[reagents.total_volume]/[reagents.maximum_volume] liquids remaining.")

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(reagents)
	return ..()

/obj/machinery/shower/interact(mob/user)
	. = ..()
	if(.)
		return

	intended_on = !intended_on
	if(!update_actually_on(intended_on))
		balloon_alert(user, "[src] is dry!")
		return FALSE

	balloon_alert(user, "turned [intended_on ? "on" : "off"]")

	return TRUE

/obj/machinery/shower/analyzer_act(mob/living/user, obj/item/tool)
	. = ..()

	tool.play_tool_sound(src)
	to_chat(user, span_notice("The water temperature seems to be [current_temperature]."))
	return TRUE

/obj/machinery/shower/attackby(obj/item/tool, mob/user, params)
	if(istype(tool, /obj/item/stock_parts/water_recycler))
		if(has_water_reclaimer)
			to_chat(user, span_warning("There is already has a water recycler installed."))
			return

		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		qdel(tool)
		has_water_reclaimer = TRUE
		begin_processing()

	return ..()

/obj/machinery/shower/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return

	tool.play_tool_sound(src)
	mode = (mode + 1) % SHOWER_MODE_COUNT
	begin_processing()
	to_chat(user, span_notice("You change the shower's auto shut-off mode to [GLOB.shower_mode_descriptions["[mode]"]]."))
	return TRUE

/obj/machinery/shower/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return
	if(!has_water_reclaimer)
		to_chat(user, span_warning("There isn't a water recycler to remove."))
		return

	tool.play_tool_sound(src)
	has_water_reclaimer = FALSE
	new/obj/item/stock_parts/water_recycler(get_turf(loc))
	to_chat(user, span_notice("You remove the water reclaimer from [src]"))
	return TRUE

/obj/machinery/shower/screwdriver_act(mob/living/user, obj/item/I)
	..()
	to_chat(user, span_notice("You begin to adjust the temperature valve with \the [I]..."))
	if(I.use_tool(src, user, 50))
		switch(current_temperature)
			if(SHOWER_NORMAL)
				current_temperature = SHOWER_FREEZING
			if(SHOWER_FREEZING)
				current_temperature = SHOWER_BOILING
			if(SHOWER_BOILING)
				current_temperature = SHOWER_NORMAL
		user.visible_message(span_notice("[user] adjusts the shower with \the [I]."), span_notice("You adjust the shower with \the [I] to [current_temperature] temperature."))
		user.log_message("has wrenched a shower to [current_temperature].", LOG_ATTACK)
		add_hiddenprint(user)
	handle_mist()
	return TRUE

/obj/machinery/shower/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	I.play_tool_sound(src)
	deconstruct()
	return TRUE

/obj/machinery/shower/update_overlays()
	. = ..()
	if(!actually_on)
		return
	var/mutable_appearance/water_falling = mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER, appearance_flags = KEEP_APART)
	water_falling.color = mix_color_from_reagents(reagents.reagent_list)
	switch(dir)
		if(NORTH)
			water_falling.pixel_y += pixel_shift
		if(SOUTH)
			water_falling.pixel_y -= pixel_shift
		if(EAST)
			water_falling.pixel_x += pixel_shift
		if(WEST)
			water_falling.pixel_x -= pixel_shift
	. += water_falling

/obj/machinery/shower/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(same_z_layer)
		return ..()
	update_appearance()
	return ..()

/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && actually_on && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, PROC_REF(make_mist)), 5 SECONDS)

	if(mist && !(actually_on && current_temperature != SHOWER_FREEZING))
		addtimer(CALLBACK(src, PROC_REF(clear_mist)), 25 SECONDS)

/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && actually_on && current_temperature != SHOWER_FREEZING)
		var/obj/effect/mist/new_mist = new /obj/effect/mist(loc)
		new_mist.color = mix_color_from_reagents(reagents.reagent_list)

/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && !(actually_on && current_temperature != SHOWER_FREEZING))
		qdel(mist)

/obj/machinery/shower/proc/on_entered(datum/source, atom/movable/enterer)
	SIGNAL_HANDLER

	if(actually_on && reagents.total_volume)
		expose_to_reagents(enterer)

/obj/machinery/shower/proc/on_exited(datum/source, atom/movable/exiter)
	SIGNAL_HANDLER

	if(!isliving(exiter))
		return

	var/obj/machinery/shower/locate_new_shower = locate() in get_turf(exiter)
	if(locate_new_shower && isturf(exiter.loc))
		return
	var/mob/living/take_his_status_effect = exiter
	take_his_status_effect.remove_status_effect(/datum/status_effect/washing_regen)

/obj/machinery/shower/proc/expose_to_reagents(atom/target)
	var/purity_volume = reagents.total_volume*0.70 	// need 70% of total reagents
	var/datum/reagent/blood/bloody_shower = reagents.has_reagent(/datum/reagent/blood, amount=purity_volume)
	var/datum/reagent/water/clean_shower = reagents.has_reagent(/datum/reagent/water, amount=purity_volume)
	// we only care about blood and h20 for mood/status effect
	var/datum/reagent/shower_reagent = bloody_shower || clean_shower || null

	reagents.expose(target, (TOUCH), SHOWER_EXPOSURE_MULTIPLIER * SHOWER_SPRAY_VOLUME / max(reagents.total_volume, SHOWER_SPRAY_VOLUME))
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	check_heat(living_target)

	living_target.apply_status_effect(/datum/status_effect/washing_regen, shower_reagent)
	living_target.add_mood_event("shower", /datum/mood_event/shower, shower_reagent)

/**
 * Toggle whether shower is actually on and outputting water.
 * May not match what user asked to happen by clicking.
 * Returns TRUE if the state was changed.
 *
 * Arguments:
 * * new_on_state - new state
 */
/obj/machinery/shower/proc/update_actually_on(new_on_state)
	if(new_on_state == actually_on)
		return FALSE

	// Check if we have enough reagents to actually turn on.
	if(new_on_state && reagents.total_volume < SHOWER_SPRAY_VOLUME)
		return FALSE

	actually_on = new_on_state

	update_appearance()
	handle_mist()
	if(new_on_state)
		begin_processing()
		soundloop.start()
		COOLDOWN_START(src, timed_cooldown, SHOWER_TIMED_LENGTH)
	else
		soundloop.stop()
		if(isopenturf(loc))
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, wet_time_to_add = 1 SECONDS)
		for(var/mob/living/showerer in loc)
			showerer.remove_status_effect(/datum/status_effect/washing_regen)
	return TRUE

/obj/machinery/shower/process(seconds_per_tick)
	// the TIMED mode cutoff feature. User has to manually reactivate.
	if(intended_on && mode == SHOWER_MODE_TIMED && COOLDOWN_FINISHED(src, timed_cooldown))
		// the TIMED mode cutoff feature. User has to manually reactivate.
		intended_on = FALSE

	// Out of water.
	if(actually_on && reagents.total_volume < SHOWER_SPRAY_VOLUME)
		update_actually_on(FALSE)

		// Don't turn back on.
		if(mode != SHOWER_MODE_FOREVER)
			intended_on = FALSE
	else
		// Cycle: update_actually_on() will only change state if appropriate.
		update_actually_on(intended_on)

	// Reclaim water
	if(!actually_on)
		if(has_water_reclaimer && reagents.total_volume < reagents.maximum_volume)
			reagents.add_reagent(reagent_id, refill_rate * seconds_per_tick)
			return 0

		// FOREVER mode stays processing so it can cycle back on.
		return mode == SHOWER_MODE_FOREVER ? 0 : PROCESS_KILL
	// Assemble cleaning flags
	var/purity_volume = reagents.total_volume*0.70 	// need 70% of total reagents
	var/datum/reagent/water/clean_shower = reagents.has_reagent(/datum/reagent/water, amount=purity_volume)

	// radiation my beloved
	var/rad_purity_volume = reagents.total_volume*0.20 // need 20% of total reagents
	var/radium_volume = reagents.get_reagent_amount(/datum/reagent/uranium/radium)
	var/uranium_volume = reagents.get_reagent_amount(/datum/reagent/uranium)
	var/polonium_volume = reagents.get_reagent_amount(/datum/reagent/toxin/polonium) * 3 // highly radioactive
	var/total_radiation_volume = (radium_volume + uranium_volume + polonium_volume)
	var/radioactive_shower = total_radiation_volume >= rad_purity_volume

	var/wash_flags = NONE
	if(clean_shower)
		wash_flags |= CLEAN_WASH
	if(!radioactive_shower)
		// note it is possible to have a clean_shower that is radioactive (+70% water mixed with +20% radiation)
		wash_flags |= CLEAN_RAD

	// Wash up.
	loc.wash(wash_flags, TRUE)
	expose_to_reagents(loc)
	for(var/atom/movable/movable_content as anything in loc)
		expose_to_reagents(movable_content) // Wash the items on the turf (=expose them to the shower reagent)
	reagents.remove_all(SHOWER_SPRAY_VOLUME)

/obj/machinery/shower/on_deconstruction(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 2)
	if(has_water_reclaimer)
		new /obj/item/stock_parts/water_recycler(drop_location())

/obj/machinery/shower/proc/check_heat(mob/living/living)

	if(current_temperature == SHOWER_FREEZING)
		living.adjust_bodytemperature(-80, 80)
		to_chat(living, span_warning("[src] is freezing!"))
	else if(current_temperature == SHOWER_BOILING)
		living.adjust_bodytemperature(35, 0, 500)
		living.adjustFireLoss(5)
		to_chat(living, span_danger("[src] is searing!"))


/obj/structure/showerframe
	name = "shower frame"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower_frame"
	desc = "A shower frame, that needs a water recycler to finish construction."
	anchored = FALSE

/obj/structure/showerframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/showerframe/attackby(obj/item/tool, mob/living/user, params)
	if(istype(tool, /obj/item/stock_parts/water_recycler))
		qdel(tool)
		var/obj/machinery/shower/shower = new(loc, REVERSE_DIR(dir), TRUE)
		qdel(src)
		playsound(shower, 'sound/machines/click.ogg', 20, TRUE)
		return
	return ..()

/obj/structure/showerframe/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

	tool.play_tool_sound(src)
	new/obj/machinery/shower(loc, REVERSE_DIR(dir), FALSE)
	qdel(src)

	return TRUE

/obj/structure/sinkframe/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src)
	deconstruct()
	return TRUE


/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

#undef SHOWER_MODE_UNTIL_EMPTY
#undef SHOWER_MODE_TIMED
#undef SHOWER_MODE_FOREVER
#undef SHOWER_MODE_COUNT
#undef SHOWER_TIMED_LENGTH
#undef SHOWER_SPRAY_VOLUME
#undef SHOWER_EXPOSURE_MULTIPLIER
#undef SHOWER_BOILING_TEMP
#undef SHOWER_BOILING
#undef SHOWER_NORMAL_TEMP
#undef SHOWER_NORMAL
#undef SHOWER_FREEZING_TEMP
#undef SHOWER_FREEZING
