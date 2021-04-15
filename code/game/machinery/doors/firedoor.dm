#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_NO_CIRCUIT 2 //Circuit board removed, can safely weld apart
#define DEFAULT_STEP_TIME 20 /// default time for each step
#define MINIMUM_TEMPERATURE_TO_BURN_ARMS 500 ///everything above this temperature will start burning unprotected arms
#define TOOLLESS_OPEN_DURATION_SOLO (20 SECONDS) ///opening a firelock without a tool takes this long if only one person is doing it
#define TOOLLESS_BURN_DAMAGE_PER_SECOND 5 ///how much burn
#define TRUE_OPENING_TIME max(TOOLLESS_OPEN_DURATION_SOLO / max(length(people_trying_to_open) * 0.75, 1), 2 SECONDS)

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
	armor = list(MELEE = 10, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 100, FIRE = 95, ACID = 70)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	var/nextstate = null
	var/boltslocked = TRUE
	var/list/affecting_areas
	///the list of people trying to open this firelock without any tools
	var/list/people_trying_to_open = list()
	var/being_held_open = FALSE

/obj/machinery/door/firedoor/Initialize()
	. = ..()
	CalculateAffectingAreas()

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(!density)
		. += "<span class='notice'>It is open, but could be <b>pried</b> closed.</span>"
	else if(!welded)
		. += "<span class='notice'>It is closed, but could be <b>pried</b> open.</span>"
		. += "<span class='notice'>Hold the door open by prying it with <i>left-click</i> and standing next to it.</span>"
		. += "<span class='notice'>Prying by <i>right-clicking</i> the door will simply open it.</span>"
		. += "<span class='notice'>Deconstruction would require it to be <b>welded</b> shut.</span>"
	else if(boltslocked)
		. += "<span class='notice'>It is <i>welded</i> shut. The floor bolts have been locked by <b>screws</b>.</span>"
	else
		. += "<span class='notice'>The bolt locks have been <i>unscrewed</i>, but the bolts themselves are still <b>wrenched</b> to the floor.</span>"

/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	remove_from_areas()
	affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	for(var/I in affecting_areas)
		var/area/A = I
		LAZYADD(A.firedoors, src)

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	density = TRUE

//see also turf/AfterChange for adjacency shennanigans

/obj/machinery/door/firedoor/proc/remove_from_areas()
	if(affecting_areas)
		for(var/I in affecting_areas)
			var/area/A = I
			LAZYREMOVE(A.firedoors, src)

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	affecting_areas.Cut()
	return ..()

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
	INVOKE_ASYNC(src, .proc/latetoggle)

