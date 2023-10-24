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
	// A variable for how many people have to attempt to rip the painting
	var/rip_resistance = 4

// Mood applied for ripping the painting
/datum/mood_event/eldritch_painting
	description = "YOU, I SHOULD NOT HAVE DONE THAT!!!"
	mood_change = -6
	category = ELDRITCH_PAINTING
	timeout = 3 MINUTES

/obj/structure/sign/poster/eldritch_painting/on_placed_poster(mob/user)
	base_painting = new(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	return ..()

/obj/structure/sign/poster/eldritch_painting/attackby(obj/item/I, mob/user, params)
	if (I.tool_behaviour == TOOL_WIRECUTTER)
		QDEL_NULL(base_painting)
	return ..()

/obj/structure/sign/poster/eldritch_painting/attack_hand(mob/user, list/modifiers)
	. = ..()
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
	if(rip_resistance>rips)
		tear_poster(user)
		QDEL_NULL(base_painting)

/obj/structure/sign/poster/eldritch_painting/Destroy()
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
	RegisterSignal(host, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/proximity_monitor/advanced/eldritch_painting/field_turf_crossed(atom/movable/crossed, turf/location)
	if (!isliving(crossed) || !can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/datum/proximity_monitor/advanced/eldritch_painting/proc/on_examine(datum/source, mob/examiner)
	SIGNAL_HANDLER
	if (isliving(examiner))
		on_seen(examiner)

/datum/proximity_monitor/advanced/eldritch_painting/proc/on_seen(mob/living/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	if (viewer.has_status_effect())
		return
	if(IS_HERETIC(viewer))
		return
	to_chat(viewer, span_notice("Wow, great poster!"))
	viewer.add_mood_event(POSTER_MOOD_CAT, /datum/mood_event/poster_mood)
