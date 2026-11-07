/// Creates a autoref to the given input.
/// See /datum/autoref's documentation for more information.
/proc/AUTOREF(datum/input)
	if(!istype(input) || QDELING(input))
		return

	if(isautoref(input))
		return input
	if(input.datum_flags & DF_WEAK_AUTOREF)
		return input.auto_reference ||= new /datum/autoref/weak(input)
	return input.auto_reference ||= new /datum/autoref(input)

/datum/proc/create_autoref() //Forced creation for admin proccalls
	return AUTOREF(src)

/**
 * A autoref holds a non-owning reference to a datum.
 * The datum can be referenced again using `resolve()`.
 *
 * To figure out why this is important, you must understand how deletion in
 * BYOND works.
 *
 * Imagine a datum as a TV in a living room. When one person enters to watch
 * TV, they turn it on. Others can come into the room and watch the TV.
 * When the last person leaves the room, they turn off the TV because it's
 * no longer being used.
 *
 * A datum being deleted tells everyone who's watching the TV to stop.
 * If everyone leaves properly (AKA cleaning up their references), then the
 * last person will turn off the TV, and everything is well.
 * However, if someone is resistant (holds a hard reference after deletion),
 * then someone has to walk in, drag them away, and turn off the TV forecefully.
 * This process is very slow, and it's known as hard deletion.
 *
 * This is where auto references come in. Auto references don't count as someone
 * watching the TV. Thus, when what it's referencing is destroyed, it will
 * hopefully clean up properly, and limit hard deletions.
 *
 * A common use case for auto references is holding onto what created itself.
 * For example, if a machine wanted to know what its last user was, it might
 * create a `var/mob/living/last_user`. However, this is a strong reference to
 * the mob, and thus will force a hard deletion when that mob is deleted.
 * It is often better in this case to instead create a autoref to the user,
 * meaning this type definition becomes `var/datum/autoref/last_user`.
 *
 * A good rule of thumb is that you should hold strong references to things
 * that you *own*. For example, a dog holding a chew toy would be the owner
 * of that chew toy, and thus a `var/obj/item/chew_toy` reference is fine
 * (as long as it is cleaned up properly).
 * However, a chew toy does not own its dog, so a `var/mob/living/dog/owner`
 * might be inferior to a autoref.
 * This is also a good rule of thumb to avoid circular references, such as the
 * chew toy example. A circular reference that doesn't clean itself up properly
 * will always hard delete.
 */
/datum/autoref
	/// The reference held by this autoref. Either a text reference, or an actual reference. Depends on the target's datum flags.
	VAR_PRIVATE/datum/reference

/datum/autoref/New(datum/thing)
	reference = thing
	RegisterSignal(reference, COMSIG_POST_QDELETED, PROC_REF(clear_reference))

/datum/autoref/proc/clear_reference(datum/source, hint)
	SIGNAL_HANDLER
	if(hint == QDEL_HINT_LETMELIVE)
		return
	reference.auto_reference = null
	reference = null

/datum/autoref/Destroy(force)
	qdel(resolve())
	// Let BYOND autoGC this when nothing is using it anymore.
	return force ? ..() : QDEL_HINT_LETMELIVE

/**
 * Retrieves the datum that this autoref is referencing.
 *
 * This will return `null` if the datum was deleted. This MUST be respected.
 */
/datum/autoref/proc/resolve()
	return reference?.gc_destroyed ? null : reference

/datum/autoref/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /autoref ---")
	VV_DROPDOWN_OPTION(VV_HK_AUTOREF_RESOLVE, "Go to reference")

/datum/autoref/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return

	if(href_list[VV_HK_AUTOREF_RESOLVE])
		var/datum/R = resolve()
		if(R)
			usr.client.debug_variables(R)

/datum/autoref/weak/New(datum/thing)
	reference = REF(thing)

/datum/autoref/weak/resolve()
	var/datum/resolved = locate(reference)
	return (QDELETED(resolved) || resolved.auto_reference != src) ? null : resolved
