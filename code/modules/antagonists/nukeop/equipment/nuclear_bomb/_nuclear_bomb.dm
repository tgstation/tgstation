/// Whether the station has been nuked itself. TRUE only if the station was actually hit by the nuke, otherwise FALSE
GLOBAL_VAR_INIT(station_was_nuked, FALSE)
/// The source of the last nuke that went off
GLOBAL_VAR(station_nuke_source)

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = FALSE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	use_power = NO_POWER_USE

	/// What the timer is set to, in seconds
	var/timer_set = 90
	/// What the min value the timer can be, in seconds
	var/minimum_timer_set = 90
	/// What the max value the timer can be, in seconds
	var/maximum_timer_set = 3600
	/// The current input of the numpad on the bomb
	var/numeric_input = ""
	/// What mode the UI currently is in
	var/ui_mode = NUKEUI_AWAIT_DISK
	/// Whether we're currently timing an explosive and counting down
	var/timing = FALSE
	/// Whether the timer has elapsed and we're currently exploding
	var/exploding = FALSE
	/// Whether we've actually fully exploded
	var/exploded = FALSE
	/// world time tracker for when we're going to explode
	var/detonation_timer = null
	/// The code we need to detonate this nuke. Starts as "admin", purposefully un-enterable
	var/r_code = NUKE_CODE_UNSET
	/// If TRUE, the correct code has been entered and we can start the nuke
	var/yes_code = FALSE
	/// Whether the nuke safety is on, can't explode if it is
	var/safety = TRUE
	/// The nuke disk currently inserted into the nuke
	var/obj/item/disk/nuclear/auth
	/// The alert level that was set before the nuke started, so we can revert to the correct level after
	var/previous_level = ""
	/// The nuke core within the nuke, created in initialize
	var/obj/item/nuke_core/core
	/// The current state of deconstructing / opening up the nuke to access the core
	var/deconstruction_state = NUKESTATE_INTACT
	/// Overlay - flashing lights over the nuke
	var/lights = ""
	/// Overlay - shows the interior of the nuke
	var/interior = ""
	/// if TRUE, this nuke is actually a real nuke, and not a prank or toy
	var/proper_bomb = TRUE //Please
	/// A reference to the countdown that goes up over the nuke
	var/obj/effect/countdown/nuclearbomb/countdown

/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	countdown = new(src)
	core = new /obj/item/nuke_core(src)
	STOP_PROCESSING(SSobj, core)
	update_appearance()
	SSpoints_of_interest.make_point_of_interest(src)
	previous_level = SSsecurity_level.get_current_level_as_text()

/obj/machinery/nuclearbomb/Destroy()
	safety = FALSE
	if(!exploding)
		// If we're not exploding, set the alert level back to normal
		toggle_nuke_safety()
	QDEL_NULL(countdown)
	QDEL_NULL(core)
	return ..()

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(exploding)
		. += span_bolddanger("It is in the process of exploding. Perhaps reviewing your affairs is in order.")
	if(timing)
		. += span_danger("There are [get_time_left()] seconds until detonation.")

/// Checks if the disk inserted is a real nuke disk or not.
/obj/machinery/nuclearbomb/proc/disk_check(obj/item/disk/nuclear/inserted_disk)
	if(inserted_disk.fake)
		say("Authentication failure; disk not recognised.")
		return FALSE

	return TRUE