/obj/machinery/door/firedoor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(operating || !density)
		return
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(living_user.combat_mode)
		living_user.changeNext_move(CLICK_CD_MELEE)
		living_user.visible_message("<span class='notice'>[living_user] bangs on [src].</span>", \
			"<span class='notice'>You bang on [src].</span>")
		playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)
	else
		if(DOING_INTERACTION(living_user, DOAFTER_SOURCE_BAREHAND_FIRELOCK_OPEN))//you get one firelock to open, better pick the right one
			return

		//dont want them to be moved by pressure differences when theyre holding onto the firelock with all their strength
		living_user.move_resist = MOVE_FORCE_VERY_STRONG

		//starting stats in order to write logs that provide enough data to make kickass fucking graphs later
		var/starting_health = living_user.health
		var/starting_time = REALTIMEOFDAY

		var/datum/gas_mixture/users_air = living_user.return_air()
		var/user_loc_starting_temperature = users_air.temperature

		///used so that we can log everyone's stats once when the do_after finishes
		var/list/user_stat_list = list(list("user" = living_user, "starting temperature" = user_loc_starting_temperature, "starting health" = starting_health, "starting time" = starting_time))
		people_trying_to_open += user_stat_list
		RegisterSignal(living_user, COMSIG_PARENT_PREQDELETED, .proc/remove_from_opening_list)

		///we dont want people with only one hand to have the same visible_message as people with two hands
		var/hand_string = "hands"
		if(iscarbon(living_user))
			var/mob/living/carbon/carbon_user = living_user
			var/obj/item/bodypart/right_arm = carbon_user.get_bodypart(BODY_ZONE_R_ARM)
			var/obj/item/bodypart/left_arm = carbon_user.get_bodypart(BODY_ZONE_L_ARM)

			if(!right_arm || right_arm.bodypart_disabled)//this is assuming that you have at least one hand since... this proc is called attack_hand
				hand_string = "hand"
			if(!left_arm || left_arm.bodypart_disabled)
				hand_string = "hand"

		var/user_their_pronoun = user.p_their()
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			user_their_pronoun = human_user.p_their()

		//we want to acknowledge that several people are trying to open the same firelock to encourage them to do it
		//also to signal to people doing it by themselves that its faster with help
		if(length(people_trying_to_open) == 1)
			user.visible_message("<span class='notice'>[living_user] tries to open [src] with [user_their_pronoun] [hand_string], struggling greatly to open the heavy door by themselves.</span>", \
				"<span class='notice'>You try with all your strength to pry open [src] with your [hand_string], barely moving [p_them()]!</span>")
		else if (length(people_trying_to_open) == 2)
			user.visible_message("<span class='notice'>[living_user] joins [people_trying_to_open[1]["user"]] in trying to open [src] with [user_their_pronoun] [hand_string].</span>", \
				"<span class='notice'>You join [people_trying_to_open[1]] in trying to pry open [src] with your [hand_string]!</span>")
		else
			user.visible_message("<span class='notice'>[living_user] joins the others in trying to open [src] with [user_their_pronoun] [hand_string]!</span>", \
				"<span class='notice'>You join the others in trying to pry open [src] with your [hand_string]!</span>")

		//stops the do_after if the firelock is open
		var/datum/callback/is_closed_callback = CALLBACK(src, .proc/is_closed)

		//this callback adjusts the timer of the do_after_dynamic for each user if the number of people trying to open the firelock changes
		var/datum/callback/timer_callback = CALLBACK(src, .proc/adjust_do_after_timer)

		START_PROCESSING(SSmachines, src)//burns the arms of everyone trying to open the firelock if its hot enough and they dont have protection

		//TODOKYLER: the progress bar is inaccurate for teaming up, and only the first person will succeed, this needs to be centralized to work
		///players can team up to open it faster. 20 seconds -> 13.333 -> 8.88 ... -> 2
		if(do_after_dynamic(user, TRUE_OPENING_TIME, src, extra_checks = is_closed_callback, interaction_key = DOAFTER_SOURCE_BAREHAND_FIRELOCK_OPEN, max_interact_count = 1,  dynamic_timer_change = timer_callback))
			user.visible_message("<span class='notice'>[living_user] opens [src] with [user.p_their()] [hand_string].</span>", \
				self_message = "<span class='notice'>You pry open [src] with your [hand_string]!</span>")

			barehanded_open_log(TRUE, user)

			open()

		else //user failed to open it
			barehanded_open_log(FALSE, user)

		people_trying_to_open -= user_stat_list
		UnregisterSignal(user, COMSIG_PARENT_PREQDELETED)
		user.move_resist = initial(user.move_resist)

/obj/machinery/door/firedoor/attack_paw(mob/living/user, list/modifiers)
	. = ..()
	if(!user.combat_mode)
		attack_hand(user, modifiers)

/**
 * deals with logging either when failing or succeeding to open a firelock without a crowbar.
 * everyone trying to open it are logged individually, regardless of whether theres more than one trying to do so
 * * success - whether or not the user opened it successfully
 * * user - the person who either succeeded or failed in opening it, returns if not specified
 */
