#define CONSTRUCTION_NO_CIRCUIT 1 //Empty frame, can safely weld apart or install circuit
#define CONSTRUCTION_PANEL_OPEN 2 //Circuit panel exposed for removal or securing
#define DEFAULT_STEP_TIME 20 /// default time for each step
#define REACTIVATION_DELAY (3 SECONDS) // Delay on reactivation, used to prevent dumb crowbar things. Just trust me

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "Apply crowbar."
	icon = 'icons/obj/doors/doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	armor_type = /datum/armor/door_firedoor
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN

	COOLDOWN_DECLARE(activation_cooldown)

	///X offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_xoffset = 0
	///Y offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_yoffset = 0


	///The type of door frame to drop during deconstruction
	var/assemblytype = /obj/structure/firelock_frame
	var/boltslocked = TRUE
	///List of areas we handle. See CalculateAffectingAreas()
	var/list/affecting_areas
	///For the few times we affect only the area we're actually in. Set during Init. If we get moved, we don't update, but this is consistant with fire alarms and also kinda funny so call it intentional.
	var/area/my_area
	///List of problem turfs with bad temperature
	var/list/turf/issue_turfs
	///Tracks if the firelock is being held open by a crowbar. If so, we don't close until they walk away
	var/being_held_open = FALSE
	///Should the firelock ignore atmosphere when choosing to stay open/closed?
	var/ignore_alarms = FALSE
	///Type of alarm we're under. See code/defines/firealarm.dm for the list. This var being null means there is no alarm.
	var/alarm_type = null
	///Is this firelock active/closed?
	var/active = FALSE
	///The merger_id and merger_typecache variables are used to make rows of firelocks activate at the same time.
	var/merger_id = "firelocks"
	var/static/list/merger_typecache

	///Overlay object for the warning lights. This and some plane settings allows the lights to glow in the dark.
	var/mutable_appearance/warn_lights

	///looping sound datum for our fire alarm siren.
	var/datum/looping_sound/firealarm/soundloop
	///Keeps track of if we're playing the alarm sound loop (as only one firelock per group should be). Used during power changes.
	var/is_playing_alarm = FALSE

	var/knock_sound = 'sound/effects/glass/glassknock.ogg'
	var/bash_sound = 'sound/effects/glass/glassbash.ogg'


/datum/armor/door_firedoor
	melee = 10
	bullet = 30
	laser = 20
	energy = 20
	bomb = 30
	fire = 95
	acid = 70

/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	id_tag = assign_random_name()
	soundloop = new(src, FALSE)
	CalculateAffectingAreas()
	my_area = get_area(src)
	if(name == initial(name))
		update_name()
	if(!merger_typecache)
		merger_typecache = typecacheof(/obj/machinery/door/firedoor)

	if(prob(0.004) && icon == 'icons/obj/doors/doorfireglass.dmi')
		base_icon_state = "sus"
		desc += " This one looks a bit sus..."

	RegisterSignal(src, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_power_restore))
	RegisterSignal(src, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_loss))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/firedoor/post_machine_initialize()
	. = ..()
	RegisterSignal(src, COMSIG_MERGER_ADDING, PROC_REF(merger_adding))
	RegisterSignal(src, COMSIG_MERGER_REMOVING, PROC_REF(merger_removing))
	GetMergeGroup(merger_id, merger_typecache)
	register_adjacent_turfs()

	if(alarm_type) // Fucking subtypes fucking mappers fucking hhhhhhhh
		start_activation_process(alarm_type)

/**
 * Sets the offset for the warning lights.
 *
 * Used for special firelocks with light overlays that don't line up to their sprite.
 */
