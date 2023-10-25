#define ELDRITCH_PAINTING "eldritch_painting_mood"

/obj/item/poster/eldritch_painting
	name = "The sister and He Who Wept"
	poster_type = /obj/structure/sign/poster/eldritch_painting
	icon_state = "rolled_traitor"

/obj/structure/sign/poster/eldritch_painting
	poster_item_name = "The sister and He Who Wept"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its seditious themes are likely to demoralise Nanotrasen employees."
	poster_item_icon_state = "rolled_traitor"
	// This stops people hiding their sneaky posters behind signs
	layer = CORGI_ASS_PIN_LAYER
	// A basic proximity sensor
	var/datum/proximity_monitor/advanced/eldritch_painting/base_painting
	// A variable for how many people have to rip the painting
	var/rip_resistance = 10

// Mood applied for ripping the painting
/datum/mood_event/eldritch_painting
	description = "YOU, I SHOULD NOT HAVE DONE THAT!!!"
	mood_change = -6
	category = ELDRITCH_PAINTING
	timeout = 3 MINUTES

/obj/structure/sign/poster/eldritch_painting/on_placed_poster(mob/user)
	base_painting = new(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	RegisterSignal(COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	return ..()

/obj/structure/sign/poster/eldritch_painting/attackby(obj/item/I, mob/user, params)
	if (I.tool_behaviour == TOOL_WIRECUTTER)
		QDEL_NULL(base_painting)
	return ..()

/obj/structure/sign/poster/eldritch_painting/attack_hand(mob/living/user, list/modifiers)
	var/rips = 0
	if(.)
		return
	if(ruined)
		return
	// Has the user already ripped up this painting once?
	if(user.mob_mood.has_mood_of_category(ELDRITCH_PAINTING))
		return
	// Adds one to the amount of rips
	rips +=1
	user.add_mood_event(ELDRITCH_PAINTING, /datum/mood_event/eldritch_painting)
	to_chat(user, span_notice("IT STILL STANDS [rip_resistance-rips] MORE HAVE TO TRY!!!"))
	if(rip_resistance>rips)
		tear_poster(user)
		QDEL_NULL(base_painting)

/obj/structure/sign/poster/eldritch_painting/proc/on_examine(datum/source, mob/living/examiner)
	SIGNAL_HANDLER
	if(IS_HERETIC(examiner))
		examiner.remove_status_effect(/datum/hallucination)
		to_chat(examiner, span_notice("Oh, what arts! Just gazing upon it clears your mind."))
	else
		examiner.remove_status_effect(/datum/hallucination/delusion/preset/heretic)
		to_chat(examiner, span_notice("Respite, for now...."))

/obj/structure/sign/poster/eldritch_painting/Destroy()
	QDEL_NULL(base_painting)
	UnregisterSignal(COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	return ..()

/*
 * Applies an affect on view
 *
 * - Applies affects on examine
 */
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
 */
/datum/brain_trauma/severe/weeping
	name = "The Weeping"
	desc = "Patient hallucinates everyone as a figure called He Who Wept"
	scan_desc = "H_E##%%%WEEP6%11S!!,)()"
	gain_text = span_warning("HE WEEPS AND I WILL SEE HIM ONCE MORE")
	lose_text = span_notice("You feel the tendrils of something slip from your mind.")


/datum/brain_trauma/severe/weeping/on_life(seconds_per_tick, times_fired)
	var/chance_to_cause_hallucination = 1
	if(owner.stat != CONSCIOUS || owner.IsSleeping() || owner.IsUnconscious())
		return
	if(SPT_PROB(0.5 * chance_to_cause_hallucination, seconds_per_tick))
		owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	else
		chance_to_cause_hallucination +=0.2

/datum/brain_trauma/severe/weeping/on_gain()
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	..()

/datum/brain_trauma/severe/weeping/on_lose()
	owner.remove_status_effect(/datum/hallucination/delusion/preset/heretic)
	return ..()









#undef ELDRITCH_PAINTING
