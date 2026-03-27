#define RADIO_EXIT 1
#define RADIO_ENTER 2
#define RADIO_DIVING "radio-diving"
#define RADIO_DIVE_BEAM_COLOR "#3ecfb3"
#define RADIO_DIVE_SCREEN_TINT_COLOR "#266155"
#define RADIO_DIVE_CRIT_HEALTH_PERCENT 20
#define RADIO_DIVE_COLOR_MATRIX list(1,0,0,0,1,0,0,0,1,0.24,0.81,0.70)

/datum/action/cooldown/spell/jaunt/radiodive
	name = "Radiodive"
	desc = "Allows you to convert yourself into a signal and dive into signal-space. \
		WARNING: YOU WILL SLOWLY ATTENUATE AND LOSE INTEGRITY AS A SIGNAL. \
		Exiting signal-space will reinforce your integrity, fully healing you. \
		You can only enter signal-space from radio devices that are both on and listening, \
		and you can only exit signal-space from radio devices that are on and broadcasting."
	background_icon = 'troutstation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_flock"
	overlay_icon_state = "bg_flock_border"
	button_icon = 'troutstation/icons/mob/actions/actions_flock.dmi'
	button_icon_state = "radiodive"

	spell_requirements = NONE
	jaunt_type = /obj/effect/dummy/phased_mob/radiodive

	/// Radius we'll check for radio devices in
	var/radio_radius = 4
	/// Time it takes to dive into signal-space / enter jaunt
	var/phase_out_time = 2.5 SECONDS // using mirrorwalk as an example
	/// Time it takes to emerge from signal-space / exit jaunt
	var/phase_in_time = 2 SECONDS
	/// Traits applied while in signal form (resistances, and also crits disabled while in signal form as we handle attenuation ourselves)
	var/static/list/jaunting_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_NOBREATH,
	TRAIT_STUNIMMUNE, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT)
	/// Reference to a fancy visual we own
	VAR_PRIVATE/obj/effect/radio_dive_swirl/swirly
	/// Keep track of the visual beam so we can kill it
	VAR_PRIVATE/datum/weakref/beam_weakref
	/// Reference to the processor overload event
	var/datum/round_event_control/processor_overload/processor_overload_control

/datum/action/cooldown/spell/jaunt/radiodive/New()
	. = ..()
	processor_overload_control = locate(/datum/round_event_control/processor_overload) in SSevents.control

/datum/action/cooldown/spell/jaunt/radiodive/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(processor_overload_control, COMSIG_CREATED_ROUND_EVENT, PROC_REF(exospheric_punt))

/datum/action/cooldown/spell/jaunt/radiodive/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(processor_overload_control, COMSIG_CREATED_ROUND_EVENT)

/datum/action/cooldown/spell/jaunt/radiodive/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(is_within_radio_jammer_range(owner))
		if(feedback)
			to_chat(owner, span_warning("Something is emitting a disruptive jamming signal!"))
		return FALSE
	if(is_within_supermatter_range(owner))
		if(feedback)
			to_chat(owner, span_warning("That horrendous screeching is distorting signal-space. Whatever that yellow anomaly is, it's not safe to transmit anywhere near it."))
		return FALSE

	var/we_are_phasing = is_jaunting(owner)
	var/required_radio_mode = we_are_phasing ? RADIO_EXIT : RADIO_ENTER
	var/turf/owner_turf = get_turf(owner)
	if(!length(find_nearby_radios(owner_turf, radio_radius, required_radio_mode)))
		if(feedback)
			to_chat(owner, span_warning("There are no functional radios in sight and range currently [we_are_phasing ? "transmitting":"receiving"] any signals nearby!"))
		return FALSE

	if(owner_turf.is_blocked_turf(exclude_mobs = TRUE))
		if(feedback)
			to_chat(owner, span_warning("Something is blocking you from [we_are_phasing ? "surfacing from":"diving into"] signal-space here!"))
		return FALSE

	return TRUE

/// Find all nearby valid radios that match the mode we're looking for.
/datum/action/cooldown/spell/jaunt/radiodive/proc/find_nearby_radios(turf/origin, radio_radius, radio_mode)
	var/list/radios = get_radios_nearby(origin, radio_radius, visible_only = TRUE)
	var/list/candidates = list()
	for(var/obj/item/radio/radio in radios)
		if(!radio.is_on())
			continue
		var/datum/wires/wires = radio.wires
		switch(radio_mode)
			if(RADIO_ENTER)
				if(wires && wires.is_cut(WIRE_TX))
					continue
				if(radio.get_broadcasting())
					candidates += radio
			if(RADIO_EXIT)
				if(wires && wires.is_cut(WIRE_RX))
					continue
				if(radio.get_listening())
					candidates += radio
	return candidates