/obj/machinery/door/firedoor/proc/adjust_lights_starting_offset()
	return

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	unregister_adjacent_turfs(loc)
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(!density)
		. += span_notice("It is open, but could be <b>pried</b> closed.")
	else if(!welded)
		. += span_notice("It is closed, but could be <b>pried</b> open.")
		. += span_notice("Hold the firelock temporarily open by prying it with <i>left-click</i> and standing next to it.")
		. += span_notice("Prying by <i>right-clicking</i> the firelock will open it permanently.")
		. += span_notice("Deconstruction would require it to be <b>welded</b> shut.")
	else if(boltslocked)
		. += span_notice("It is <i>welded</i> shut. The floor bolts have been locked by <b>screws</b>.")
	else
		. += span_notice("The bolt locks have been <i>unscrewed</i>, but the bolts themselves are still <b>wrenched</b> to the floor.")

/obj/machinery/door/firedoor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(!isliving(user))
		return .

	var/mob/living/living_user = user

	if (isnull(held_item))
		if(density)
			if(isalienadult(living_user) || issilicon(living_user))
				context[SCREENTIP_CONTEXT_LMB] = "Open"
				return CONTEXTUAL_SCREENTIP_SET
			if(!living_user.combat_mode)
				if(ishuman(living_user))
					context[SCREENTIP_CONTEXT_LMB] = "Knock"
					return CONTEXTUAL_SCREENTIP_SET
			else
				if(ismonkey(living_user))
					context[SCREENTIP_CONTEXT_LMB] = "Attack"
					return CONTEXTUAL_SCREENTIP_SET
				if(ishuman(living_user))
					context[SCREENTIP_CONTEXT_LMB] = "Bash"
					return CONTEXTUAL_SCREENTIP_SET
		else if(issilicon(living_user))
			context[SCREENTIP_CONTEXT_LMB] = "Close"
			return CONTEXTUAL_SCREENTIP_SET
		return .

	if(!Adjacent(src, living_user))
		return .

	switch (held_item.tool_behaviour)
		if (TOOL_CROWBAR)
			if (!density)
				context[SCREENTIP_CONTEXT_LMB] = "Close"
			else if (!welded)
				context[SCREENTIP_CONTEXT_LMB] = "Hold open"
				context[SCREENTIP_CONTEXT_RMB] = "Open permanently"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WELDER)
			context[SCREENTIP_CONTEXT_RMB] = welded ? "Unweld shut" : "Weld shut"
			return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_WRENCH)
			if (welded && !boltslocked)
				context[SCREENTIP_CONTEXT_LMB] = "Unfasten bolts"
				return CONTEXTUAL_SCREENTIP_SET
		if (TOOL_SCREWDRIVER)
			if (welded)
				context[SCREENTIP_CONTEXT_LMB] = "Unlock bolts"
				return CONTEXTUAL_SCREENTIP_SET

	return .

/obj/machinery/door/firedoor/update_name(updates)
	. = ..()
	name = "[get_area_name(my_area)] [initial(name)] [id_tag]"

/**
 * Calculates what areas we should worry about.
 *
 * This proc builds a list of areas we are in and areas we border
 * and writes it to affecting_areas.
 */
/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	var/list/new_affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	if(compare_list(new_affecting_areas, affecting_areas))
		return //No changes needed

	remove_from_areas()
	affecting_areas = new_affecting_areas
	for(var/area/place in affecting_areas)
		LAZYADD(place.firedoors, src)
	if(active)
		add_as_source()

/obj/machinery/door/firedoor/proc/remove_from_areas()
	remove_as_source()
	for(var/area/place in affecting_areas)
		LAZYREMOVE(place.firedoors, src)

/obj/machinery/door/firedoor/proc/merger_adding(obj/machinery/door/firedoor/us, datum/merger/new_merger)
	SIGNAL_HANDLER
	if(new_merger.id != merger_id)
		return
	RegisterSignal(new_merger, COMSIG_MERGER_REFRESH_COMPLETE, PROC_REF(refresh_shared_turfs))

/obj/machinery/door/firedoor/proc/merger_removing(obj/machinery/door/firedoor/us, datum/merger/old_merger)
	SIGNAL_HANDLER
	if(old_merger.id != merger_id)
		return
	UnregisterSignal(old_merger, COMSIG_MERGER_REFRESH_COMPLETE)

