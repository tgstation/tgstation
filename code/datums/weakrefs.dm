/// Creates a weakref to the given input.
/// See /datum/weakref's documentation for more information.
/proc/WEAKREF(datum/input)
	if(istype(input) && !QDELETED(input))
		if(istype(input, /datum/weakref))
			return input

		if(!input.weak_reference)
			input.weak_reference = new /datum/weakref(input)
		return input.weak_reference

/datum/proc/create_weakref() //Forced creation for admin proccalls
	return WEAKREF(src)

/**
 * A weakref holds a non-owning reference to a datum.
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
 * This is where weak references come in. Weak references don't count as someone
 * watching the TV. Thus, when what it's referencing is destroyed, it will
 * hopefully clean up properly, and limit hard deletions.
 *
 * A common use case for weak references is holding onto what created itself.
 * For example, if a machine wanted to know what its last user was, it might
 * create a `var/mob/living/last_user`. However, this is a strong reference to
 * the mob, and thus will force a hard deletion when that mob is deleted.
 * It is often better in this case to instead create a weakref to the user,
 * meaning this type definition becomes `var/datum/weakref/last_user`.
 *
 * A good rule of thumb is that you should hold strong references to things
 * that you *own*. For example, a dog holding a chew toy would be the owner
 * of that chew toy, and thus a `var/obj/item/chew_toy` reference is fine
 * (as long as it is cleaned up properly).
 * However, a chew toy does not own its dog, so a `var/mob/living/dog/owner`
 * might be inferior to a weakref.
 * This is also a good rule of thumb to avoid circular references, such as the
 * chew toy example. A circular reference that doesn't clean itself up properly
 * will always hard delete.
 */
/datum/weakref
	var/reference

/datum/weakref/New(datum/thing)
	reference = REF(thing)

/datum/weakref/Destroy(force)
	var/datum/target = resolve()
	qdel(target)

	if(!force)
		return QDEL_HINT_LETMELIVE //Let BYOND autoGC thiswhen nothing is using it anymore.
	target?.weak_reference = null
	return ..()

/**
 * Retrieves the datum that this weakref is referencing.
 *
 * This will return `null` if the datum was deleted. This MUST be respected.
 */
/datum/weakref/proc/resolve()
	var/datum/D = locate(reference)
	return (!QDELETED(D) && D.weak_reference == src) ? D : null


/datum/weakref/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_WEAKREF_RESOLVE, "Go to reference")

/datum/weakref/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_WEAKREF_RESOLVE])
		if(!check_rights(NONE))
			return
		var/datum/R = resolve()
		if(R)
			usr.client.debug_variables(R)