/// Find the nearest ideally stationary radio that matches the mode we're looking for.
/// Prioritizes radios that aren't in containers or mobs that are likely to be moved.
/// Returns null if none.
/datum/action/cooldown/spell/jaunt/radiodive/proc/find_nearest_radio(turf/origin, radio_radius, radio_mode)
	// prioritize radios that aren't likely to move
	var/obj/item/radio/best_stationary_match
	var/best_stationary_match_distance = INFINITY
	var/obj/item/radio/best_backup_match
	var/best_backup_match_distance = INFINITY
	var/list/candidates = find_nearby_radios(origin, radio_radius, radio_mode)

	for(var/obj/item/radio/radio in candidates)
		var/is_stationary = isturf(radio.loc)
		if(best_stationary_match && !is_stationary)
			continue // we prefer stationary matches always
		var/dist = get_dist(origin, radio)
		if(is_stationary)
			if(dist < best_stationary_match_distance)
				best_stationary_match = radio
				best_stationary_match_distance = dist
		else
			if(dist < best_backup_match_distance)
				best_backup_match = radio
				best_backup_match_distance = dist

	return best_stationary_match ? best_stationary_match : best_backup_match

/datum/action/cooldown/spell/jaunt/radiodive/cast(mob/living/cast_on)
	. = ..()
	var/health_percentage = floor((cast_on.health / cast_on.maxHealth) * 100)
	if(!is_jaunting(cast_on) && health_percentage <= RADIO_DIVE_CRIT_HEALTH_PERCENT)
		if(tgui_alert(cast_on, "This will likely kill you! Are you sure?", "Criticial Integrity Warning!", list("Yes", "No")) == "No")
			return
	var/we_are_phasing = is_jaunting(cast_on)
	var/required_radio_mode = we_are_phasing ? RADIO_EXIT : RADIO_ENTER
	var/obj/item/radio/nearest_radio = find_nearest_radio(get_turf(cast_on), radio_radius, required_radio_mode)
	do_radiodive(nearest_radio, cast_on)

/datum/action/cooldown/spell/jaunt/radiodive/proc/do_radiodive(obj/item/radio/radio, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(radio, jaunter)
	else
		. = try_enter_jaunt(radio, jaunter)
	if(!.)
		reset_spell_cooldown()
		to_chat(jaunter, span_warning("You are unable to radiodive!"))

/datum/action/cooldown/spell/jaunt/radiodive/proc/try_enter_jaunt(obj/item/radio/radio, mob/living/jaunter)
	// drop everything we have that isn't flock items
	for(var/obj/item/item in jaunter.get_all_gear())
		if(!HAS_TRAIT(item, TRAIT_FLOCKISH_ITEM))
			jaunter.dropItemToGround(item, force = TRUE)

	var/atom/target = radio
	if(!isturf(radio.loc))
		target = radio.loc

	// The actual turf we enter
	var/turf/jaunt_turf = get_turf(target)

	if(phase_out_time > 0 SECONDS)
		if(target == radio)
			jaunter.visible_message(span_warning("[jaunter] shimmers and begins to dissolve into [radio]!"))
		else
			jaunter.visible_message(span_warning("[jaunter] shimmers and begins to dissolve towards [target]!"))
		do_enter_effect(jaunter, target, phase_out_time)
		playsound(jaunter, 'troutstation/sound/effects/flock/start_radiodive.ogg', 50, TRUE, -1)
		if(!do_after(jaunter, phase_out_time, target = target, extra_checks = CALLBACK(src, PROC_REF(radio_still_on), target, RADIO_ENTER)))
			cancel_effects()
			return FALSE

	end_swirly()

	// Begin the jaunt
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	var/obj/effect/dummy/phased_mob/holder = enter_jaunt(jaunter, jaunt_turf)
	if(!holder)
		REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
		return FALSE

	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

	jaunter.add_traits(jaunting_traits, RADIO_DIVING)
	radio.visible_message(span_warning("[jaunter] fully dissipates into [target]!"))
	playsound(radio, 'troutstation/sound/effects/flock/radio_sweep.ogg', 50, TRUE, -1)
	jaunter.extinguish_mob()

	for(var/atom/movable/screen/plane_master/lighting as anything in jaunter.hud_used.get_true_plane_masters(LIGHTING_PLANE))
		lighting.add_atom_colour(RADIO_DIVE_SCREEN_TINT_COLOR, TEMPORARY_COLOUR_PRIORITY)

	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	return TRUE

/datum/action/cooldown/spell/jaunt/radiodive/proc/radio_still_on(obj/item/radio/radio, direction)
	if(QDELETED(radio) || !radio.is_on())
		return FALSE
	var/datum/wires/wires = radio.wires
	switch(direction)
		if(RADIO_ENTER)
			if((wires && wires.is_cut(WIRE_TX)) || !radio.get_broadcasting())
				return FALSE
		if(RADIO_EXIT)
			if((wires && wires.is_cut(WIRE_RX)) || !radio.get_listening())
				return FALSE
	return TRUE

/datum/action/cooldown/spell/jaunt/radiodive/proc/radio_still_on_and_no_movement(obj/item/radio/radio, turf/original_location)
	return radio_still_on(radio, RADIO_EXIT) && (get_turf(owner) == original_location)

/datum/action/cooldown/spell/jaunt/radiodive/proc/on_move(atom/old_loc, dir, forced, list/old_locs)
	update_status_on_signal()
	var/we_are_phasing = is_jaunting(owner)
	if(!we_are_phasing)
		return
	if(is_within_radio_jammer_range(owner))
		var/mob/living/jaunter = owner
		to_chat(jaunter, span_boldwarning("Hostile radio interference! Signal disrupted! Attempting to reassemble!!"))
		get_punted()
	// do not get near any supermatter
	if(is_within_supermatter_range(owner))
		var/mob/living/jaunter = owner
		to_chat(jaunter, span_boldwarning("Severe radio distortions! Unable to compensate for anomalous source! Initiating emergency reintegration!"))
		get_punted()

/datum/action/cooldown/spell/jaunt/radiodive/proc/is_within_supermatter_range(atom/source, dist = 6)
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/supermatter_crystal))
		if(!isturf(sm.loc) || !(is_station_level(sm.z) || is_mining_level(sm.z) || sm.z == source.z))
			continue
		if(IN_GIVEN_RANGE(source, sm, dist))
			return TRUE
	return FALSE