/obj/machinery/door/firedoor/proc/barehanded_open_log(success, mob/living/user)
	if(QDELETED(user) || !isliving(user))
		return

	var/list/user_stat_list

	var/user_opening_duration

	var/end_temperature_of_user

	var/user_damage_taken

	var/user_has_internals = "false"

	for(var/list/user_list as anything in people_trying_to_open)
		if(user_list["user"] == user)
			user_stat_list = user_list
			break

	if(!user_stat_list)
		return

	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.internal)
			user_has_internals = "true"
	user_opening_duration = (REALTIMEOFDAY - user_stat_list["starting time"]) / 10

	user_damage_taken = user.health - user_stat_list["starting health"]

	var/datum/gas_mixture/user_environment = user.return_air()
	end_temperature_of_user = user_environment.temperature

	if(success || (!density && user.stat == CONSCIOUS)) //if we're open and the user is conscious, then no matter what we're called with its a success
		SSblackbox.record_feedback("associative", "barehand firelock opens", 1, \
		list( \
		"user" = key_name(user), \
		"starting temperature" = user_stat_list["starting temperature"], \
		"ending temperature" = end_temperature_of_user, \
		"user damage taken" = user_damage_taken, \
		"size of group trying to open" = length(people_trying_to_open), \
		"user has internals on" = user_has_internals \
		))

	else
		var/failure_health_state_string = "conscious"
		switch(user.stat)
			if(CONSCIOUS)
				failure_health_state_string = "conscious"
			if(SOFT_CRIT)
				failure_health_state_string = "soft crit"
			if(UNCONSCIOUS)
				failure_health_state_string = "unconscious"
			if(HARD_CRIT)
				failure_health_state_string = "hard crit"
			if(DEAD)
				failure_health_state_string = "dead"

		SSblackbox.record_feedback("associative", "barehand firelock failures", 1, \
		list( \
		"user" = key_name(user), \
		"starting temperature" = user_stat_list["starting temperature"], \
		"ending temperature" = end_temperature_of_user, \
		"user attempt duration" = user_opening_duration, \
		"user damage taken" = user_damage_taken, \
		"user stat" = failure_health_state_string, \
		"size of group trying to open" = length(people_trying_to_open), \
		"user has internals on" = user_has_internals \
		))


///deals burn damage to the user depending on whether theyre resistant to heat and how hot the door is
/obj/machinery/door/firedoor/process(delta_time)
	if(!length(people_trying_to_open))
		return PROCESS_KILL
	for(var/list/user_stat_list as anything in people_trying_to_open)
		var/mob/living/user = user_stat_list["user"]
		if(QDELETED(user))
			people_trying_to_open -= user_stat_list
			continue
		//figure out how "hot" the door is with the temperature of the turf we are on and the user touching us, remember we dont conduct heat to the other side
		var/datum/gas_mixture/our_air = return_air()
		var/our_temperature = our_air.temperature
		var/datum/gas_mixture/users_air = user.return_air()
		var/users_temperature = users_air.temperature

		var/heat_of_contact_surface = max(our_temperature, users_temperature)

		if(heat_of_contact_surface < MINIMUM_TEMPERATURE_TO_BURN_ARMS)
			return

		var/heat_protected = HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS)

		if(!iscarbon(user))
			if(!heat_protected)
				user.adjustFireLoss(TOOLLESS_BURN_DAMAGE_PER_SECOND, forced = TRUE)
			return

		var/mob/living/carbon/carbon_user = user

		if(carbon_user.gloves)
			var/obj/item/clothing/gloves/gloves_of_user = carbon_user.gloves

			if(gloves_of_user.max_heat_protection_temperature)
				heat_protected = heat_protected || (gloves_of_user.max_heat_protection_temperature >= heat_of_contact_surface)

		if(!heat_protected)
			var/obj/item/bodypart/right_arm = carbon_user.get_bodypart(BODY_ZONE_R_ARM)
			var/obj/item/bodypart/left_arm = carbon_user.get_bodypart(BODY_ZONE_L_ARM)

			if(DT_PROB(30, delta_time))
				playsound(carbon_user, 'sound/effects/wounds/sizzle1.ogg', 70)

			if(right_arm && right_arm.status == BODYPART_ORGANIC && !right_arm.is_pseudopart)
				right_arm.receive_damage(0, TOOLLESS_BURN_DAMAGE_PER_SECOND)
			if(left_arm && left_arm.status == BODYPART_ORGANIC && !left_arm.is_pseudopart)
				left_arm.receive_damage(0, TOOLLESS_BURN_DAMAGE_PER_SECOND)