/obj/machinery/nuclearbomb/attackby(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/disk/nuclear))
		if(!disk_check(weapon))
			return TRUE
		if(!user.transferItemToLoc(weapon, src))
			return TRUE
		auth = weapon
		update_ui_mode()
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		add_fingerprint(user)
		return TRUE

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(weapon, /obj/item/screwdriver/nuke))
				to_chat(user, span_notice("You start removing [src]'s front panel's screws..."))
				if(weapon.use_tool(src, user, 6 SECONDS, volume = 100))
					deconstruction_state = NUKESTATE_UNSCREWED
					to_chat(user, span_notice("You remove the screws from [src]'s front panel."))
					update_appearance()
				return TRUE

		if(NUKESTATE_PANEL_REMOVED)
			if(weapon.tool_behaviour == TOOL_WELDER)
				if(!weapon.tool_start_check(user, amount = 1))
					return TRUE
				to_chat(user, span_notice("You start cutting [src]'s inner plate..."))
				if(weapon.use_tool(src, user, 8 SECONDS, volume=100))
					to_chat(user, span_notice("You cut [src]'s inner plate."))
					deconstruction_state = NUKESTATE_WELDED
					update_appearance()
				return TRUE

		if(NUKESTATE_CORE_EXPOSED)
			if(istype(weapon, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = weapon
				to_chat(user, span_notice("You start loading the plutonium core into [core_box]..."))
				if(do_after(user, 5 SECONDS, target=src))
					if(core_box.load(core, user))
						to_chat(user, span_notice("You load the plutonium core into [core_box]."))
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_appearance()
						core = null
					else
						to_chat(user, span_warning("You fail to load the plutonium core into [core_box]. [core_box] has already been used!"))
				return TRUE

			if(istype(weapon, /obj/item/stack/sheet/iron))
				if(!weapon.tool_start_check(user, amount = 20))
					return TRUE

				to_chat(user, span_notice("You begin repairing [src]'s inner metal plate..."))
				if(weapon.use_tool(src, user, 10 SECONDS, amount = 20))
					to_chat(user, span_notice("You repair [src]'s inner metal plate. The radiation is contained."))
					deconstruction_state = NUKESTATE_PANEL_REMOVED
					STOP_PROCESSING(SSobj, core)
					update_appearance()
				return TRUE

	return ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/tool)
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			to_chat(user, span_notice("You start removing [src]'s front panel..."))
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, span_notice("You remove [src]'s front panel."))
				deconstruction_state = NUKESTATE_PANEL_REMOVED
				update_appearance()
			return TRUE
		if(NUKESTATE_WELDED)
			to_chat(user, span_notice("You start prying off [src]'s inner plate..."))
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, span_notice("You pry off [src]'s inner plate. You can see the core's green glow!"))
				deconstruction_state = NUKESTATE_CORE_EXPOSED
				update_appearance()
				START_PROCESSING(SSobj, core)
			return TRUE

	return FALSE

/obj/machinery/nuclearbomb/can_interact(mob/user)
	if(HAS_TRAIT(user, TRAIT_CAN_USE_NUKE))
		return TRUE

	return ..()

/obj/machinery/nuclearbomb/ui_state(mob/user)
	if(HAS_TRAIT(user, TRAIT_CAN_USE_NUKE))
		return GLOB.physical_state

	return ..()

/// Gets the current state of the nuke.
/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(exploding)
		return NUKE_ON_EXPLODING
	if(timing)
		return NUKE_ON_TIMING
	if(safety)
		return NUKE_OFF_LOCKED
	else
		return NUKE_OFF_UNLOCKED

/obj/machinery/nuclearbomb/update_icon_state()
	if(deconstruction_state != NUKESTATE_INTACT)
		icon_state = "nuclearbomb_base"
		return ..()

	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
			icon_state = "nuclearbomb_base"
		if(NUKE_ON_TIMING)
			icon_state = "nuclearbomb_timing"
		if(NUKE_ON_EXPLODING)
			icon_state = "nuclearbomb_exploding"

	return ..()

/obj/machinery/nuclearbomb/update_overlays()
	. = ..()

	if(lights)
		cut_overlay(lights)
	cut_overlay(interior)

	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			interior = "panel-unscrewed"
		if(NUKESTATE_PANEL_REMOVED)
			interior = "panel-removed"
		if(NUKESTATE_WELDED)
			interior = "plate-welded"
		if(NUKESTATE_CORE_EXPOSED)
			interior = "plate-removed"
		if(NUKESTATE_CORE_REMOVED)
			interior = "core-removed"
		if(NUKESTATE_INTACT)
			return

	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED)
			lights = ""
			return
		if(NUKE_OFF_UNLOCKED)
			lights = "lights-safety"
		if(NUKE_ON_TIMING)
			lights = "lights-timing"
		if(NUKE_ON_EXPLODING)
			lights = "lights-exploding"

	add_overlay(lights)
	add_overlay(interior)

/obj/machinery/nuclearbomb/process()
	if(!timing || exploding)
		return

	if(detonation_timer < world.time)
		explode()
		return

	var/volume = (get_time_left() <= 20 ? 30 : 5)
	playsound(loc, 'sound/items/timer.ogg', volume, FALSE)