/obj/machinery/door/firedoor/proc/refresh_shared_turfs(datum/source, list/leaving_members, list/joining_members)
	SIGNAL_HANDLER
	var/datum/merger/temp_group = source
	if(temp_group.origin != src)
		return
	var/list/shared_problems = list() // We only want to do this once, this is a nice way of pulling that off
	for(var/obj/machinery/door/firedoor/firelock as anything in temp_group.members)
		firelock.issue_turfs = shared_problems
		for(var/dir in GLOB.cardinals)
			var/turf/checked_turf = get_step(get_turf(firelock), dir)
			if(!checked_turf)
				continue
			if(isclosedturf(checked_turf))
				continue
			process_results(checked_turf)

/obj/machinery/door/firedoor/proc/register_adjacent_turfs()
	if(!loc)
		return

	var/turf/our_turf = get_turf(loc)
	RegisterSignal(our_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS, PROC_REF(process_results))
	for(var/dir in GLOB.cardinals)
		var/turf/checked_turf = get_step(our_turf, dir)

		if(!checked_turf)
			continue

		RegisterSignal(checked_turf, COMSIG_TURF_CHANGE, PROC_REF(adjacent_change))
		RegisterSignal(checked_turf, COMSIG_TURF_EXPOSE, PROC_REF(process_results))
		if(!isopenturf(checked_turf))
			continue
		process_results(checked_turf)

/obj/machinery/door/firedoor/proc/unregister_adjacent_turfs(atom/old_loc)
	if(!loc)
		return

	var/turf/our_turf = get_turf(old_loc)
	UnregisterSignal(our_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)
	for(var/dir in GLOB.cardinals)
		var/turf/checked_turf = get_step(our_turf, dir)

		if(!checked_turf)
			continue

		UnregisterSignal(checked_turf, COMSIG_TURF_CHANGE)
		UnregisterSignal(checked_turf, COMSIG_TURF_EXPOSE)

// If a turf adjacent to us changes, recalc our affecting areas when it's done yeah?
/obj/machinery/door/firedoor/proc/adjacent_change(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(CalculateAffectingAreas))
	post_change_callbacks += CALLBACK(src, PROC_REF(process_results), changed) //check the atmosphere of the changed turf so we don't hold onto alarm if a wall is built

/obj/machinery/door/firedoor/proc/check_atmos(turf/checked_turf)
	var/datum/gas_mixture/environment = checked_turf.return_air()
	if(!environment)
		stack_trace("We tried to check a gas_mixture that doesn't exist for its firetype, what are you DOING")
		return

	if(environment.temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return FIRELOCK_ALARM_TYPE_HOT
	if(environment.temperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
		return FIRELOCK_ALARM_TYPE_COLD
	return

/obj/machinery/door/firedoor/proc/process_results(datum/source)
	SIGNAL_HANDLER

	for(var/area/place in affecting_areas)
		if(!place.fire_detect) //if any area is set to disable detection
			return

	var/turf/checked_turf = source
	var/result = check_atmos(checked_turf)

	if(result && TURF_SHARES(checked_turf))
		issue_turfs |= checked_turf
		if(alarm_type) // If you've already got an alarm, go away
			return
		// Store our alarm type, in case we can't activate for some reason
		alarm_type = result
		if(!ignore_alarms)
			start_activation_process(result)
	else if(length(issue_turfs))
		issue_turfs -= checked_turf
		if(length(issue_turfs) && alarm_type != FIRELOCK_ALARM_TYPE_GENERIC)
			return
		alarm_type = null
		if(!ignore_alarms)
			start_deactivation_process()


/**
 * Begins activation process of us and our neighbors.
 *
 * This proc will call activate() on every fire lock (including us) listed
 * in the merge group datum. Returns without doing anything if we're already active, cause of course
 *
 * Arguments:
 * code should be one of three defined alarm types, or can be not supplied. Will dictate the color of the fire alarm lights, and defaults to "firelock_alarm_type_generic"
 */
/obj/machinery/door/firedoor/proc/start_activation_process(code = FIRELOCK_ALARM_TYPE_GENERIC)
	if(active)
		return //We're already active
	soundloop.start()
	is_playing_alarm = TRUE
	my_area.fault_status = AREA_FAULT_AUTOMATIC
	my_area.fault_location = name
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group.members)
		buddylock.activate(code)
/**
 * Begins deactivation process of us and our neighbors.
 *
 * This proc will call reset() on every fire lock (including us) listed
 * in the merge group datum. sets our alarm type to null, signifying no alarm.
 */
/obj/machinery/door/firedoor/proc/start_deactivation_process()
	soundloop.stop()
	is_playing_alarm = FALSE
	my_area.fault_status = AREA_FAULT_NONE
	my_area.fault_location = null
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group.members)
		buddylock.reset()

