/obj/effect/abstract/liquid_turf
	name = "liquid"
	icon = 'monkestation/icons/obj/effects/liquid.dmi'
	icon_state = "water-0"
	base_icon_state = "water"
	anchored = TRUE
	plane = FLOOR_PLANE
	color = "#DDF"
	alpha = 175
	//For being on fire
	light_outer_range = 0
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_WATER
	canSmoothWith = SMOOTH_GROUP_WATER + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS

	mouse_opacity = FALSE

	var/datum/liquid_group/liquid_group
	var/turf/my_turf

	var/fire_state = LIQUID_FIRE_STATE_NONE
	var/liquid_state = LIQUID_STATE_PUDDLE
	var/no_effects = FALSE


	var/static/obj/effect/abstract/fire/small_fire/small_fire
	var/static/obj/effect/abstract/fire/medium_fire/medium_fire
	var/static/obj/effect/abstract/fire/big_fire/big_fire

	var/mutable_appearance/displayed_content
	/// State-specific message chunks for examine_turf()
	var/static/list/liquid_state_messages = list(
		"[LIQUID_STATE_PUDDLE]" = "a puddle of $",
		"[LIQUID_STATE_ANKLES]" = "$ going [span_warning("up to your ankles")]",
		"[LIQUID_STATE_WAIST]" = "$ going [span_warning("up to your waist")]",
		"[LIQUID_STATE_SHOULDERS]" = "$ going [span_warning("up to your shoulders")]",
		"[LIQUID_STATE_FULLTILE]" = "$ going [span_danger("over your head")]",
	)

	var/temporary_split_key


/obj/effect/abstract/liquid_turf/proc/process_evaporation()
	if(liquid_group.expected_turf_height > LIQUID_ANKLES_LEVEL_HEIGHT)
		SSliquids.evaporation_queue -= my_turf
		return

	//See if any of our reagents evaporates
	var/any_change = FALSE
	var/datum/reagent/R //Faster declaration
	for(var/reagent_type in liquid_group.reagents.reagent_list)
		R = reagent_type
		//We evaporate. bye bye
		if(initial(R.evaporates))
			var/remove_amount = min((initial(R.evaporation_rate)), R.volume, (liquid_group.reagents_per_turf / liquid_group.reagents.reagent_list.len))
			liquid_group.remove_specific(src, remove_amount, R)
			any_change = TRUE
			R.evaporate(src.loc, remove_amount)

	if(!any_change)
		SSliquids.evaporation_queue -= my_turf
		return

/obj/effect/abstract/liquid_turf/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		. = ..()

/obj/effect/abstract/liquid_turf/proc/set_new_liquid_state(new_state)
	if(no_effects)
		return
	liquid_state = new_state

	var/number = new_state - 1
	if(number != 0)
		icon_state = null
		base_icon_state = null
		update_appearance()

	else
		icon_state = initial(icon_state)
		base_icon_state = initial(base_icon_state)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/effect/abstract/liquid_turf/update_overlays()
	. = ..()
	var/number = liquid_state - 1
	if(number != 0)
		. += mutable_appearance('monkestation/icons/obj/effects/liquid_overlays.dmi', "stage[number]_bottom", offset_spokesman = my_turf, plane = GAME_PLANE_UPPER, layer = ABOVE_MOB_LAYER)
		. += mutable_appearance('monkestation/icons/obj/effects/liquid_overlays.dmi', "stage[number]_top", offset_spokesman = my_turf, plane =GAME_PLANE, layer = GATEWAY_UNDERLAY_LAYER)

/obj/effect/abstract/liquid_turf/proc/set_fire_effect()
	if(displayed_content)
		vis_contents -= displayed_content

	if(!liquid_group)
		return

	switch(liquid_group.group_fire_state)
		if(LIQUID_FIRE_STATE_SMALL)
			displayed_content = small_fire
		if(LIQUID_FIRE_STATE_MILD)
			displayed_content = small_fire
		if(LIQUID_FIRE_STATE_MEDIUM)
			displayed_content = medium_fire
		if(LIQUID_FIRE_STATE_HUGE)
			displayed_content = big_fire
		if(LIQUID_FIRE_STATE_INFERNO)
			displayed_content = big_fire
		else
			displayed_content = null

	if(displayed_content)
		vis_contents |= displayed_content

//Takes a flat of our reagents and returns it, possibly qdeling our liquids
/obj/effect/abstract/liquid_turf/proc/take_reagents_flat(flat_amount)
	liquid_group.remove_any(src, flat_amount)

/obj/effect/abstract/liquid_turf/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(liquid_group.group_overlay_state >= LIQUID_STATE_ANKLES)
		if(prob(30))
			var/sound_to_play = pick(list(
				'monkestation/sound/effects/water_wade1.ogg',
				'monkestation/sound/effects/water_wade2.ogg',
				'monkestation/sound/effects/water_wade3.ogg',
				'monkestation/sound/effects/water_wade4.ogg'
				))
			playsound(T, sound_to_play, 50, 0)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.apply_status_effect(/datum/status_effect/water_affected)
		if(isliving(AM))
			var/mob/living/carbon/human/stepped_human = AM
			liquid_group.expose_atom(stepped_human, 1, TOUCH)
	else if (isliving(AM))
		var/mob/living/L = AM
		if(prob(7) && !(L.movement_type & FLYING) && L.body_position == STANDING_UP)
			L.slip(30, T, NO_SLIP_WHEN_WALKING, 0, TRUE)

	if(fire_state)
		AM.fire_act((T20C+50) + (50*fire_state), 125)

