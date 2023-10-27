
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
	timeout = 10 SECONDS

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
	to_chat(viewer, span_notice("Wow, what a nice painting! She is so fair, and HE WEEPS STILL!!!"))
	viewer.gain_trauma(/datum/brain_trauma/severe/weeping, TRAUMA_RESILIENCE_ABSOLUTE)

/*
 * A brain trauma that this eldritch paintings apply
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
	// If they already have the weeping mood event return, its duration is the same as the hallucination so this is done to prevent large amounts of lag
	if("eldritch_weeping" in owner.mob_mood.mood_events)
		return
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	..()

/datum/brain_trauma/severe/weeping/on_gain()
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	..()



// The First Desire painting, using a lot of the painting/eldritch framework
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

// Moodlets used to track hunger and provide feedback
/datum/mood_event/eldritch_painting/desire_heretic
	description = "A part gained, the manus takes and gives. What did it take from me?"
	mood_change = -2
	timeout = 1 MINUTES

/obj/structure/sign/painting/eldritch/desire/Initialize(mapload, dir, building)
	desire_painting = new(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	return ..()

/obj/structure/sign/painting/eldritch/desire/wirecutter_act(mob/living/user, obj/item/I)
	user.add_mood_event("ripped_eldritch_painting", /datum/mood_event/eldritch_painting)
	to_chat(user, span_notice("A hungering echo fills your mind"))
	QDEL_NULL(desire_painting)
	qdel(src)

/obj/structure/sign/painting/eldritch/desire/examine(mob/living/carbon/user)
	if(IS_HERETIC(user))
		// If they already have the negative moodlet return
		if("heretic_eldritch_hunger" in user.mob_mood.mood_events)
			return
		// A list made of the organs and bodyparts the heretic possess
		var/list/random_bodypart_or_organ = list(
			/obj/item/organ/internal/brain,
			/obj/item/organ/internal/lungs,
			/obj/item/organ/internal/eyes,
			/obj/item/organ/internal/ears,
			/obj/item/organ/internal/heart,
			/obj/item/organ/internal/liver,
			/obj/item/organ/internal/stomach,
			/obj/item/organ/internal/appendix,
			/obj/item/bodypart/arm/left,
			/obj/item/bodypart/arm/right,
			/obj/item/bodypart/leg/left,
			/obj/item/bodypart/leg/right
		)
		var/organ_or_bodypart_to_spawn = pick(random_bodypart_or_organ)
		new organ_or_bodypart_to_spawn(src.loc)
		to_chat(user, span_notice("A piece of flesh crawls out of the painting and flops onto the floor."))
		// Adds a negative mood event to our heretic
		user.add_mood_event("heretic_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_heretic)
	// Do they have the mood event added with the hallucination?
	if (user.has_trauma_type(/datum/brain_trauma/severe/flesh_desire))

// Specific proximity monitor for The First Desire or /obj/item/wallframe/painting/eldritch/desire
/datum/proximity_monitor/advanced/eldritch_painting/desire

/datum/proximity_monitor/advanced/eldritch_painting/desire/on_seen(mob/living/carbon/human/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	if (viewer.has_trauma_type(/datum/brain_trauma/severe/flesh_desire))
		return
	if(IS_HERETIC(viewer))
		return
	to_chat(viewer, span_notice("Oh, what arts! Though it does make me hungry, maybe there is an organ nearby?"))
	viewer.gain_trauma(/datum/brain_trauma/severe/flesh_desire, TRAUMA_RESILIENCE_ABSOLUTE)

/*
 * A brain trauma that this eldritch paintings apply
 * This one is for "The First Desire" or /obj/structure/sign/painting/eldritch/desire
 */
/datum/brain_trauma/severe/flesh_desire
	name = "The Desire for Flesh"
	desc = "Patient seems to only be able to eat organs or raw flesh for nutrients, also seems to become hungrier at a faster rate"
	scan_desc = "H_(82882)G3E:__))9R"
	gain_text = span_warning("I feel a hunger, only organs and flesh will feed it...")
	lose_text = span_notice("Your stomach no longer craves flesh, and your tongue feels duller.")
	/// How much faster we loose hunger
	var/hunger_rate = 10

/datum/brain_trauma/severe/flesh_desire/on_gain()
	// Allows them to eat faster, mainly for flavor
	owner.add_traits(TRAIT_VORACIOUS)
	// We don't want this to be bypassed by Aguesia so if they have it, remove it
	if(HAS_TRAIT(owner, TRAIT_AGEUSIA))
		owner.remove_traits(TRAIT_AGEUSIA)
	// If they have a tongue, make it crave meat
	var/obj/item/organ/internal/tongue/tongue = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_foodtypes = GORE | MEAT
	..()

/datum/brain_trauma/severe/flesh_desire/on_life(seconds_per_tick, times_fired)
	// Causes them to need to eat at 10x the normal rate
	owner.adjust_nutrition(hunger_rate * HUNGER_FACTOR)
	if(prob(2))
		to_chat(owner, span_notice("You feel a ravenous hunger for flesh..."))

/datum/brain_trauma/severe/flesh_desire/on_lose()
	owner.remove_traits(TRAIT_VORACIOUS)
	// After loosing this trauma you also loose the ability to taste, sad!
	owner.add_traits(TRAIT_AGEUSIA)
	..()
