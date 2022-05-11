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
 * Emits a hallucinating pulse around the passed atom.
 * Affects everyone in the passed radius who can view the center,
 * except for those with TRAIT_MADNESS_IMMUNE, or those who are blind.
 *
 * center - required, the center of the pulse
 * radius - the radius around that the pulse reaches
 * hallucination_duration - how much hallucination is added by the pulse. reduced based on distance to the center.
 * hallucination_max_duration - a cap on how much hallucination can be added
 * optional_messages - optional list of messages passed. Those affected by pulses will be given one of the messages in said list.
 */
/proc/visible_hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/nearby_living in view(center, radius))
		if (HAS_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE) || (nearby_living.mind && HAS_TRAIT(nearby_living.mind, TRAIT_MADNESS_IMMUNE)))
			continue

		if (nearby_living.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.adjust_timed_status_effect(hallucination_duration * dist, /datum/status_effect/hallucination, max_duration = hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))

/// A global list of all ongoing hallucinations.
GLOBAL_LIST_EMPTY(all_ongoing_hallucinations)

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
	var/feedback_details = ""
	/// The mob we're targeting with the hallucination.
	var/mob/living/hallucinator

/datum/hallucination/New(mob/living/hallucinator)
	if(!hallucinator)
		stack_trace("[type] was created without a hallucinating mob.")
		qdel(src)
		return

	src.hallucinator = hallucinator
	RegisterSignal(hallucinator, COMSIG_PARENT_QDELETING, .proc/target_deleting)
	GLOB.all_ongoing_hallucinations += src

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

	GLOB.all_ongoing_hallucinations -= src
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

	/// The created image, what we look like.
	var/image/shown_image
	/// The icon file the image uses. If null, we have no image
	var/image_icon
	/// The icon state the image uses
	var/image_state
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

/obj/effect/hallucination/Initialize(mapload, datum/hallucination/parent)
	. = ..()
	if(!parent)
		stack_trace("[type] was created without a parent hallucination.")
		return INITIALIZE_HINT_QDEL

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/parent_deleting)
	src.parent = parent

	if(image_icon)
		show_image()

/obj/effect/hallucination/Destroy(force)
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = null

	if(shown_image)
		parent.hallucinator.client?.images -= shown_image

	return ..()

/// Signal proc for [COMSIG_PARENT_QDELETING], if our associated hallucination deletes, we should too
/obj/effect/hallucination/proc/parent_deleting(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/// Generates the image which we take on.
/obj/effect/hallucination/proc/generate_image()
	var/image/created = image(image_icon, src, image_state, image_layer, dir = src.dir)
	created.plane = image_plane
	created.pixel_x = image_pixel_x
	created.pixel_y = image_pixel_y
	if(image_color)
		created.color = image_color
	return created

/// Shows the image we generated to the person hallucinating (the hallucinator var of our parent).
/obj/effect/hallucination/proc/show_image()
	if(!image_icon)
		return
	if(shown_image)
		parent.hallucinator.client?.images -= shown_image
	shown_image = generate_image()
	parent.hallucinator.client?.images |= shown_image

// Whenever we perform icon updates, regenerate our image
/obj/effect/hallucination/update_icon(updates = ALL)
	. = ..()
	show_image()

// If we move for some reason, regenerate our image
/obj/effect/hallucination/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!loc)
		return
	show_image()
