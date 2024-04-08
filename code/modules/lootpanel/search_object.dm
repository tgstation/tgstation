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
	var/string_ref
	/// Client attached to the search_object
	var/datum/weakref/client_ref
	/// Weakref to the original object
	var/datum/weakref/item_ref


/datum/search_object/New(mob/user, atom/item)
	. = ..()

	client_ref = WEAKREF(user.client)
	item_ref = WEAKREF(item)
	name = item.name
	string_ref = REF(item)


/// Generates the icon for the search object. This is the expensive part.
/datum/search_object/proc/generate_icon()
	var/atom/item = item_ref?.resolve()
	if(isnull(item))
		qdel(src)

	var/client/user_client = client_ref?.resolve()
	if(isnull(user_client))
		qdel(src)

	if(ismob(item) || length(item.overlays) > 2)
		icon = costly_icon2html(item, user_client, sourceonly = TRUE)
	else
		icon = icon2html(item, user_client, sourceonly = TRUE)

	if(icon)
		return TRUE
