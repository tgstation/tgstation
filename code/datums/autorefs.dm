/// Creates a autoref to the given input.
/// See /datum/autoref's documentation for more information.
/proc/AUTOREF(datum/input)
	if(istype(input) && !QDELING(input))
		if(isautoref(input))
			return input
		return input.auto_reference ||= new(input)

/**
 * An autoref holds an automatically managed reference to a datum.
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
	/// The datum instance that this autoref is keeping track of
	VAR_PRIVATE/datum/instance

/datum/autoref/New(datum/thing)
	instance = thing

/datum/autoref/Destroy(force)
	qdel(instance)
	return force ? ..() : QDEL_HINT_LETMELIVE

/**
 * Retrieves the datum that this autoref is referencing.
 *
 * This will return `null` if the datum was deleted. This MUST be respected.
 */
/datum/autoref/proc/resolve()
	return instance

/datum/autoref/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /autoref ---")
	VV_DROPDOWN_OPTION(VV_HK_AUTOREF_RESOLVE, "Go to reference")

/datum/autoref/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return

	if(href_list[VV_HK_AUTOREF_RESOLVE] && instance)
		usr.client.debug_variables(instance)
