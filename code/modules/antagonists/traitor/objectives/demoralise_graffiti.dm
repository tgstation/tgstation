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

			RegisterSignal(spray, COMSIG_QDELETING, PROC_REF(on_spray_destroyed))
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
	UnregisterSignal(spray, COMSIG_QDELETING)
	UnregisterSignal(spray, COMSIG_TRAITOR_GRAFFITI_DRAWN)
	RegisterSignal(drawn_rune, COMSIG_QDELETING, PROC_REF(on_rune_destroyed))
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
		UnregisterSignal(rune, COMSIG_QDELETING)
		UnregisterSignal(rune, COMSIG_DEMORALISING_EVENT)
		UnregisterSignal(rune, COMSIG_TRAITOR_GRAFFITI_SLIPPED)
		rune = null
	return ..()


