#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_NO_CIRCUIT 2 //Circuit board removed, can safely weld apart
#define DEFAULT_STEP_TIME 20 /// default time for each step
#define DETECT_COOLDOWN_STEP_TIME 5 SECONDS ///Wait time before we can detect an issue again, after a recent clear.

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "Apply crowbar."
	icon = 'icons/obj/doors/Doorfireglass.dmi'
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
	assemblytype = /obj/structure/firelock_frame
	armor = list(MELEE = 10, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, FIRE = 95, ACID = 70)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN

	COOLDOWN_DECLARE(detect_cooldown)

	///Trick to get the glowing overlay visible from a distance
	luminosity = 1
	///X offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_xoffset = 0
	///Y offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_yoffset = 0

	var/boltslocked = TRUE
	///List of areas we handle. See CalculateAffectingAreas()
	var/list/affecting_areas
	///For the few times we affect only the area we're actually in. Set during Init. If we get moved, we don't update, but this is consistant with fire alarms and also kinda funny so call it intentional.
	var/area/my_area
	///Tracks if the firelock is being held open by a crowbar. If so, we don't close until they walk away
	var/being_held_open = FALSE

	///Type of alarm when active. See code/defines/firealarm.dm for the list. This var being null means there is no alarm.
	var/alarm_type = null
	///The merger_id and merger_typecache variables are used to make rows of firelocks activate at the same time.
	var/merger_id = "firelocks"
	var/static/list/merger_typecache
	///Overlay object for the warning lights. This and some plane settings allows the lights to glow in the dark.
	var/mutable_appearance/warn_lights

	///looping sound datum for our fire alarm siren.
	var/datum/looping_sound/firealarm/soundloop

	var/knock_sound = 'sound/effects/glassknock.ogg'
	var/bash_sound = 'sound/effects/glassbash.ogg'


/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	COOLDOWN_START(src, detect_cooldown, DETECT_COOLDOWN_STEP_TIME)
	soundloop = new(src, FALSE)
	AddElement(/datum/element/atmos_sensitive, mapload)
	CalculateAffectingAreas()
	my_area = get_area(src)
	var/static/list/loc_connections = list(
		COMSIG_TURF_EXPOSE = .proc/check_atmos,
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	if(!merger_typecache)
		merger_typecache = typecacheof(/obj/machinery/door/firedoor)

	check_atmos()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/firedoor/LateInitialize()
	. = ..()
	GetMergeGroup(merger_id, allowed_types = merger_typecache)

/**
 * Sets the offset for the warning lights.
 *
 * Used for special firelocks with light overlays that don't line up to their sprite.
 */
/obj/machinery/door/firedoor/proc/adjust_lights_starting_offset()
	return

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
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
		if(alarm_type)
			if(place == get_area(src))
				LAZYADD(place.active_firelocks, src) //We only add ourselves to our own area's active firelocks...
			for(var/obj/machinery/firealarm/fire_panel in place.firealarms)
				fire_panel.set_status() //...but all adjacent fire alarms are notified

/**
 * Removes us from any lists of areas in the affecting_areas list, then clears affecting_areas
 *
 * Undoes everything done in the CalculateAffectingAreas() proc, to clean up prior to deletion.
 * Calls reset() first, in case any alarms need to be cleared first.
 */
/obj/machinery/door/firedoor/proc/remove_from_areas()
	if(!affecting_areas)
		return
	for(var/area/place in affecting_areas)
		LAZYREMOVE(place.firedoors, src)
		LAZYREMOVE(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks)) //if we were the last firelock still active in this particular area
			continue
		for(var/obj/machinery/firealarm/fire_panel in place.firealarms)
			fire_panel.set_status()

/obj/machinery/door/firedoor/proc/check_atmos(datum/source)
	if(!COOLDOWN_FINISHED(src, detect_cooldown))
		return
	if(alarm_type)
		return
	for(var/area/place in affecting_areas)
		if(!place.fire_detect) //if any area is set to disable detection
			return

	var/turf/my_turf = source
	if(!my_turf)
		my_turf = get_turf(src)

	var/datum/gas_mixture/environment = my_turf.return_air()
	var/result

	if(environment?.temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		result = FIRELOCK_ALARM_TYPE_HOT
	if(environment?.temperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
		result = FIRELOCK_ALARM_TYPE_COLD
	if(!result)
		return

	start_activation_process(result)

/**
 * Begins activation process of us and our neighbors.
 *
 * This proc will call activate() on every fire lock (including us) listed
 * in the merge group datum. Returns without doing anything if our alarm_type
 * was already set, as that means that we're already active.
 *
 * Arguments:
 * code should be one of three defined alarm types, or can be not supplied. Will dictate the color of the fire alarm lights, and defults to "firelock_alarm_type_generic"
 */
/obj/machinery/door/firedoor/proc/start_activation_process(code = FIRELOCK_ALARM_TYPE_GENERIC)
	if(alarm_type)
		return //We're already active
	soundloop.start()
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group.members)
		buddylock.activate(code)


/**
 * Proc that handles activation of the firelock and all this details
 *
 * Sets the alarm_type variable based on the single arg, which is in turn
 * used by several procs to understand the intended state of the fire lock.
 * Also calls set_status() on all fire alarms in all affected areas, tells
 * the area the firelock sits in to report the event (AI, alarm consoles, etc)
 * and finally calls correct_state(), which will handle opening or closing
 * this fire lock.
 */
/obj/machinery/door/firedoor/proc/activate(code = FIRELOCK_ALARM_TYPE_GENERIC)
	SIGNAL_HANDLER
	if(alarm_type)
		return //Already active
	alarm_type = code
	for(var/area/place in affecting_areas)
		LAZYADD(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks) == 1) //if we're the first to activate in this particular area
			for(var/obj/machinery/firealarm/fire_panel in place.firealarms)
				fire_panel.set_status()
			if(place == my_area)
				place.alarm_manager.send_alarm(ALARM_FIRE, place) //We'll limit our reporting to just the area we're on. If the issue affects bordering areas, they can report it themselves
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