/**
 * Proc that handles activation of the firelock and all this details
 *
 * Sets active and alarm type to properly represent our state.
 * Also calls set_status() on all fire alarms in all affected areas, tells
 * the area the firelock sits in to report the event (AI, alarm consoles, etc)
 * and finally calls correct_state(), which will handle opening or closing
 * this fire lock.
 */
/obj/machinery/door/firedoor/proc/activate(code = FIRELOCK_ALARM_TYPE_GENERIC)
	SIGNAL_HANDLER
	if(active)
		return //Already active
	if(ignore_alarms && code != FIRELOCK_ALARM_TYPE_GENERIC)
		return
	if(code != FIRELOCK_ALARM_TYPE_GENERIC && !COOLDOWN_FINISHED(src, activation_cooldown)) // Non generic activation, subject to crowbar safety
		// Properly activate once the timeleft's up
		addtimer(CALLBACK(src, PROC_REF(activate), code), COOLDOWN_TIMELEFT(src, activation_cooldown))
		return
	active = TRUE
	alarm_type = code
	add_as_source()
	update_appearance(UPDATE_ICON) //Sets the door lights even if the door doesn't move.
	correct_state()

/// Adds this fire door as a source of trouble to all of its areas
/obj/machinery/door/firedoor/proc/add_as_source()
	for(var/area/place in affecting_areas)
		LAZYADD(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks) != 1)
			continue
		//if we're the first to activate in this particular area
		place.set_fire_effect(TRUE, AREA_FAULT_AUTOMATIC, name) //bathe in red
		if(place == my_area)
			// We'll limit our reporting to just the area we're on. If the issue affects bordering areas, they can report it themselves
			place.alarm_manager.send_alarm(ALARM_FIRE, place)

/**
 * Proc that handles reset steps
 *
 * Clears the alarm state and attempts to open the firelock.
 */
/obj/machinery/door/firedoor/proc/reset()
	SIGNAL_HANDLER
	alarm_type = null
	active = FALSE
	remove_as_source()
	soundloop.stop()
	is_playing_alarm = FALSE
	update_appearance(UPDATE_ICON) //Sets the door lights even if the door doesn't move.
	correct_state()

/**
 * Open the firedoor without resetting existing alarms
 *
 * * delay - Reconsider if this door should be open or closed after some period
 *
 */
/obj/machinery/door/firedoor/proc/crack_open(delay)
	active = FALSE
	ignore_alarms = TRUE
	if(!length(issue_turfs)) // Generic alarms get out
		alarm_type = null

	soundloop.stop()
	is_playing_alarm = FALSE
	remove_as_source()
	update_appearance(UPDATE_ICON) //Sets the door lights even if the door doesn't move.
	correct_state()

	/// Please be called 3 seconds after the LAST open, rather then 3 seconds after the first
	addtimer(CALLBACK(src, PROC_REF(release_constraints)), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
 * Reset our temporary alarm ignoring
 * Consider if we should close ourselves/our neighbors or not
 */
/obj/machinery/door/firedoor/proc/release_constraints()
	ignore_alarms = FALSE
	if(!alarm_type || active) // If we have no alarm type, or are already active, go away
		return
	// Do we even care about temperature?
	for(var/area/place in affecting_areas)
		if(!place.fire_detect) // If any area is set to disable detection
			return
	// Otherwise, reactivate ourselves
	start_activation_process(alarm_type)

/// Removes this firedoor from all areas it's serving as a source of problems for
/obj/machinery/door/firedoor/proc/remove_as_source()
	for(var/area/place in affecting_areas)
		if(!LAZYLEN(place.active_firelocks)) // If it has no active firelocks, do nothing
			continue
		LAZYREMOVE(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks)) // If we were the last firelock still active, clear the area effects
			continue
		place.set_fire_effect(FALSE, AREA_FAULT_NONE, name)
		if(place == my_area)
			place.alarm_manager.clear_alarm(ALARM_FIRE, place)

