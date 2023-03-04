/datum/traitor_objective/demoralise/graffiti
	name = "Sow doubt among the crew %VIEWS% times using Syndicate graffiti."
	description = "Use the button below to materialize a seditious spray can, \
		and use it to draw a 3x3 tag in a place where people will come across it. \
		Special syndicate sealing agent ensures that it can't be removed for \
		five minutes following application, and it's slippery too! \
		People seeing or slipping on your graffiti grants progress towards success."

	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES
	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	duplicate_type = /datum/traitor_objective/demoralise/graffiti
	/// Have we given out a spray can yet?
	var/obtained_spray = FALSE
	/// Graffiti 'rune' which we will be drawing
	var/obj/effect/decal/cleanable/traitor_rune/rune

/datum/traitor_objective/demoralise/graffiti/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if (!obtained_spray)
		buttons += add_ui_button("", "Pressing this will materialize a syndicate spraycan in your hand.", "wifi", "summon_gear")
	else
		buttons += add_ui_button("[demoralised_crew_events] / [demoralised_crew_required] propagandised", "This many crew have been exposed to propaganda, out of a required [demoralised_crew_required].", "wifi", "none")
	return buttons

/datum/traitor_objective/demoralise/graffiti/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if ("summon_gear")
			if (obtained_spray)
				return

			obtained_spray = TRUE
			var/obj/item/traitor_spraycan/spray = new(user.drop_location())
			user.put_in_hands(spray)
			spray.balloon_alert(user, "the spraycan materializes in your hand")

			RegisterSignal(spray, COMSIG_PARENT_QDELETING, PROC_REF(on_spray_destroyed))
			RegisterSignal(spray, COMSIG_TRAITOR_GRAFFITI_DRAWN, PROC_REF(on_rune_complete))

/**
 * Called when the spray can is deleted.
 * If it's already been expended we don't care, if it hasn't you just made your objective impossible.area
 *
 * Arguments
 * * spray - the spraycan which was just deleted
 */
/datum/traitor_objective/demoralise/graffiti/proc/on_spray_destroyed()
	SIGNAL_HANDLER
	// You fucked up pretty bad if you let this happen
	if (!rune)
		fail_objective(penalty_cost = telecrystal_penalty)

/**
 * Called when you managed to draw a traitor rune.
 * Sets up tracking for objective progress, and unregisters signals for the spraycan because we don't care about it any more.
 *
 * Arguments
 * * drawn_rune - graffiti 'rune' which was just drawn.
 */
/datum/traitor_objective/demoralise/graffiti/proc/on_rune_complete(atom/spray, obj/effect/decal/cleanable/traitor_rune/drawn_rune)
	SIGNAL_HANDLER
	rune = drawn_rune
	UnregisterSignal(spray, COMSIG_PARENT_QDELETING)
	UnregisterSignal(spray, COMSIG_TRAITOR_GRAFFITI_DRAWN)
	RegisterSignal(drawn_rune, COMSIG_PARENT_QDELETING, PROC_REF(on_rune_destroyed))
	RegisterSignal(drawn_rune, COMSIG_DEMORALISING_EVENT, PROC_REF(on_mood_event))
	RegisterSignal(drawn_rune, COMSIG_TRAITOR_GRAFFITI_SLIPPED, PROC_REF(on_mood_event))

/**
 * Called when your traitor rune is destroyed. If you haven't suceeded by now, you fail.area
 *
 * Arguments
 * * rune - the rune which just got destroyed.
 */
/datum/traitor_objective/demoralise/graffiti/proc/on_rune_destroyed(obj/effect/decal/cleanable/traitor_rune/rune)
	SIGNAL_HANDLER
	fail_objective(penalty_cost = telecrystal_penalty)

/datum/traitor_objective/demoralise/graffiti/ungenerate_objective()
	if (rune)
		UnregisterSignal(rune, COMSIG_PARENT_QDELETING)
		UnregisterSignal(rune, COMSIG_DEMORALISING_EVENT)
		UnregisterSignal(rune, COMSIG_TRAITOR_GRAFFITI_SLIPPED)
		rune = null
	return ..()