/**
 * Proc that handles reset steps
 *
 * Clears the alarm state and attempts to open the firelock.
 */
/obj/machinery/door/firedoor/proc/reset()
	SIGNAL_HANDLER
	alarm_type = null
	for(var/area/place in affecting_areas)
		LAZYREMOVE(place.active_firelocks, src)
		if(!LAZYLEN(place.active_firelocks)) //if we were the last firelock still active in this particular area
			for(var/obj/machinery/firealarm/fire_panel in place.firealarms)
				fire_panel.set_status()
	COOLDOWN_START(src, detect_cooldown, DETECT_COOLDOWN_STEP_TIME)
	soundloop.stop()
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

/obj/machinery/door/firedoor/emag_act(mob/user, obj/item/card/emag/doorjack/digital_crowbar)
	if(obj_flags & EMAGGED)
		return
	if(!isAI(user)) //Skip doorjack-specific code
		if(!user || digital_crowbar.charges < 1)
			return
		digital_crowbar.use_charge(user)
	obj_flags |= EMAGGED
	INVOKE_ASYNC(src, .proc/open)

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	return FALSE

/obj/machinery/door/firedoor/bumpopen(mob/living/user)
	return FALSE //No bumping to open, not even in mechs

/obj/machinery/door/firedoor/power_change()
	. = ..()
	update_icon()
	correct_state()

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

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return
	if(welded)
		if(C.tool_behaviour == TOOL_WRENCH)
			if(boltslocked)
				to_chat(user, span_notice("There are screws locking the bolts in place!"))
				return
			C.play_tool_sound(src)
			user.visible_message(span_notice("[user] starts undoing [src]'s bolts..."), \
				span_notice("You start unfastening [src]'s floor bolts..."))
			if(!C.use_tool(src, user, DEFAULT_STEP_TIME))
				return
			playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
			user.visible_message(span_notice("[user] unfastens [src]'s bolts."), \
				span_notice("You undo [src]'s floor bolts."))
			deconstruct(TRUE)
			return
		if(C.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message(span_notice("[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts."), \
				span_notice("You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts."))
			C.play_tool_sound(src)
			boltslocked = !boltslocked
			return
	return ..()

/obj/machinery/door/firedoor/try_to_activate_door(mob/user, access_bypass = FALSE)
	return

/obj/machinery/door/firedoor/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message(span_notice("[user] starts [welded ? "unwelding" : "welding"] [src]."), span_notice("You start welding [src]."))
	if(W.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
		welded = !welded
		user.visible_message(span_danger("[user] [welded?"welds":"unwelds"] [src]."), span_notice("You [welded ? "weld" : "unweld"] [src]."))
		log_game("[key_name(user)] [welded ? "welded":"unwelded"] firedoor [src] with [W] at [AREACOORD(src)]")
		update_appearance()
		correct_state()

/// We check for adjacency when using the primary attack.
/obj/machinery/door/firedoor/try_to_crowbar(obj/item/acting_object, mob/user)
	if(welded || operating)
		return

	if(density)
		being_held_open = TRUE
		user.balloon_alert_to_viewers("holding [src] open", "holding [src] open")
		open()
		if(QDELETED(user))
			being_held_open = FALSE
			return
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/handle_held_open_adjacency)
		RegisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION, .proc/handle_held_open_adjacency)
		RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/handle_held_open_adjacency)
		handle_held_open_adjacency(user)
	else
		close()

/// A simple toggle for firedoors between on and off
/obj/machinery/door/firedoor/try_to_crowbar_secondary(obj/item/acting_object, mob/user)
	if(welded || operating)
		return

	if(density)
		open()
		if(alarm_type)
			addtimer(CALLBACK(src, .proc/correct_state), 2 SECONDS, TIMER_UNIQUE)
	else
		close()

