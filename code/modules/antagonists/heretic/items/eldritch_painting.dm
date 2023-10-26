#define ELDRITCH_PAINTING "eldritch_painting_mood"

/obj/item/wallframe/painting/eldritch
	name = "The sister and He Who Wept"
	desc = "A perfect artwork showing a beutiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN."
	icon = 'icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch
	pixel_shift = 30

/obj/structure/sign/painting/eldritch
	name = "The sister and He Who Wept"
	desc = "A perfect artwork showing a beutiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN. Destroyable with wirecutters."
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	base_icon_state = "frame"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// This stops people hiding their sneaky posters behind signs
	layer = CORGI_ASS_PIN_LAYER
	// A basic proximity sensor
	var/datum/proximity_monitor/advanced/eldritch_painting/base_painting
	// A variable for how many people have to rip the painting
	var/rip_resistance = 10
	// Set to false since we don't want this to persist
	persistence_id = FALSE

// Mood applied for ripping the painting
/datum/mood_event/eldritch_painting
	description = "YOU, I SHOULD NOT HAVE DONE THAT!!!"
	mood_change = -6
	category = ELDRITCH_PAINTING
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping
	description = "I MUST SEE THE HIM AGAIN, I MUST GAZE UPON THE ARTS!"
	mood_change = -2
	timeout = 1 MINUTES

/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	base_painting = new(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	return ..()

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	var/rips = 0
	// Has the user already ripped up this painting once?
	if(user.mob_mood.has_mood_of_category(ELDRITCH_PAINTING))
		return
	// Adds one to the amount of rips
	rips +=1
	user.add_mood_event(/datum/mood_event/eldritch_painting)
	to_chat(user, span_notice("IT STILL STANDS [rip_resistance-rips] MORE HAVE TO TRY!!!"))
	if(rip_resistance>rips)
		QDEL_NULL(base_painting)
		qdel(src)

/obj/structure/sign/painting/eldritch/examine(mob/living/carbon/user)
	if(IS_HERETIC(user))
		to_chat(user, span_notice("Oh, what arts! Just gazing upon it clears your mind."))
	if(user.has_trauma_type(/datum/brain_trauma/severe/weeping))
		to_chat(user, span_notice("Respite, for now...."))
	user.adjust_hallucinations(user.hallucinations)

/obj/structure/sign/painting/eldritch/Destroy()
	QDEL_NULL(base_painting)
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
	if(owner.stat != CONSCIOUS || owner.IsSleeping() || owner.IsUnconscious())
		return
	if(has_hallucination)
		return
	owner.add_mood_event(/datum/mood_event/eldritch_painting/weeping)
	if(times_fired>600)
		owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	..()

/datum/brain_trauma/severe/weeping/on_gain()
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	..()

/datum/brain_trauma/severe/weeping/on_lose()
	owner.adjust_hallucinations(-300 SECONDS)
	..()









#undef ELDRITCH_PAINTING