// Extending the existing spraycan item was more trouble than it was worth, I don't want or need this to be able to draw arbitrary shapes.
/obj/item/traitor_spraycan
	name = "seditious spraycan"
	desc = "This spraycan deploys a subversive pattern containing subliminal priming agents over a 3x3 area. Contains enough primer for just one final coating."
	icon = 'icons/obj/art/crayons.dmi'
	icon_state = "deathcan"
	worn_icon_state = "spraycan"
	inhand_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/paint_color = "#780000"
	var/static/list/no_draw_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))

	/// Are we currently drawing? Used to prevent spam clicks for do_while
	var/drawing_rune = FALSE
	/// Set to true if we finished drawing something, this spraycan is now useless
	var/expended = FALSE

/obj/item/traitor_spraycan/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if (expended)
		user.balloon_alert(user, "all out of paint...")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (drawing_rune)
		user.balloon_alert(user, "already busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	. |= AFTERATTACK_PROCESSED_ITEM

	if (!proximity || !check_allowed_items(target) || !isliving(user))
		return

	if (isturf(target))
		try_draw_new_rune(user, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (istype(target, /obj/effect/decal/cleanable/traitor_rune))
		try_complete_rune(user, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Attempt to draw a rune on [target_turf].
 * Shamelessly adapted from the heretic rune drawing process.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 */
/obj/item/traitor_spraycan/proc/try_draw_new_rune(mob/living/user, turf/target_turf)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if (!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, no_draw_turfs))
			user.balloon_alert(user, "you need a clear 3x3 area!")
			return

	draw_rune(user, target_turf)

/**
 * Draw your stage one rune on the ground and store it.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 */
/obj/item/traitor_spraycan/proc/draw_rune(mob/living/user, turf/target_turf)
	if (!try_draw_step("drawing outline...", user, target_turf))
		return
	try_complete_rune(user, new /obj/effect/decal/cleanable/traitor_rune(target_turf))

/**
 * Holder for repeated code to do something after a message and a set amount of time.
 *
 * Arguments
 * * output - a string to show when you start the process
 * * user - the mob drawing the rune
 * * target - what they're trying to draw, or the place they are trying to draw on
 */
/obj/item/traitor_spraycan/proc/try_draw_step(start_output, mob/living/user, atom/target)
	drawing_rune = TRUE
	user.balloon_alert(user, "[start_output]")
	if (!do_after(user, 3 SECONDS, target))
		user.balloon_alert(user, "interrupted!")
		drawing_rune = FALSE
		return FALSE

	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	drawing_rune = FALSE
	return TRUE

#define RUNE_STAGE_OUTLINE 0
#define RUNE_STAGE_COLOURED 1
#define RUNE_STAGE_COMPLETE 2
#define RUNE_STAGE_REMOVABLE 3

/**
 * Try to upgrade a floor rune to its next stage.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 */
/obj/item/traitor_spraycan/proc/try_complete_rune(mob/living/user, obj/effect/decal/cleanable/traitor_rune/rune)
	switch(rune.drawn_stage)
		if (RUNE_STAGE_OUTLINE)
			if (!try_draw_step("... finalising design...", user, rune))
				return
			if (!rune)
				user.balloon_alert(user, "graffiti was destroyed!")
				return
			rune.set_stage(RUNE_STAGE_COLOURED)
			try_complete_rune(user, rune)

		if (RUNE_STAGE_COLOURED)
			if (!try_draw_step("... applying final coating...", user, rune))
				return
			if (!rune)
				user.balloon_alert(user, "graffiti was destroyed!")
				return
			user.balloon_alert(user, "finished!")
			rune.set_stage(RUNE_STAGE_COMPLETE)
			expended = TRUE
			desc = "A suspicious looking spraycan, it's all out of paint."
			SEND_SIGNAL(src, COMSIG_TRAITOR_GRAFFITI_DRAWN, rune)

		if (RUNE_STAGE_COMPLETE, RUNE_STAGE_REMOVABLE)
			user.balloon_alert(user, "all done!")

/// Copying the functionality from normal spraycans, but doesn't need all the optional checks
/obj/item/traitor_spraycan/suicide_act(mob/living/user)
	if(expended)
		user.visible_message(span_suicide("[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, but nothing happens!"))
		user.say("MEDIOCRE!!", forced="spraycan suicide")
		return SHAME

	var/mob/living/carbon/human/suicider = user
	user.visible_message(span_suicide("[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, spraying paint across [user.p_their()] teeth!"))
	user.say("WITNESS ME!!", forced="spraycan suicide")
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	suicider.update_lips("spray_face", paint_color)
	return OXYLOSS

/obj/effect/decal/cleanable/traitor_rune
	name = "syndicate graffiti"
	desc = "It looks like it's going to be... the Syndicate logo?"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "traitor_rune_outline"
	pixel_x = -32
	pixel_y = -32
	gender = NEUTER
	mergeable_decal = FALSE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clean_type = CLEAN_TYPE_HARD_DECAL
	layer = SIGIL_LAYER
	var/slip_time = 6 SECONDS
	var/slip_flags = NO_SLIP_WHEN_WALKING

	/// The stage of drawing we have reached
	var/drawn_stage = RUNE_STAGE_OUTLINE
	/// Proximity sensor to make people sad if they're nearby
	var/datum/proximity_monitor/advanced/demoraliser/demoraliser
	/// Whether we protect the rune from being cleaned up
	var/clean_proof = FALSE
	/// Timer until the rune can be cleaned up off the floor
	var/protected_timer

/obj/effect/decal/cleanable/traitor_rune/traitor/Destroy()
	deltimer(protected_timer)
	QDEL_NULL(demoraliser)
	return ..()

/obj/effect/decal/cleanable/traitor_rune/HasProximity(atom/movable/proximity_check_mob)
	if (isliving(proximity_check_mob) && get_dist(proximity_check_mob, src) <= 1)
		slip(proximity_check_mob)
	return ..()

/**
 * Makes someone fall over. If it's not the traitor, this counts as demoralising the crew.
 *
 * Arguments
 * * victim - whoever just slipped, point and laugh at them
 */
/obj/effect/decal/cleanable/traitor_rune/proc/slip(mob/living/victim)
	if(victim.movement_type & FLYING)
		return
	if (!victim.slip(slip_time, src, slip_flags))
		return
	SEND_SIGNAL(src, COMSIG_TRAITOR_GRAFFITI_SLIPPED, victim.mind)

/**
 * Sets the "drawing stage" of the rune.
 * This affects the appearance, behaviour, and description of the effect.
 *
 * Arguments
 * * stage - new stage to apply
 */
/obj/effect/decal/cleanable/traitor_rune/proc/set_stage(stage)
	drawn_stage = stage
	switch(drawn_stage)
		if (RUNE_STAGE_OUTLINE)
			icon_state = "traitor_rune_outline"
			desc = "It looks like it's going to be... the Syndicate logo?"

		if (RUNE_STAGE_COLOURED, RUNE_STAGE_REMOVABLE)
			icon_state = "traitor_rune_done"
			desc = "A large depiction of the Syndicate logo."
			clean_proof = FALSE

		if (RUNE_STAGE_COMPLETE)
			icon_state = "traitor_rune_sheen"
			desc = "A large depiction of the Syndicate logo. It looks slippery."
			var/datum/demoralise_moods/graffiti/mood_category = new()
			demoraliser = new(src, 7, TRUE, mood_category)
			clean_proof = TRUE
			protected_timer = addtimer(CALLBACK(src, PROC_REF(set_stage), RUNE_STAGE_REMOVABLE), 5 MINUTES)

/obj/effect/decal/cleanable/traitor_rune/wash(clean_types)
	if (clean_proof)
		return FALSE

	return ..()

#undef RUNE_STAGE_OUTLINE
#undef RUNE_STAGE_COLOURED
#undef RUNE_STAGE_COMPLETE