/obj/machinery/door/firedoor/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	if(istype(emag_card, /obj/item/card/emag/doorjack)) //Skip doorjack-specific code
		var/obj/item/card/emag/doorjack/digital_crowbar = emag_card
		digital_crowbar.use_charge(user)
	obj_flags |= EMAGGED
	INVOKE_ASYNC(src, PROC_REF(open))
	return TRUE

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	return FALSE

/obj/machinery/door/firedoor/bumpopen(mob/living/user)
	return FALSE //No bumping to open, not even in mechs

/obj/machinery/door/firedoor/proc/on_power_loss()
	SIGNAL_HANDLER

	soundloop.stop()

/obj/machinery/door/firedoor/proc/on_power_restore()
	SIGNAL_HANDLER

	correct_state()

	if(is_playing_alarm)
		soundloop.start()


/obj/machinery/door/firedoor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(operating || !density)
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(!user.combat_mode)
		user.visible_message(span_notice("[user] knocks on [src]."), \
			span_notice("You knock on [src]."))
		playsound(src, knock_sound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] bashes [src]!"), \
			span_warning("You bash [src]!"))
		playsound(src, bash_sound, 100, TRUE)

/obj/machinery/door/firedoor/wrench_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	if(operating || !welded)
		return FALSE

	if(boltslocked)
		to_chat(user, span_notice("There are screws locking the bolts in place!"))
		return ITEM_INTERACT_SUCCESS
	tool.play_tool_sound(src)
	user.visible_message(span_notice("[user] starts undoing [src]'s bolts..."), \
		span_notice("You start unfastening [src]'s floor bolts..."))
	if(!tool.use_tool(src, user, DEFAULT_STEP_TIME))
		return ITEM_INTERACT_SUCCESS
	playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] unfastens [src]'s bolts."), \
		span_notice("You undo [src]'s floor bolts."))
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/door/firedoor/screwdriver_act(mob/living/user, obj/item/tool)
	if(operating || !welded)
		return FALSE
	user.visible_message(span_notice("[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts."), \
				span_notice("You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts."))
	tool.play_tool_sound(src)
	boltslocked = !boltslocked
	return ITEM_INTERACT_SUCCESS

/obj/machinery/door/firedoor/try_to_activate_door(mob/user, access_bypass = FALSE)
	return

