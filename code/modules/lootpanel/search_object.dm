/**
 * ## Search Object
 * An object for content lists. Compacted item data.
 */
/datum/search_object
	/// A string representation of the object's icon
	var/icon
	/// The name of the object
	var/name
	/// The STRING reference of the object for indexing purposes
	var/ref
	/// Weakref to the original object
	var/datum/weakref/item_ref


/datum/search_object/New(mob/user, atom/item)
	. = ..()

	name = item.name
	ref = REF(item)
	item_ref = WEAKREF(item)

	if(ismob(item) || length(item.overlays) > 2)
		icon = costly_icon2html(item, user.client, sourceonly = TRUE)
	else
		icon = icon2html(item, user.client, sourceonly = TRUE)


/datum/search_object/Destroy(force)
	icon = null
	name = null
	ref = null

	return ..()