/obj/machinery/door/firedoor/proc/handle_held_open_adjacency(mob/user)
	SIGNAL_HANDLER

	var/mob/living/living_user = user
	if(!QDELETED(user) && Adjacent(user) && isliving(user) && (living_user.body_position == STANDING_UP))
		return
	being_held_open = FALSE
	correct_state()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	if(user)
		user.balloon_alert_to_viewers("released [src]", "released [src]")

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
		if(alarm_type)
			addtimer(CALLBACK(src, .proc/correct_state), 2 SECONDS, TIMER_UNIQUE)
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user, list/modifiers)
	add_fingerprint(user)
	if(welded)
		to_chat(user, span_warning("[src] refuses to budge!"))
		return
	open()
	if(alarm_type)
		addtimer(CALLBACK(src, .proc/correct_state), 2 SECONDS, TIMER_UNIQUE)

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[density ? "closed" : "open"]"

/obj/machinery/door/firedoor/update_overlays()
	. = ..()
	if(welded)
		. += density ? "welded" : "welded_open"
	if(alarm_type && powered())
		var/mutable_appearance/hazards
		hazards = mutable_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]")
		hazards.pixel_x = light_xoffset
		hazards.pixel_y = light_yoffset
		. += hazards
		hazards = emissive_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]", alpha = src.alpha)
		hazards.pixel_x = light_xoffset
		hazards.pixel_y = light_yoffset
		. += hazards

/**
 * Corrects the current state of the door, based on if alarm_type is set.
 *
 * This proc is called after weld and power restore events. Gives the
 * illusion that the door is constantly attempting to move without actually
 * having to process it. Timers also call this, so that if alarm_type
 * changes during the timer, the door doesn't close or open incorrectly.
 */
/obj/machinery/door/firedoor/proc/correct_state()
	if(obj_flags & EMAGGED || being_held_open)
		return //Unmotivated, indifferent, we have no real care what state we're in anymore.
	if(alarm_type && !density) //We should be closed but we're not
		INVOKE_ASYNC(src, .proc/close)
		return
	if(!alarm_type && density) //We should be open but we're not
		INVOKE_ASYNC(src, .proc/open)
		return

/obj/machinery/door/firedoor/open()
	if(welded)
		return
	var/alarm = alarm_type
	. = ..()
	if(alarm != alarm_type) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	var/alarm = alarm_type
	. = ..()
	if(alarm != alarm_type) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/targetloc = get_turf(src)
		if(disassembled || prob(40))
			var/obj/structure/firelock_frame/unbuilt_lock = new assemblytype(targetloc)
			if(disassembled)
				unbuilt_lock.constructionStep = CONSTRUCTION_PANEL_OPEN
			else
				unbuilt_lock.constructionStep = CONSTRUCTION_NO_CIRCUIT
				unbuilt_lock.update_integrity(unbuilt_lock.max_integrity * 0.5)
			unbuilt_lock.update_appearance()
		else
			new /obj/item/electronics/firelock (targetloc)
	qdel(src)

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	density = TRUE

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	can_crush = FALSE
	flags_1 = ON_BORDER_1
	can_atmos_pass = ATMOS_PASS_PROC

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	density = TRUE

/obj/machinery/door/firedoor/border_only/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	adjust_lights_starting_offset()

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
	update_icon()

/obj/machinery/door/firedoor/border_only/Moved()
	. = ..()
	adjust_lights_starting_offset()

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!(border_dir == dir)) //Make sure looking at appropriate border
		return TRUE

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
	icon = 'icons/obj/doors/Doorfire.dmi'
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
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "frame1"
	base_icon_state = "frame"
	anchored = FALSE
	density = TRUE
	var/constructionStep = CONSTRUCTION_NO_CIRCUIT
	var/reinforced = 0

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += span_notice("It is <i>unbolted</i> from the floor. The circuit could be removed with a <b>crowbar</b>.")
			if(!reinforced)
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
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(attacking_object, /obj/item/stack/sheet/plasteel))
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
				return
			if(attacking_object.tool_behaviour == TOOL_WELDER)
				if(!attacking_object.tool_start_check(user, amount=1))
					return
				user.visible_message(span_notice("[user] begins cutting apart [src]'s frame..."), \
					span_notice("You begin slicing [src] apart..."))

				if(attacking_object.use_tool(src, user, DEFAULT_STEP_TIME, volume=50, amount=1))
					if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
						return
					user.visible_message(span_notice("[user] cuts apart [src]!"), \
						span_notice("You cut [src] into metal."))
					var/turf/tagetloc = get_turf(src)
					new /obj/item/stack/sheet/iron(tagetloc, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(tagetloc, 2)
					qdel(src)
				return
			if(istype(attacking_object, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/raspberrypi = attacking_object
				if(!raspberrypi.adapt_circuit(user, DEFAULT_STEP_TIME * 0.5))
					return
				user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
				span_notice("You adapt a firelock circuit and slot it into the assembly."))
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_appearance()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 16)
	else if((constructionStep == CONSTRUCTION_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message(span_notice("[user] fabricates a circuit and places it into [src]."), \
			span_notice("You adapt a firelock circuit and slot it into the assembly."))
			constructionStep = CONSTRUCTION_PANEL_OPEN
			update_appearance()
			return TRUE
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct [src]."))
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE

#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_NO_CIRCUIT
#undef DETECT_COOLDOWN_STEP_TIME