///used in a callback given to do_after_dynamic to adjust the timer based on how many people are trying to open it barehanded
/obj/machinery/door/firedoor/proc/adjust_do_after_timer(old_delay, multiplicative_action_slowdown)
	if(old_delay == (TRUE_OPENING_TIME) * multiplicative_action_slowdown)
		return null
	else
		return (TRUE_OPENING_TIME) * multiplicative_action_slowdown

///used as a callback in dynamic do_after, returns FALSE if the firelock is opened, stopping the do_after
/obj/machinery/door/firedoor/proc/is_closed()
	if(density)
		return TRUE
	else
		return FALSE

/obj/machinery/door/firedoor/proc/remove_from_opening_list(datum/source, mob/living/to_remove)
	SIGNAL_HANDLER
	for(var/list/user_stat_list as anything in people_trying_to_open)
		if(user_stat_list["user"] == to_remove)
			people_trying_to_open -= user_stat_list
			return

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return
	if(welded)
		if(C.tool_behaviour == TOOL_WRENCH)
			if(boltslocked)
				to_chat(user, "<span class='notice'>There are screws locking the bolts in place!</span>")
				return
			C.play_tool_sound(src)
			user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
				"<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
			if(!C.use_tool(src, user, DEFAULT_STEP_TIME))
				return
			playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
				"<span class='notice'>You undo [src]'s floor bolts.</span>")
			deconstruct(TRUE)
			return
		if(C.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts.</span>", \
				"<span class='notice'>You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts.</span>")
			C.play_tool_sound(src)
			boltslocked = !boltslocked
			return
	. = ..()

/obj/machinery/door/firedoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/firedoor/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message("<span class='notice'>[user] starts [welded ? "unwelding" : "welding"] [src].</span>", "<span class='notice'>You start welding [src].</span>")
	if(W.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
		welded = !welded
		to_chat(user, "<span class='danger'>[user] [welded?"welds":"unwelds"] [src].</span>", "<span class='notice'>You [welded ? "weld" : "unweld"] [src].</span>")
		log_game("[key_name(user)] [welded ? "welded":"unwelded"] firedoor [src] with [W] at [AREACOORD(src)]")
		update_appearance()

/// We check for adjacency when using the primary attack.
/obj/machinery/door/firedoor/try_to_crowbar(obj/item/acting_object, mob/user)
	if(welded || operating)
		return

	if(density)
		being_held_open = TRUE
		if(length(people_trying_to_open))
			user.visible_message("<span class='notice'>[user] easily opens [src] with his crowbar.</span>")
			SSblackbox.record_feedback("tally","firedoor crowbar opens", 1, "with barehanded openers")
			people_trying_to_open = list()
		else
			SSblackbox.record_feedback("tally", "firedoor crowbar opens", 1, "without barehanded openers")
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

/obj/machinery/door/firedoor/proc/handle_held_open_adjacency(mob/user)
	SIGNAL_HANDLER

	//Handle qdeletion here
	if(QDELETED(user))
		being_held_open = FALSE
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION)
		UnregisterSignal(user, COMSIG_PARENT_QDELETING)
		return

	var/mob/living/living_user = user
	if(Adjacent(user) && isliving(user) && (living_user.body_position == STANDING_UP))
		return
	being_held_open = FALSE
	INVOKE_ASYNC(src, .proc/close)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(user, COMSIG_PARENT_QDELETING)

/// A simple toggle for firedoors between on and off
/obj/machinery/door/firedoor/try_to_crowbar_secondary(obj/item/acting_object, mob/user)
	if(welded || operating)
		return

	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user, list/modifiers)
	add_fingerprint(user)
	if(welded)
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	open()

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
	if(!welded)
		return
	. += density ? "welded" : "welded_open"

