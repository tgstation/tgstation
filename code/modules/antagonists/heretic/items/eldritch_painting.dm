
// The sister and He Who Wept eldritch painting
// All eldritch paintings are based on this one, with some light changes
/obj/item/wallframe/painting/eldritch
	name = "The sister and He Who Wept"
	desc = "A beautiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN."
	icon = 'icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch
	pixel_shift = 30

/obj/structure/sign/painting/eldritch
	name = "The sister and He Who Wept"
	desc = "A beautiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN. Destroyable with wirecutters."
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// This stops people hiding their sneaky posters behind signs
	layer = CORGI_ASS_PIN_LAYER
	// A basic proximity sensor
	var/datum/proximity_monitor/advanced/eldritch_painting/base_painting
	// Set to false since we don't want this to persist
	persistence_id = FALSE

// Mood applied for ripping the painting
// These moods are here to check hallucinations and provide easier user feedback
/datum/mood_event/eldritch_painting
	description = "YOU, I SHOULD NOT HAVE DONE THAT!!!"
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping
	description = "HE IS HERE, AND HE WEEPS!"
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/eldritch_painting/weeping_heretic
	description = "Oh such arts! They truly inspire me!"
	mood_change = 5
	timeout = 5 MINUTES

/datum/mood_event/eldritch_painting/weeping_withdrawl
	description = "My mind is clear from his influence."
	mood_change = 1
	timeout = 5 MINUTES

/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	base_painting = new(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	return ..()

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	user.add_mood_event("ripped_eldritch_painting", /datum/mood_event/eldritch_painting)
	to_chat(user, span_notice("laugher echoes through your mind"))
	QDEL_NULL(base_painting)
	qdel(src)

/obj/structure/sign/painting/eldritch/examine(mob/living/carbon/user)
	if(IS_HERETIC(user))
		// If they already have the positive moodlet return
		if("heretic_eldritch_painting" in user.mob_mood.mood_events)
			return
		to_chat(user, span_notice("Oh, what arts! Just gazing upon it clears your mind."))
		// Adjusts every hallucination by -300, thus removing them if we have any
		user.adjust_hallucinations(-300 SECONDS)
		// Adds a very good mood event to the heretic
		user.add_mood_event("heretic_eldritch_painting", /datum/mood_event/eldritch_painting/weeping_heretic)
	// Do they have the mood event added with the hallucination?
	if("eldritch_weeping" in user.mob_mood.mood_events)
		to_chat(user, span_notice("Respite, for now...."))
		// Remove the mood event associated with the hallucinations
		user.mob_mood.mood_events.Remove("eldritch_weeping")
		// Add a mood event that causes the hallucinations to not trigger anymore
		user.add_mood_event("weeping_withdrawl", /datum/mood_event/eldritch_painting/weeping_withdrawl)

/obj/structure/sign/painting/eldritch/Destroy()
	QDEL_NULL(base_painting)
	return ..()

// Applies an affect on view
/datum/proximity_monitor/advanced/eldritch_painting

/datum/proximity_monitor/advanced/eldritch_painting/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	. = ..()

/datum/proximity_monitor/advanced/eldritch_painting/field_turf_crossed(atom/movable/crossed, turf/location)
	if (!isliving(crossed) || !can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/datum/proximity_monitor/advanced/eldritch_painting/proc/on_seen(mob/living/carbon/human/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	if (viewer.has_trauma_type(/datum/brain_trauma/severe/weeping))
		return
	if(IS_HERETIC(viewer))
		return
	to_chat(viewer, span_notice("Wow, great poster!"))
	viewer.gain_trauma(/datum/brain_trauma/severe/weeping, TRAUMA_RESILIENCE_ABSOLUTE)

/*
 * The brain traumas that these eldritch paintings apply
 * This one is for "The Sister and He Who Wept" or /obj/structure/sign/painting/eldritch
 */
/datum/brain_trauma/severe/weeping
	name = "The Weeping"
	desc = "Patient hallucinates everyone as a figure called He Who Wept"
	scan_desc = "H_E##%%%WEEP6%11S!!,)()"
	gain_text = span_warning("HE WEEPS AND I WILL SEE HIM ONCE MORE")
	lose_text = span_notice("You feel the tendrils of something slip from your mind.")

/datum/brain_trauma/severe/weeping/on_life(seconds_per_tick, times_fired)
	if(owner.stat != CONSCIOUS || owner.IsSleeping() || owner.IsUnconscious())
		return
	// If they have the weeping withdrawl mood event return
	if("weeping_withdrawl" in owner.mob_mood.mood_events)
		return
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	// If they already have the weeping mood event return, if they don't give them it
	if("eldritch_weeping" in owner.mob_mood.mood_events)
		return
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	..()

/datum/brain_trauma/severe/weeping/on_gain()
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	..()

/datum/brain_trauma/severe/weeping/on_lose()
	to_chat(owner, span_notice("You feel the tendrils of something dark slip from your mind..."))
	owner.mob_mood.mood_events.Remove("eldritch_weeping")
	..()

// The First Desire
/obj/item/wallframe/painting/eldritch/desire
	name = "The First Desire"
	desc = "A perfect artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN."
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch/desire

/obj/structure/sign/painting/eldritch/desire
	name = "The First Desire"
	desc = "A perfect artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN. Destroyable with wirecutters."
	icon_state = "frame-empty"
	// A basic proximity sensor
	var/datum/proximity_monitor/advanced/eldritch_painting/desire/desire_painting

// Specific proximity monitor for The First Desire or /obj/item/wallframe/painting/eldritch/desire
/datum/proximity_monitor/advanced/eldritch_painting/desire

/datum/proximity_monitor/advanced/eldritch_painting/desire/on_seen(mob/living/carbon/human/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	if (viewer.has_trauma_type(/datum/brain_trauma/severe/weeping))
		return
	if(IS_HERETIC(viewer))
		return
	to_chat(viewer, span_notice("Wow, great poster!"))
	viewer.gain_trauma(/datum/brain_trauma/severe/weeping, TRAUMA_RESILIENCE_ABSOLUTE)

/obj/structure/sign/painting/eldritch/desire/Initialize(mapload, dir, building)
	desire_painting = new(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	return ..()