/obj/machinery/door/firedoor/try_to_weld_secondary(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=1))
		return
	user.visible_message(span_notice("[user] starts [welded ? "unwelding" : "welding"] [src]."), span_notice("You start welding [src]."))
	if(W.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
		welded = !welded
		user.visible_message(span_danger("[user] [welded?"welds":"unwelds"] [src]."), span_notice("You [welded ? "weld" : "unweld"] [src]."))
		user.log_message("[welded ? "welded":"unwelded"] firedoor [src] with [W].", LOG_GAME)
		update_appearance()
		correct_state()

/// We check for adjacency when using the primary attack.
/obj/machinery/door/firedoor/try_to_crowbar(obj/item/acting_object, mob/user, forced = FALSE)
	if(welded || operating)
		return

	var/atom/crowbar_owner = acting_object?.loc || user // catches mechs and any other non-mob using a crowbar

	if(density)
		being_held_open = TRUE
		crowbar_owner.balloon_alert_to_viewers("holding firelock open", "holding firelock open")
		COOLDOWN_START(src, activation_cooldown, REACTIVATION_DELAY)
		open()
		if(QDELETED(crowbar_owner))
			being_held_open = FALSE
			return
		RegisterSignal(crowbar_owner, COMSIG_MOVABLE_MOVED, PROC_REF(handle_held_open_adjacency))
		RegisterSignal(crowbar_owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(handle_held_open_adjacency))
		RegisterSignal(crowbar_owner, COMSIG_QDELETING, PROC_REF(handle_held_open_adjacency))
		handle_held_open_adjacency(crowbar_owner)
	else
		close()

/// A simple toggle for firedoors between on and off
/obj/machinery/door/firedoor/try_to_crowbar_secondary(obj/item/acting_object, mob/user)
	if(welded || operating)
		return

	if(density)
		open()
		if(active)
			addtimer(CALLBACK(src, PROC_REF(correct_state)), 2 SECONDS, TIMER_UNIQUE)
	else
		close()

/obj/machinery/door/firedoor/proc/handle_held_open_adjacency(atom/crowbar_owner)
	SIGNAL_HANDLER


	if(!QDELETED(crowbar_owner) && crowbar_owner.CanReach(src))
		if(!ismob(crowbar_owner))
			return
		var/mob/living/mob_user = crowbar_owner
		if(isliving(mob_user) && (mob_user.body_position == STANDING_UP))
			return
	being_held_open = FALSE
	correct_state()
	UnregisterSignal(crowbar_owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(crowbar_owner, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(crowbar_owner, COMSIG_QDELETING)
	if(crowbar_owner)
		crowbar_owner.balloon_alert_to_viewers("released firelock", "released firelock")

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
		if(active)
			addtimer(CALLBACK(src, PROC_REF(correct_state)), 2 SECONDS, TIMER_UNIQUE)
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user, list/modifiers)
	add_fingerprint(user)
	if(welded)
		balloon_alert(user, "refuses to budge!")
		return
	open()
	if(active)
		addtimer(CALLBACK(src, PROC_REF(correct_state)), 2 SECONDS, TIMER_UNIQUE)

/obj/machinery/door/firedoor/update_icon_state()
	. = ..()
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			icon_state = "[base_icon_state]_opening"
		if(DOOR_CLOSING_ANIMATION)
			icon_state = "[base_icon_state]_closing"
		if(DOOR_DENY_ANIMATION)
			icon_state = "[base_icon_state]_deny"
		else
			icon_state = "[base_icon_state]_[density ? "closed" : "open"]"

/obj/machinery/door/firedoor/animation_length(animation)
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			return 1.2 SECONDS
		if(DOOR_CLOSING_ANIMATION)
			return 1.2 SECONDS
		if(DOOR_DENY_ANIMATION)
			return 0.3 SECONDS

/obj/machinery/door/firedoor/animation_segment_delay(animation)
	switch(animation)
		if(DOOR_OPENING_PASSABLE)
			return 1.0 SECONDS
		if(DOOR_OPENING_FINISHED)
			return 1.2 SECONDS
		if(DOOR_CLOSING_UNPASSABLE)
			return 0.2 SECONDS
		if(DOOR_CLOSING_FINISHED)
			return 1.2 SECONDS

/obj/machinery/door/firedoor/update_overlays()
	. = ..()
	if(welded)
		. += density ? "welded" : "welded_open"
	if(alarm_type && powered() && !ignore_alarms)
		var/mutable_appearance/hazards
		hazards = mutable_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]")
		hazards.pixel_w = light_xoffset
		hazards.pixel_z = light_yoffset
		. += hazards
		hazards = emissive_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]", src, alpha = src.alpha)
		hazards.pixel_w = light_xoffset
		hazards.pixel_z = light_yoffset
		. += hazards

/**
 * Corrects the current state of the door, based on its activity.
 *
 * This proc is called after weld and power restore events. Gives the
 * illusion that the door is constantly attempting to move without actually
 * having to process it. Timers also call this, so that if activity
 * changes during the timer, the door doesn't close or open incorrectly.
 */