/// Changes what mode the UI is depending on the state of the nuke.
/obj/machinery/nuclearbomb/proc/update_ui_mode()
	if(exploded)
		ui_mode = NUKEUI_EXPLODED
		return

	if(!auth)
		ui_mode = NUKEUI_AWAIT_DISK
		return

	if(timing)
		ui_mode = NUKEUI_TIMING
		return

	if(!safety)
		ui_mode = NUKEUI_AWAIT_ARM
		return

	if(!yes_code)
		ui_mode = NUKEUI_AWAIT_CODE
		return

	ui_mode = NUKEUI_AWAIT_TIMER

/obj/machinery/nuclearbomb/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb", name)
		ui.open()

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth

	var/hidden_code = (ui_mode == NUKEUI_AWAIT_CODE && numeric_input != "ERROR")

	var/current_code = ""
	if(hidden_code)
		while(length(current_code) < length(numeric_input))
			current_code = "[current_code]*"
	else
		current_code = numeric_input
	while(length(current_code) < 5)
		current_code = "[current_code]-"

	var/first_status
	var/second_status
	switch(ui_mode)
		if(NUKEUI_AWAIT_DISK)
			first_status = "DEVICE LOCKED"
			if(timing)
				second_status = "TIME: [get_time_left()]"
			else
				second_status = "AWAIT DISK"
		if(NUKEUI_AWAIT_CODE)
			first_status = "INPUT CODE"
			second_status = "CODE: [current_code]"
		if(NUKEUI_AWAIT_TIMER)
			first_status = "INPUT TIME"
			second_status = "TIME: [current_code]"
		if(NUKEUI_AWAIT_ARM)
			first_status = "DEVICE READY"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_TIMING)
			first_status = "DEVICE ARMED"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_EXPLODED)
			first_status = "DEVICE DEPLOYED"
			second_status = "THANK YOU"

	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored

	return data

/obj/machinery/nuclearbomb/ui_act(action, params)
	. = ..()
	if(.)
		return
	playsound(src, SFX_TERMINAL_TYPE, 20, FALSE)
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
			else
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/disk/nuclear)
				if(I && disk_check(I) && usr.transferItemToLoc(I, src))
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
					playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
					auth = I
					. = TRUE
			update_ui_mode()
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("C")
						if(auth && ui_mode == NUKEUI_AWAIT_ARM)
							toggle_nuke_safety()
							yes_code = FALSE
							playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
							update_ui_mode()
						else
							playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
						numeric_input = ""
						. = TRUE
					if("E")
						switch(ui_mode)
							if(NUKEUI_AWAIT_CODE)
								if(numeric_input == r_code)
									numeric_input = ""
									yes_code = TRUE
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									. = TRUE
								else
									playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
									numeric_input = "ERROR"
							if(NUKEUI_AWAIT_TIMER)
								var/number_value = text2num(numeric_input)
								if(number_value)
									timer_set = clamp(number_value, minimum_timer_set, maximum_timer_set)
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									toggle_nuke_safety()
									. = TRUE
							else
								playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
						update_ui_mode()
					if("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
						if(numeric_input != "ERROR")
							numeric_input += digit
							if(length(numeric_input) > 5)
								numeric_input = "ERROR"
							else
								playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
							. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("arm")
			if(auth && yes_code && !safety && !exploded)
				playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
				toggle_nuke_armed()
				update_ui_mode()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("anchor")
			if(auth && yes_code)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				set_anchor(usr)
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)

/// Anchors the nuke, duh. Can only be done if the disk is inside.
/obj/machinery/nuclearbomb/proc/set_anchor(mob/anchorer)
	if(isinspace() && !anchored)
		if(anchorer)
			to_chat(anchorer, span_warning("There is nothing to anchor to!"))
		return

	set_anchored(!anchored)

/// Toggles the safety of the nuke.
/obj/machinery/nuclearbomb/proc/toggle_nuke_safety()
	safety = !safety

	// We're safe now, so stop any ongoing timers
	if(safety)
		if(timing)
			disarm_nuke()

		timing = FALSE
		detonation_timer = null
		countdown.stop()

