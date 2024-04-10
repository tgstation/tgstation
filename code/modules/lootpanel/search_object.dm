/**
 * ## Search Object
 * An object for content lists. Compacted item data.
 */
/datum/search_object
	/// Client attached to the search_object
	var/datum/weakref/client_ref
	/// Weakref to the original object
	var/datum/weakref/item_ref
	/// Url to the image of the object
	var/icon
	/// Icon state, for inexpensive icons
	var/icon_state
	/// The name of the object
	var/name
	/// The typepath, used for concatenating the search results
	var/path
	/// The STRING reference of the object for indexing purposes
	var/string_ref


/datum/search_object/New(mob/user, atom/item)
	. = ..()

	client_ref = WEAKREF(user.client)
	item_ref = WEAKREF(item)
	name = item.name
	path = isobj(item) && item.type
	string_ref = REF(item)

	if(!ismob(item) && length(item.overlays) < 3)
		icon = item.icon
		icon_state = item.icon_state


/// Generates the icon for the search object. This is the expensive part.
/datum/search_object/proc/generate_icon()
	if(icon && icon_state)
		return TRUE

	var/atom/item = item_ref?.resolve()
	if(isnull(item))
		qdel(src)

	var/client/user_client = client_ref?.resolve()
	if(isnull(user_client))
		qdel(src)

	icon = costly_icon2html(item, user_client, sourceonly = TRUE)
	
	return !!icon