/obj/machinery/door/firedoor/open()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(disassembled || prob(40))
			var/obj/structure/firelock_frame/F = new assemblytype(T)
			if(disassembled)
				F.constructionStep = CONSTRUCTION_PANEL_OPEN
			else
				F.constructionStep = CONSTRUCTION_NO_CIRCUIT
				F.obj_integrity = F.max_integrity * 0.5
			F.update_appearance()
		else
			new /obj/item/electronics/firelock (T)
	qdel(src)


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || machine_stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(FIREDOOR_OPEN)
			nextstate = null
			open()
		if(FIREDOOR_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	can_crush = FALSE
	flags_1 = ON_BORDER_1
	CanAtmosPass = ATMOS_PASS_PROC
	glass = FALSE

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE

/obj/machinery/door/firedoor/border_only/Initialize()
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, src, loc_connections)

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!(get_dir(loc, target) == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/proc/on_exit(datum/source, atom/movable/leaving, atom/new_location)
	SIGNAL_HANDLER

	if(get_dir(leaving.loc, new_location) == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
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
			. += "<span class='notice'>It is <i>unbolted</i> from the floor. The circuit could be removed with a <b>crowbar</b>.</span>"
			if(!reinforced)
				. += "<span class='notice'>It could be reinforced with plasteel.</span>"
		if(CONSTRUCTION_NO_CIRCUIT)
			. += "<span class='notice'>There are no <i>firelock electronics</i> in the frame. The frame could be <b>welded</b> apart .</span>"

/obj/structure/firelock_frame/update_icon_state()
	icon_state = "[base_icon_state][constructionStep]"
	return ..()

/obj/structure/firelock_frame/attackby(obj/item/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
					"<span class='notice'>You begin prying out the circuit board from [src]...</span>")
				if(!C.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
					"<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NO_CIRCUIT
				update_appearance()
				return
			if(C.tool_behaviour == TOOL_WRENCH)
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					to_chat(user, "<span class='warning'>There's already a firelock there.</span>")
					return
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
					"<span class='notice'>You begin bolting [src]...</span>")
				if(!C.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message("<span class='notice'>[user] finishes the firelock.</span>", \
					"<span class='notice'>You finish the firelock.</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(C, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = C
				if(reinforced)
					to_chat(user, "<span class='warning'>[src] is already reinforced.</span>")
					return
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to reinforce [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins reinforcing [src]...</span>", \
					"<span class='notice'>You begin reinforcing [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(do_after(user, DEFAULT_STEP_TIME, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || P.get_amount() < 2 || !P)
						return
					user.visible_message("<span class='notice'>[user] reinforces [src].</span>", \
						"<span class='notice'>You reinforce [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
					P.use(2)
					reinforced = 1
				return
		if(CONSTRUCTION_NO_CIRCUIT)
			if(istype(C, /obj/item/electronics/firelock))
				user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
					"<span class='notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(!do_after(user, DEFAULT_STEP_TIME, target = src))
					return
				if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
					return
				qdel(C)
				user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
					"<span class='notice'>You insert and secure [C].</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				constructionStep = CONSTRUCTION_PANEL_OPEN
				return
			if(C.tool_behaviour == TOOL_WELDER)
				if(!C.tool_start_check(user, amount=1))
					return
				user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
					"<span class='notice'>You begin slicing [src] apart...</span>")

				if(C.use_tool(src, user, DEFAULT_STEP_TIME, volume=50, amount=1))
					if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
						return
					user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
						"<span class='notice'>You cut [src] into metal.</span>")
					var/turf/T = get_turf(src)
					new /obj/item/stack/sheet/iron(T, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(T, 2)
					qdel(src)
				return
			if(istype(C, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = C
				if(!P.adapt_circuit(user, DEFAULT_STEP_TIME * 0.5))
					return
				user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
				"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
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
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
			constructionStep = CONSTRUCTION_PANEL_OPEN
			update_appearance()
			return TRUE
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE

#undef TOOLLESS_BURN_DAMAGE_PER_SECOND
#undef TOOLLESS_OPEN_DURATION_SOLO
#undef MINIMUM_TEMPERATURE_TO_BURN_ARMS
