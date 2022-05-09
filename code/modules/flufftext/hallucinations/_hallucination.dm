/// Causes a hallucination of a certain type to the mob.
/mob/living/proc/cause_hallucination(datum/hallucination/type, source = "an external source", ...)
	if(!ispath(type, /datum/hallucination))
		CRASH("cause_hallucination was given a non-hallucination type.")

	var/list/passed_args = args.Copy(3)
	passed_args.Insert(1, src)

	var/datum/hallucination/new_hallucination = new type(passed_args)
	if(!new_hallucination.start())
		qdel(new_hallucination)
		return

	investigate_log("was afflicted with a hallucination of type [type] by [source]. [new_hallucination.feedback_details]", INVESTIGATE_HALLUCINATIONS)
	return new_hallucination


/**
 * # Hallucination datum.
 *
 * Handles effects of a hallucination on a living mob.
 * Created and triggered via the [cause hallucination proc][/mob/living/proc/cause_hallucination].
 *
 * See also: [the hallucination status effect][/datum/status_effect/hallucination].
 */
/datum/hallucination
	/// Extra info about the hallucination displayed in the log.
	var/feedback_details
	/// The mob we're targeting with the hallucination.
	var/mob/living/hallucinator

/datum/hallucination/New(mob/living/hallucinator)
	if(!hallucinator)
		stack_trace("[type] was created without a hallucinating mob.")
		qdel(src)
		return

	src.hallucinator = hallucinator
	RegisterSignal(hallucinator, COMSIG_PARENT_QDELETING, .proc/target_deleting)

/// Signal proc for [COMSIG_PARENT_QDELETING], if the mob hallucinating us is deletes, we should delete too.
/datum/hallucination/proc/target_deleting()
	SIGNAL_HANDLER

	qdel(src)

/// Starts the hallucination.
/datum/hallucination/proc/start()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("[type] didn't implement any hallucination effects in start.")

/datum/hallucination/Destroy()
	if(hallucinator)
		UnregisterSignal(hallucinator, COMSIG_PARENT_QDELETING)
		hallucinator = null

	return ..()

/// Returns a random turf in a ring around the hallucinator mob.
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

	return locate(hallucinator.x + x_offset, hallucinator.y + y_offset, hallucinator.z)

/**
 * # Hallucination effect.
 *
 * The visal component to hallucination datums.
 */
/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	/// The hallucination that created us.
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

/// Signal proc for [COMSIG_PARENT_QDELETING], if our associated hallucination deletes, we should too
/obj/effect/hallucination/proc/parent_deleting(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/// A subtype of hallucination effects that take on a simple image.
/obj/effect/hallucination/simple
	/// The created image, what we look like
	var/image/shown_image
	/// The icon file the image uses
	var/image_icon = 'icons/mob/alien.dmi'
	/// The icon state the image uses
	var/image_state = "alienh_pounce"
	/// The x pixel offset of the image
	var/image_pixel_x = 0
	/// The y pixel offset of the image
	var/image_pixel_y = 0
	/// Optional, the color of the image
	var/image_color
	/// The layer of the image
	var/image_layer = MOB_LAYER
	/// The plane of the image
	var/image_plane = GAME_PLANE

/obj/effect/hallucination/simple/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		return

	show_image()

/// Generates the image which we take on.
/obj/effect/hallucination/simple/proc/generate_image()
	var/image/created = image(image_icon, src, image_state, image_layer, dir = src.dir)
	created.plane = image_plane
	created.pixel_x = image_pixel_x
	created.pixel_y = image_pixel_y
	if(image_color)
		created.color = image_color
	return created

/// Shows the image we generated to the person hallucinating (the hallucinator var of our parent).
/obj/effect/hallucination/simple/proc/show_image()
	if(shown_image)
		parent.hallucinator.client?.images -= shown_image
	shown_image = generate_image()
	parent.hallucinator.client?.images |= shown_image

// Whenever we perform icon updates, regenerate our image
/obj/effect/hallucination/simple/update_icon(updates = ALL)
	. = ..()
	show_image()

// If we move for some reason, regenerate our image
/obj/effect/hallucination/simple/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!loc)
		return
	show_image()

/obj/effect/hallucination/simple/Destroy()
	if(shown_image)
		parent.hallucinator.client?.images -= shown_image

	return ..()