/obj/effect/abstract/liquid_turf/proc/mob_fall(datum/source, mob/M)
	SIGNAL_HANDLER
	var/turf/T = source
	if(liquid_group.group_overlay_state >= LIQUID_STATE_ANKLES && T.has_gravity(T))
		playsound(T, 'monkestation/sound/effects/splash.ogg', 50, 0)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.wear_mask && C.wear_mask.flags_cover & MASKCOVERSMOUTH)
				to_chat(C, span_userdanger("You fall in the water!"))
			else
				liquid_group.transfer_to_atom(src, CHOKE_REAGENTS_INGEST_ON_FALL_AMOUNT, C)
				C.adjustOxyLoss(5)
				//C.emote("cough")
				INVOKE_ASYNC(C, TYPE_PROC_REF(/mob, emote), "cough")
				to_chat(C, span_userdanger("You fall in and swallow some water!"))
		else
			to_chat(M, span_userdanger("You fall in the water!"))

/obj/effect/abstract/liquid_turf/Initialize(mapload, datum/liquid_group/group_to_add)
	. = ..()
	if(!small_fire)
		small_fire = new
	if(!medium_fire)
		medium_fire = new
	if(!big_fire)
		big_fire = new

	if(!my_turf)
		my_turf = loc

	if(!my_turf.liquids)
		my_turf.liquids = src

	if(group_to_add)
		group_to_add.add_to_group(my_turf)
		set_new_liquid_state(liquid_group.group_overlay_state)

	if(!liquid_group && !group_to_add)
		liquid_group = new(1, src)

	if(!SSliquids)
		CRASH("Liquid Turf created with the liquids sybsystem not yet initialized!")
	my_turf = loc
	RegisterSignal(my_turf, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(my_turf, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))
	RegisterSignal(my_turf, COMSIG_ATOM_EXAMINE, PROC_REF(examine_turf))

	SEND_SIGNAL(my_turf, COMSIG_TURF_LIQUIDS_CREATION, src)

	if(z)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)


/obj/effect/abstract/liquid_turf/Destroy(force)
	UnregisterSignal(my_turf, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL, COMSIG_ATOM_EXAMINE))
	if(liquid_group)
		liquid_group.remove_from_group(my_turf)
	if(my_turf in SSliquids.evaporation_queue)
		SSliquids.evaporation_queue -= my_turf
	if(my_turf in SSliquids.burning_turfs)
		SSliquids.burning_turfs -= my_turf
	my_turf.liquids = null
	my_turf = null
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/abstract/liquid_turf/proc/ChangeToNewTurf(turf/NewT)
	if(NewT.liquids)
		stack_trace("Liquids tried to change to a new turf, that already had liquids on it!")

	UnregisterSignal(my_turf, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL))
	if(SSliquids.evaporation_queue[my_turf])
		SSliquids.evaporation_queue -= my_turf
		SSliquids.evaporation_queue[NewT] = TRUE
	my_turf.liquids = null
	my_turf = NewT
	liquid_group.move_liquid_group(src)
	NewT.liquids = src
	loc = NewT
	RegisterSignal(my_turf, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(my_turf, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))

/**
 * Handles COMSIG_ATOM_EXAMINE for the turf.
 *
 * Adds reagent info to examine text.
 * Arguments:
 * * source - the turf we're peekin at
 * * examiner - the user
 * * examine_text - the examine list
 *  */
/obj/effect/abstract/liquid_turf/proc/examine_turf(turf/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	// This should always have reagents if this effect object exists, but as a sanity check...
	if(!length(liquid_group.reagents.reagent_list))
		return

	var/liquid_state_template = liquid_state_messages["[liquid_group.group_overlay_state]"]

	examine_list +=  "<hr>"

	if(examiner.can_see_reagents())
		examine_list +=  "<hr>"

		if(length(liquid_group.reagents.reagent_list) == 1)
			// Single reagent text.
			var/datum/reagent/reagent_type = liquid_group.reagents.reagent_list[1]
			var/reagent_name = initial(reagent_type.name)
			var/volume = round(reagent_type.volume / length(liquid_group.members), 0.01)

			examine_list += span_notice("There is [replacetext(liquid_state_template, "$", "[volume] units of [reagent_name]")] here.")
		else
			// Show each individual reagent
			examine_list += "There is [replacetext(liquid_state_template, "$", "the following")] here:"

			for(var/datum/reagent/reagent_type as anything in liquid_group.reagents.reagent_list)
				var/reagent_name = initial(reagent_type.name)
				if(istype(reagent_type, /datum/reagent/ammonia/urine) && examiner.client?.prefs.read_preference(/datum/preference/toggle/prude_mode))
					reagent_name = "Ammonia"
				var/volume = round(reagent_type.volume / length(liquid_group.members), 0.01)
				examine_list += "&bull; [volume] units of [reagent_name]"

		examine_list += span_notice("The solution has a temperature of [liquid_group.group_temperature]K.")
		examine_list +=  "<hr>"
		return

	// Otherwise, just show the total volume
	examine_list += span_notice("There is [replacetext(liquid_state_template, "$", "liquid")] here.")

/obj/effect/temp_visual/liquid_splash
	icon = 'monkestation/icons/obj/effects/splash.dmi'
	icon_state = "splash"
	layer = FLY_LAYER
	randomdir = FALSE

/obj/effect/abstract/fire
	icon = 'monkestation/icons/obj/effects/liquid.dmi'
	plane = FLOOR_PLANE
	layer = BELOW_MOB_LAYER
	mouse_opacity = FALSE
	appearance_flags = RESET_COLOR | RESET_ALPHA

/obj/effect/abstract/fire/small_fire
	icon_state = "fire_small"

/obj/effect/abstract/fire/medium_fire
	icon_state = "fire_medium"

/obj/effect/abstract/fire/big_fire
	icon_state = "fire_big"