/// Arms the nuke, or disarms it if it's already active.
/obj/machinery/nuclearbomb/proc/toggle_nuke_armed()
	if(safety)
		to_chat(usr, span_danger("The safety is still on."))
		return

	timing = !timing
	if(timing)
		arm_nuke(usr)
	else
		disarm_nuke(usr)

/// Arms the nuke, making it active and triggering all pinpointers to start counting down (+delta alert)
/obj/machinery/nuclearbomb/proc/arm_nuke(mob/armer)
	var/turf/our_turf = get_turf(src)
	message_admins("\The [src] was armed at [ADMIN_VERBOSEJMP(our_turf)] by [armer ? ADMIN_LOOKUPFLW(armer) : "an unknown user"].")
	armer.log_message("armed \the [src].", LOG_GAME)
	armer.add_mob_memory(/datum/memory/bomb_planted/nuke, antagonist = src)

	previous_level = SSsecurity_level.get_current_level_as_number()
	detonation_timer = world.time + (timer_set * 10)
	for(var/obj/item/pinpointer/nuke/syndicate/nuke_pointer in GLOB.pinpointer_list)
		nuke_pointer.switch_mode_to(TRACK_INFILTRATOR)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DEVICE_ARMED, src)

	countdown.start()
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	notify_ghosts(
		"A nuclear device has been armed in [get_area_name(src)]!",
		source = src,
		header = "Nuke Armed",
		action = NOTIFY_ORBIT,
	)
	update_appearance()

/// Disarms the nuke, reverting all pinpointers and the security level
/obj/machinery/nuclearbomb/proc/disarm_nuke(mob/disarmer)
	var/turf/our_turf = get_turf(src)
	message_admins("\The [src] at [ADMIN_VERBOSEJMP(our_turf)] was disarmed by [disarmer ? ADMIN_LOOKUPFLW(disarmer) : "an unknown user"].")
	if(disarmer)
		disarmer.log_message("disarmed [src].", LOG_GAME)

	detonation_timer = null
	SSsecurity_level.set_level(previous_level)

	for(var/obj/item/pinpointer/nuke/syndicate/nuke_pointer in GLOB.pinpointer_list)
		nuke_pointer.switch_mode_to(initial(nuke_pointer.mode))
		nuke_pointer.alert = FALSE

	countdown.stop()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DEVICE_DISARMED, src)
	update_appearance()

/// If the nuke is active, gets how much time is left until it detonates, in seconds.
/// If the nuke is not active, gets how much time the nuke is set for, in seconds.
/obj/machinery/nuclearbomb/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/attacking_blob)
	if(exploding)
		return
	qdel(src)

/obj/machinery/nuclearbomb/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKE_RADIUS 127

/**
 * Begins the process of exploding the nuke.
 * [proc/explode] -> [proc/actually_explode] -> [proc/really_actually_explode])
 *
 * Goes through a few timers and plays a cinematic.
 */
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		return FALSE

	exploding = TRUE
	yes_code = FALSE
	safety = TRUE
	update_appearance()
	sound_to_playing_players('sound/machines/alarm.ogg')

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DEVICE_DETONATING, src)

	if(SSticker?.mode)
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, PROC_REF(actually_explode)), 10 SECONDS)
	return TRUE

/obj/machinery/nuclearbomb/proc/actually_explode()
	if(!core)
		play_cinematic(/datum/cinematic/nuke/no_core, world)
		SSticker.roundend_check_paused = FALSE
		return

	var/detonation_status
	var/turf/bomb_location = get_turf(src)
	var/area/nuke_area = get_area(bomb_location)

	// The nuke was on the station zlevel
	if(bomb_location && is_station_level(bomb_location.z))
		// Nuke missed, it's in space
		if(istype(nuke_area, /area/space))
			detonation_status = DETONATION_NEAR_MISSED_STATION

		// Nuke missed, it'stoo far from the station
		else if((bomb_location.x < (128 - NUKE_RADIUS)) \
			|| (bomb_location.x > (128 + NUKE_RADIUS)) \
			|| (bomb_location.y < (128 - NUKE_RADIUS)) \
			|| (bomb_location.y > (128 + NUKE_RADIUS)))

			detonation_status = DETONATION_NEAR_MISSED_STATION

		// Confirming good hits, the nuke hit the station
		else
			SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, TRUE)
			detonation_status = DETONATION_HIT_STATION
			GLOB.station_was_nuked = TRUE

	// The nuke was on the syndicate base
	else if(bomb_location.onSyndieBase())
		detonation_status = DETONATION_HIT_SYNDIE_BASE

	// The nuke was somewhere wacky - deep space, mining z, centcom? Whatever
	else
		detonation_status = DETONATION_MISSED_STATION

	// Now go play the cinematic
	GLOB.station_nuke_source = detonation_status
	really_actually_explode(detonation_status)
	SSticker.roundend_check_paused = FALSE

	return detonation_status