/obj/machinery/door/firedoor/proc/correct_state()
	if(obj_flags & EMAGGED || being_held_open || QDELETED(src))
		return //Unmotivated, indifferent, we have no real care what state we're in anymore.
	if(active && !density) //We should be closed but we're not
		INVOKE_ASYNC(src, PROC_REF(close))
		return
	if(!active && density) //We should be open but we're not
		INVOKE_ASYNC(src, PROC_REF(open))
		return

/obj/machinery/door/firedoor/open()
	if(welded)
		return
	var/old_activity = active
	. = ..()
	if(old_activity != active) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	var/old_activity = active
	. = ..()
	if(old_activity != active) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/on_deconstruction(disassembled)
	var/turf/targetloc = get_turf(src)
	if(disassembled || prob(40))
		var/obj/structure/firelock_frame/unbuilt_lock = new assemblytype(targetloc)
		if(disassembled)
			unbuilt_lock.constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			unbuilt_lock.constructionStep = CONSTRUCTION_NO_CIRCUIT
			unbuilt_lock.update_integrity(unbuilt_lock.max_integrity * 0.5)
		unbuilt_lock.setDir(dir)
		unbuilt_lock.update_appearance()
	else
		new /obj/item/electronics/firelock (targetloc)

/obj/machinery/door/firedoor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	unregister_adjacent_turfs(old_loc)
	register_adjacent_turfs()

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	density = TRUE
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	can_crush = FALSE
	flags_1 = ON_BORDER_1
	can_atmos_pass = ATMOS_PASS_PROC
	assemblytype = /obj/structure/firelock_frame/border_only

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	density = TRUE
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC

/obj/machinery/door/firedoor/border_only/Initialize(mapload)
	. = ..()
	adjust_lights_starting_offset()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/door/firedoor/border_only/adjust_lights_starting_offset()
	light_xoffset = 0
	light_yoffset = 0
	switch(dir)
		if(NORTH)
			light_yoffset = 2
		if(SOUTH)
			light_yoffset = -2
		if(EAST)
			light_xoffset = 2
		if(WEST)
			light_xoffset = -2
	update_appearance(UPDATE_ICON)

/obj/machinery/door/firedoor/border_only/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	adjust_lights_starting_offset()

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!(border_dir == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return !density || (dir != to_dir)

/obj/machinery/door/firedoor/border_only/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving.movement_type & PHASING)
		return
	if(leaving == src)
		return // Let's not block ourselves.

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/firedoor/border_only/can_atmos_pass(turf/T, vertical = FALSE)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550


/obj/item/electronics/firelock
	name = "firelock circuitry"
	desc = "A circuit board used in construction of firelocks."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/doorfire.dmi'
	icon_state = "frame1"
	base_icon_state = "frame"
	anchored = FALSE
	density = TRUE
	var/constructionStep = CONSTRUCTION_NO_CIRCUIT
	var/reinforced = 0
	/// Is this a border_only firelock? Used in several checks during construction
	var/directional = FALSE

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += span_notice("It is <i>unbolted</i> from the floor. The circuit could be removed with a <b>crowbar</b>.")
			if(!reinforced && !directional)
				. += span_notice("It could be reinforced with plasteel.")
		if(CONSTRUCTION_NO_CIRCUIT)
			. += span_notice("There are no <i>firelock electronics</i> in the frame. The frame could be <b>welded</b> apart .")

/obj/structure/firelock_frame/update_icon_state()
	icon_state = "[base_icon_state][constructionStep]"
	return ..()

