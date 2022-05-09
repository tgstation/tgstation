/// Causes a hallucination of a certain type to the mob.
/mob/living/proc/cause_hallucination(datum/hallucination/type, source = "an external source", ...)
	if(!ispath(type, /datum/hallucination))
		CRASH("cause_hallucination was given a non-hallucination type.")

	var/datum/hallucination/new_hallucination = new type(src, source)
	new_hallucination.log_hallucination()
	new_hallucination.start()

/**
 * # Hallucination datum.
 *
 * Handles effects and such of a hallucination on a living mob.
 * Triggered, usually, by [/datum/status_effect/hallucination](the hallucination effect).
 */
/datum/hallucination
	/// The source of the hallucination, string. Used for investigate.
	var/source
	/// Extra info about the hallucination displayed in the log.
	var/feedback_details
	/// The mob we're targeting with the hallucination.
	var/mob/living/target

/datum/hallucination/New(mob/living/target, source = "an external source")
	if(!target)
		stack_trace("[type] was created without a target.")
		qdel(src)
		return

	src.target = target
	src.source = source

	// Cancel early if the target is deleted
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/target_deleting)

/datum/hallucination/proc/target_deleting()
	SIGNAL_HANDLER

	qdel(src)

/datum/hallucination/proc/wake_and_restore()
	target.set_screwyhud(SCREWYHUD_NONE)
	target.SetSleeping(0)

/datum/hallucination/proc/log_hallucination()
	target.investigate_log("was afflicted with a hallucination of type [type] by [source]. [feedback_details]", INVESTIGATE_HALLUCINATIONS)

/datum/hallucination/proc/start()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("[type] didn't implement any hallucination effects in start.")

/datum/hallucination/Destroy()
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
		target = null

	return ..()

/// Returns a random turf in a ring around the target mob.
/// Useful for sound hallucinations.
/datum/hallucination/proc/random_far_turf()
	var/first_offset = pick(-8, -7, -6, -5, 5, 6, 7, 8)
	var/second_offset = rand(-8, 8)
	var/x_offset
	var/y_offset
	if(prob(50))
		x_offset = first_offset
		y_offset = second_offset
	else
		x_offset = second_offset
		y_offset = first_offset

	return locate(target.x + x_offset, target.y + y_offset, target.z)

/**
 * # Hallucination effect.
 *
 * The visal component to hallucination datums.
 */
/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	var/datum/hallucination/parent

/obj/effect/hallucination/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		stack_trace("[type] was created without a parent hallucination.")
		return INITIALIZE_HINT_QDEL

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/parent_deleting)
	src.parent = parent

/obj/effect/hallucination/Destroy(force)
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = null

	return ..()

/obj/effect/hallucination/proc/parent_deleting(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/obj/effect/hallucination/simple
	var/image/shown_image = null

	var/image_icon = 'icons/mob/alien.dmi'
	var/image_state = "alienh_pounce"
	var/image_pixel_x = 0
	var/image_pixel_y = 0
	var/image_color
	var/image_layer = MOB_LAYER
	var/image_plane = GAME_PLANE

/obj/effect/hallucination/simple/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		return

	show_image()

/obj/effect/hallucination/simple/proc/generate_image()
	var/image/created = image(image_icon, src, image_state, image_layer, dir = src.dir)
	created.plane = image_plane
	created.pixel_x = image_pixel_x
	created.pixel_y = image_pixel_y
	if(image_color)
		created.color = image_color
	return created

/obj/effect/hallucination/simple/proc/show_image()
	if(shown_image)
		parent.target.client?.images -= shown_image
	shown_image = generate_image()
	parent.target.client?.images |= shown_image

/obj/effect/hallucination/simple/update_icon(updates = ALL)
	. = ..()
	show_image()

/obj/effect/hallucination/simple/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!loc)
		return
	show_image()

/obj/effect/hallucination/simple/Destroy()
	if(shown_image)
		parent.target.client?.images -= shown_image

	return ..()