/datum/action/cooldown/spell/jaunt/radiodive/proc/exospheric_punt(datum/round_event_control/source_event_control, datum/round_event/processor_overload/created_event)
	var/we_are_phasing = is_jaunting(owner)
	if(!we_are_phasing)
		return
	// bad luck!!!
	var/mob/living/jaunter = owner
	to_chat(jaunter, span_boldwarning("Severe unexpected signal disruption! Attempting to reassemble!!"))
	get_punted()

/datum/action/cooldown/spell/jaunt/radiodive/proc/get_punted()
	var/mob/living/jaunter = owner
	exit_jaunt(jaunter) // get forced out without healing
	jaunter.emote("scream", forced=TRUE)
	jaunter.Stun(4 SECONDS)
	jaunter.Knockdown(2 SECONDS)

/datum/action/cooldown/spell/jaunt/radiodive/proc/try_exit_jaunt(obj/item/radio/radio, mob/living/jaunter)
	var/atom/target = radio
	if(!isturf(radio.loc))
		target = radio.loc

	if(HAS_TRAIT(jaunter, TRAIT_NO_TRANSFORM))
		to_chat(jaunter, span_warning("You're still decorporealizing!!"))
		return FALSE

	var/turf/target_turf = get_turf(jaunter)
	if(phase_in_time > 0 SECONDS)
		if(target == radio)
			radio.visible_message(span_warning("[radio] starts to emit strange noises as a beam flies out..."))
		else
			target.visible_message(span_warning("[target] starts to emit muffled strange noises as a beam flies out..."))
		playsound(target, 'troutstation/sound/effects/flock/radio_sweep.ogg', 50, TRUE, -1)
		do_exit_effect(target, target_turf, phase_in_time)
		if(!do_after(jaunter, phase_in_time, target = target, extra_checks = CALLBACK(src, PROC_REF(radio_still_on_and_no_movement), target, target_turf)))
			cancel_effects()
			return FALSE

	if(!exit_jaunt(jaunter, target_turf))
		return FALSE

	jaunter.visible_message(span_boldwarning("[jaunter] emerges in a shower of lights from [target]!"))
	var/health_percentage = floor((jaunter.health / jaunter.maxHealth) * 100)
	if(health_percentage > RADIO_DIVE_CRIT_HEALTH_PERCENT)
		jaunter.revive(HEAL_ALL)
		jaunter.show_message(span_good("Your body reassembles itself to complete physical integrity!"))
	else
		jaunter.maxHealth *= 0.9 // repeatedly leaving bits of yourself behind as cosmic microwaves is not conducive to long-term health
		jaunter.heal_overall_damage(jaunter.maxHealth * 0.2)
		jaunter.show_message(span_notice("What's left of you reassembles as best it can. You're incomplete, but still alive."))
	return TRUE