/obj/structure/firelock_frame/attackby(obj/item/attacking_object, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(attacking_object.tool_behaviour == TOOL_CROWBAR)
				attacking_object.play_tool_sound(src)
				user.visible_message(span_notice("[user] begins removing the circuit board from [src]..."), \
					span_notice("You begin prying out the circuit board from [src]..."))
				if(!attacking_object.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				user.visible_message(span_notice("[user] removes [src]'s circuit board."), \
					span_notice("You remove the circuit board from [src]."))
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NO_CIRCUIT
				update_appearance()
				return
			if(attacking_object.tool_behaviour == TOOL_WRENCH)
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					to_chat(user, span_warning("There's already a firelock there."))
					return
				attacking_object.play_tool_sound(src)
				user.visible_message(span_notice("[user] starts bolting down [src]..."), \
					span_notice("You begin bolting [src]..."))
				if(!attacking_object.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message(span_notice("[user] finishes the firelock."), \
					span_notice("You finish the firelock."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else if(directional)
					var/obj/machinery/door/firedoor/border_only/new_firedoor = new /obj/machinery/door/firedoor/border_only(get_turf(src))
					new_firedoor.setDir(dir)
					new_firedoor.adjust_lights_starting_offset()
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(attacking_object, /obj/item/stack/sheet/plasteel))
				if(directional)
					to_chat(user, span_warning("[src] can not be reinforced."))
					return
				var/obj/item/stack/sheet/plasteel/plasteel_sheet = attacking_object
				if(reinforced)
					to_chat(user, span_warning("[src] is already reinforced."))
					return
				if(plasteel_sheet.get_amount() < 2)
					to_chat(user, span_warning("You need more plasteel to reinforce [src]."))
					return
				user.visible_message(span_notice("[user] begins reinforcing [src]..."), \
					span_notice("You begin reinforcing [src]..."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(do_after(user, DEFAULT_STEP_TIME, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || plasteel_sheet.get_amount() < 2 || !plasteel_sheet)
						return
					user.visible_message(span_notice("[user] reinforces [src]."), \
						span_notice("You reinforce [src]."))
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
					plasteel_sheet.use(2)
					reinforced = 1
				return
		if(CONSTRUCTION_NO_CIRCUIT)
			if(istype(attacking_object, /obj/item/electronics/firelock))
				user.visible_message(span_notice("[user] starts adding [attacking_object] to [src]..."), \
					span_notice("You begin adding a circuit board to [src]..."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(!do_after(user, DEFAULT_STEP_TIME, target = src))
					return
				if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
					return
				qdel(attacking_object)
				user.visible_message(span_notice("[user] adds a circuit to [src]."), \
					span_notice("You insert and secure [attacking_object]."))
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_appearance()
				return
			if(attacking_object.tool_behaviour == TOOL_WELDER)
				if(!attacking_object.tool_start_check(user, amount=1))
					return
				user.visible_message(span_notice("[user] begins cutting apart [src]'s frame..."), \
					span_notice("You begin slicing [src] apart..."))

				if(attacking_object.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
					if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
						return
					user.visible_message(span_notice("[user] cuts apart [src]!"), \
						span_notice("You cut [src] into metal."))
					var/turf/targetloc = get_turf(src)
					new /obj/item/stack/sheet/iron(targetloc, directional ? 2 : 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(targetloc, 2)
					qdel(src)
				return
			if(istype(attacking_object, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/raspberrypi = attacking_object
				if(!raspberrypi.adapt_circuit(user, circuit_cost = DEFAULT_STEP_TIME * 0.0005 * STANDARD_CELL_CHARGE))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt a firelock circuit and slot it into the assembly."))
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_appearance()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 5 SECONDS, "cost" = 16)
	else if((constructionStep == CONSTRUCTION_NO_CIRCUIT) && (the_rcd.construction_upgrades & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("delay" = 2 SECONDS, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.balloon_alert(user, "circuit installed")
			constructionStep = CONSTRUCTION_PANEL_OPEN
			update_appearance()
			return TRUE
		if(RCD_DECONSTRUCT)
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE

/obj/structure/firelock_frame/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	directional = TRUE

/obj/structure/firelock_frame/border_only/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/firelock_frame/border_only/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return // Let's not block ourselves.

	if(!(direction & dir))
		return

	if (!density)
		return

	if (leaving.movement_type & (PHASING))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/firelock_frame/border_only/CanPass(atom/movable/mover, border_dir)
	return border_dir & dir ? ..() : TRUE

#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_NO_CIRCUIT
#undef REACTIVATION_DELAY
#undef DEFAULT_STEP_TIME
