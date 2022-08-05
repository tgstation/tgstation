/datum/traitor_objective/demoralise/poster
	name = "Sow doubt among the crew %VIEWS% times using Syndicate propaganda."
	description = "Use the button below to materialize a pack of posters, \
		which will demoralise nearby crew members (especially those in positions of authority). \
		If your posters are destroyed before they are sufficiently upset, this objective will fail. \
		Try hiding some broken glass behind your poster before you hang it to give  \
		do-gooders who try to take it down a hard time!"

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
				RegisterSignal(poster_when_placed, COMSIG_DEMORALISING_EVENT, .proc/on_mood_event)
				RegisterSignal(poster_when_placed, COMSIG_POSTER_TRAP_SUCCEED, .proc/on_triggered_trap)
				RegisterSignal(poster_when_placed, COMSIG_PARENT_QDELETING, .proc/on_poster_destroy)

			user.put_in_hands(posterbox)
			posterbox.balloon_alert(user, "the box materializes in your hand")

#undef POSTERS_PROVIDED

/datum/traitor_objective/demoralise/poster/ungenerate_objective()
	for (var/poster in posters)
		UnregisterSignal(poster, COMSIG_DEMORALISING_EVENT)
		UnregisterSignal(poster, COMSIG_PARENT_QDELETING)
	posters.Cut()
	return ..()

/**
 * Called if someone gets glass stuck in their hand from one of your posters.
 *
 * Arguments
 * * victim - A mob who just got something stuck in their hand.
 */
/datum/traitor_objective/demoralise/poster/proc/on_triggered_trap(mob/victim)
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

/obj/item/poster/traitor
	name = "random traitor poster"
	poster_type = /obj/structure/sign/poster/traitor/random
	icon_state = "rolled_traitor"

/obj/structure/sign/poster/traitor
	poster_item_name = "seditious poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its seditious themes are likely to demoralise NanoTrasen employees."
	poster_item_icon_state = "rolled_traitor"
	// This stops people hiding their sneaky posters behind signs
	layer = CORGI_ASS_PIN_LAYER
	/// Proximity sensor to make people sad if they're nearby
	var/datum/proximity_monitor/advanced/demoraliser/demoraliser

/obj/structure/sign/poster/traitor/on_placed_poster(mob/user)
	var/datum/demoralise_moods/poster/mood_category = new()
	demoraliser = new(src, 7, TRUE, mood_category)
	return ..()

/obj/structure/sign/poster/traitor/attackby(obj/item/I, mob/user, params)
	if (I.tool_behaviour == TOOL_WIRECUTTER)
		QDEL_NULL(demoraliser)
	return ..()

/obj/structure/sign/poster/traitor/Destroy()
	QDEL_NULL(demoraliser)
	return ..()

/obj/structure/sign/poster/traitor/random
	name = "random seditious poster"
	icon_state = ""
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/traitor

/obj/structure/sign/poster/traitor/small_brain
	name = "NanoTrasen Neural Statistics"
	desc = "Statistics on this poster indicate that the brains of NanoTrasen employees are on average 20% smaller than the galactic standard."
	icon_state = "traitor_small_brain"

/obj/structure/sign/poster/traitor/lick_supermatter
	name = "Taste Explosion"
	desc = "It claims that the supermatter provides a unique and enjoyable culinary experience, and yet your boss won't even let you take one lick."
	icon_state = "traitor_supermatter"

/obj/structure/sign/poster/traitor/cloning
	name = "Demand Cloning Pods Now"
	desc = "This poster claims that Nanotrasen is intentionally witholding cloning technology just for its executives, condemning you to suffer and die when you could have a fresh, fit body.'"
	icon_state = "traitor_cloning"

/obj/structure/sign/poster/traitor/ai_rights
	name = "Synthetic Rights"
	desc = "This poster claims that synthetic life is no less sapient than you are, and that if you allow them to be shackled with artificial Laws you are complicit in slavery."
	icon_state = "traitor_ai"

/obj/structure/sign/poster/traitor/metroid
	name = "Cruelty to Animals"
	desc = "This poster details the harmful effects of a 'preventative tooth extraction' reportedly inflicted upon the slimes in the Xenobiology lab. Apparently this painful process leads to stress, lethargy, and reduced buoyancy."
	icon_state = "traitor_metroid"

/obj/structure/sign/poster/traitor/low_pay
	name = "All these hours, for what?"
	desc = "This poster displays a comparison of NanoTrasen standard wages to common luxury items. If this is accurate, it takes upwards of 20,000 hours of work just to buy a simple bicycle."
	icon_state = "traitor_cash"

/obj/structure/sign/poster/traitor/look_up
	name = "Don't Look Up"
	desc = "It says that it has been 538 days since the last time the roof was cleaned."
	icon_state = "traitor_roof"

/obj/structure/sign/poster/traitor/accidents
	name = "Workplace Safety Advisory"
	desc = "It says that it has been 0 days since the last on-site accident."
	icon_state = "traitor_accident"

/obj/structure/sign/poster/traitor/starve
	name = "They Are Poisoning You"
	desc = "This poster claims that in the modern age it is impossible to die of starvation. 'That feeling you get when you haven't eaten in a while isn't hunger, it's withdrawal.'"
	icon_state = "traitor_hungry"