/datum/action/cooldown/spell/jaunt/radiodive/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	unjaunter.remove_traits(jaunting_traits, RADIO_DIVING)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	STOP_PROCESSING(SSobj, jaunt)
	end_swirly()
	animate(unjaunter, color=RADIO_DIVE_COLOR_MATRIX, transform = matrix()*0.5, alpha = 0, transform = null, time = 0)
	animate(color = null, alpha = 255, transform = null, time = 5)
	if(prob(50))
		do_sparks(1, TRUE, unjaunter)
	playsound(unjaunter, 'troutstation/sound/effects/flock/stop_radiodive.ogg', 50, TRUE, -1)
	// undo weird colours
	for(var/atom/movable/screen/plane_master/lighting as anything in unjaunter.hud_used.get_true_plane_masters(LIGHTING_PLANE))
		lighting.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, RADIO_DIVE_SCREEN_TINT_COLOR)
	return ..()

/datum/action/cooldown/spell/jaunt/radiodive/proc/do_enter_effect(atom/source, atom/target, duration)
	start_swirly(source)
	QDEL_NULL(beam_weakref)
	beam_weakref = WEAKREF(source.Beam(target, time = duration, icon='troutstation/icons/effects/beam.dmi', icon_state="flock_transmit"))
	animate(source, color=RADIO_DIVE_COLOR_MATRIX, transform = matrix()*0.5, time = duration * 0.8, easing = SINE_EASING | EASE_OUT)
	animate(alpha = 0, time = duration * 0.2)

/obj/effect/radio_dive_swirl
	name = "signal motes"
	icon_state = "shieldsparkles"

/datum/action/cooldown/spell/jaunt/radiodive/proc/do_exit_effect(atom/source, atom/target, duration)
	start_swirly(target)
	QDEL_NULL(beam_weakref)
	beam_weakref = WEAKREF(source.Beam(target, time = duration, icon='troutstation/icons/effects/beam.dmi', icon_state="flock_transmit"))

/datum/action/cooldown/spell/jaunt/radiodive/proc/start_swirly(atom/source)
	if(swirly)
		end_swirly()
	swirly = new(get_turf(source))

/datum/action/cooldown/spell/jaunt/radiodive/proc/end_swirly()
	if(swirly)
		qdel(swirly)
		swirly = null

/datum/action/cooldown/spell/jaunt/radiodive/proc/cancel_effects()
	end_swirly()
	animate(owner, color = null, alpha = 255, transform = null, time = 1)
	QDEL_NULL(beam_weakref)

/obj/effect/dummy/phased_mob/radiodive
	name = "signal"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "ice_1"
	// TODO: specify our icon so ghosts can see it
	/// Have we already warned our user about attenuation?
	var/attenuation_warned = FALSE
	/// Did we just start damaged?
	var/started_at_low_health = FALSE

/obj/effect/dummy/phased_mob/radiodive/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/radiodive/set_jaunter(atom/movable/new_jaunter)
	. = ..(new_jaunter)
	var/mob/living/living_jaunter = new_jaunter
	var/health_percentage = floor((living_jaunter.health / living_jaunter.maxHealth) * 100)
	if(health_percentage <= RADIO_DIVE_CRIT_HEALTH_PERCENT)
		started_at_low_health = TRUE // good luck, buddy
	redraw_health_indicator()

/obj/effect/dummy/phased_mob/radiodive/process(seconds_per_tick)
	if(!isliving(jaunter))
		STOP_PROCESSING(SSobj, src)
		return ..()
	var/mob/living/living_jaunter = jaunter
	living_jaunter.take_overall_damage(1 * seconds_per_tick)
	var/health_percentage = floor((living_jaunter.health / living_jaunter.maxHealth) * 100)
	if(health_percentage < RADIO_DIVE_CRIT_HEALTH_PERCENT * 1.1)
		if(!attenuation_warned)
			living_jaunter.show_message(span_userdanger("You're attenuating! Find a broadcasting radio and emerge before you're gone completely!!"))
			attenuation_warned = TRUE
	if(health_percentage < RADIO_DIVE_CRIT_HEALTH_PERCENT && !started_at_low_health)
		living_jaunter.show_message(span_userdanger("Integrity critical! Emergency reintegration initiated!!"))
		eject_jaunter()
		return
	redraw_health_indicator(health_percentage)


/obj/effect/dummy/phased_mob/radiodive/proc/redraw_health_indicator(health_percentage = 100)
	// TODO: change sprite based on jaunter health
	// using actual assets and not this bullshit
	switch(health_percentage)
		if(0 to 25)
			update_indicator("mini_leaper")
		if(26 to 50)
			update_indicator("bluespace")
		if(51 to 75)
			update_indicator("blue_laser")
		if(76 to INFINITY)
			update_indicator("ice_1")

#undef RADIO_EXIT
#undef RADIO_ENTER
#undef RADIO_DIVING
#undef RADIO_DIVE_BEAM_COLOR
#undef RADIO_DIVE_SCREEN_TINT_COLOR
#undef RADIO_DIVE_CRIT_HEALTH_PERCENT
#undef RADIO_DIVE_COLOR_MATRIX
