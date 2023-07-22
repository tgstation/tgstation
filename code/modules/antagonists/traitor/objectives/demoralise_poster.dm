/datum/traitor_objective/demoralise/poster
	name = "Sow doubt among the crew %VIEWS% times using Syndicate propaganda."
	description = "Use the button below to materialize a pack of posters, \
		which will demoralise nearby crew members (especially those in positions of authority). \
		If your posters are destroyed before they are sufficiently upset, this objective will fail. \
		Try hiding some broken glass behind your poster before you hang it to give  \
		do-gooders who try to take it down a hard time!"

	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES
	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	duplicate_type = /datum/traitor_objective/demoralise/poster
	/// Have we handed out a box of stuff yet?
	var/granted_posters = FALSE
	/// All of the posters the traitor gets, if this list is empty they've failed
	var/list/obj/structure/sign/poster/traitor/posters = list()

/datum/traitor_objective/demoralise/poster/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if (!granted_posters)
		buttons += add_ui_button("", "Pressing this will materialize a box of posters in your hand.", "wifi", "summon_gear")
	else
		buttons += add_ui_button("[length(posters)] posters remaining", "This many propaganda posters remain active somewhere on the station.", "box", "none")
		buttons += add_ui_button("[demoralised_crew_events] / [demoralised_crew_required] propagandised", "This many crew have been exposed to propaganda, out of a required [demoralised_crew_required].", "wifi", "none")
	return buttons

#define POSTERS_PROVIDED 3

/datum/traitor_objective/demoralise/poster/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if ("summon_gear")
			if (granted_posters)
				return

			granted_posters = TRUE
			var/obj/item/storage/box/syndie_kit/posterbox = new(user.drop_location())
			for(var/i in 1 to POSTERS_PROVIDED)
				var/obj/item/poster/traitor/added_poster = new /obj/item/poster/traitor(posterbox)
				var/obj/structure/sign/poster/traitor/poster_when_placed = added_poster.poster_structure
				posters += poster_when_placed
				RegisterSignal(poster_when_placed, COMSIG_DEMORALISING_EVENT, PROC_REF(on_mood_event))
				RegisterSignal(poster_when_placed, COMSIG_POSTER_TRAP_SUCCEED, PROC_REF(on_triggered_trap))
				RegisterSignal(poster_when_placed, COMSIG_QDELETING, PROC_REF(on_poster_destroy))

			user.put_in_hands(posterbox)
			posterbox.balloon_alert(user, "the box materializes in your hand")

#undef POSTERS_PROVIDED

/datum/traitor_objective/demoralise/poster/ungenerate_objective()
	for (var/poster in posters)
		UnregisterSignal(poster, COMSIG_DEMORALISING_EVENT)
		UnregisterSignal(poster, COMSIG_QDELETING)
	posters.Cut()
	return ..()

/**
 * Called if someone gets glass stuck in their hand from one of your posters.
 *
 * Arguments
 * * victim - A mob who just got something stuck in their hand.
 */
/datum/traitor_objective/demoralise/poster/proc/on_triggered_trap(datum/source, mob/victim)
	SIGNAL_HANDLER
	on_mood_event(victim.mind)

/**
 * Handles a poster being destroyed, increasing your progress towards failure.
 *
 * Arguments
 * * poster - A poster which someone just ripped up.
 */
/datum/traitor_objective/demoralise/poster/proc/on_poster_destroy(obj/structure/sign/poster/traitor/poster)
	SIGNAL_HANDLER
	posters.Remove(poster)
	UnregisterSignal(poster, COMSIG_DEMORALISING_EVENT)
	if (length(posters) <= 0)
		to_chat(handler.owner, span_warning("The trackers on your propaganda posters have stopped responding."))
		fail_objective(penalty_cost = telecrystal_penalty)