/obj/machinery/nuclearbomb/proc/really_actually_explode(detonation_status)
	var/cinematic = get_cinematic_type(detonation_status)
	if(!isnull(cinematic))
		play_cinematic(cinematic, world, CALLBACK(SSticker, TYPE_PROC_REF(/datum/controller/subsystem/ticker, station_explosion_detonation), src))

	var/drop_level = TRUE
	switch(detonation_status)
		if(DETONATION_HIT_STATION)
			nuke_effects(SSmapping.levels_by_trait(ZTRAIT_STATION))
			drop_level = FALSE

		if(DETONATION_HIT_SYNDIE_BASE)
			priority_announce(
				"Long Range Scanners indicate that the nuclear device has detonated on a previously unknown base, we assume \
				the base to be of Syndicate Origin. Good work crew.",
				"Nuclear Operations Command",
			)

			var/datum/turf_reservation/syndicate_base = SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NUKIEBASE)
			ASYNC
				for(var/turf/turf as anything in syndicate_base.reserved_turfs)
					for(var/mob/living/about_to_explode in turf)
						nuke_gib(about_to_explode, src)
					CHECK_TICK

		else
			priority_announce(
				"Long Range Scanners indicate that the nuclear device has detonated; however seismic activity on the station \
				is minimal. We anticipate that the device has not detonated on the station itself.",
				"Nuclear Operations Command",
			)

	if(drop_level)
		SSsecurity_level.set_level(SEC_LEVEL_RED)
	return TRUE

/// Cause nuke effects to the passed z-levels.
/obj/machinery/nuclearbomb/proc/nuke_effects(list/affected_z_levels)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(callback_on_everyone_on_z), affected_z_levels, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(nuke_gib)), src)

/// Gets what type of cinematic this nuke showcases depending on where we detonated.
/obj/machinery/nuclearbomb/proc/get_cinematic_type(detonation_status)
	if(isnull(detonation_status))
		return /datum/cinematic/nuke/self_destruct_miss

	return /datum/cinematic/nuke/self_destruct

#undef NUKE_RADIUS

/**
 * Helper proc that handles gibbing someone who has been nuked.
 */
/proc/nuke_gib(mob/living/gibbed, atom/source)
	if(HAS_TRAIT(gibbed, TRAIT_NUKEIMMUNE))
		return FALSE

	if(istype(gibbed.loc, /obj/structure/closet/secure_closet/freezer))
		var/obj/structure/closet/secure_closet/freezer/freezer = gibbed.loc
		if(!freezer.jones)
			to_chat(gibbed, span_boldannounce("You hold onto [freezer] as [source] goes off. \
				Luckily, as [freezer] is lead-lined, you survive."))
			freezer.jones = TRUE
			return FALSE

	if(gibbed.stat == DEAD)
		return FALSE

	to_chat(gibbed, span_userdanger("You are shredded to atoms by [source]!"))
	gibbed.investigate_log("has been gibbed by a nuclear blast.", INVESTIGATE_DEATHS)
	gibbed.gib()
	return TRUE

/**
 * Invokes a callback on every living mob on the provided z level.
 */
/proc/callback_on_everyone_on_z(list/z_levels, datum/callback/to_do, atom/optional_source)
	if(!islist(z_levels))
		CRASH("callback_on_everyone_on_z called [z_levels ? "with an invalid z-level list":"without any z-levels"].")

	for(var/mob/living/victim as anything in GLOB.mob_living_list)
		if(QDELETED(victim) || isnull(victim.loc))
			continue

		var/turf/target_turf = get_turf(victim)
		if(target_turf && !(target_turf.z in z_levels))
			continue

		to_do.Invoke(victim, optional_source)
