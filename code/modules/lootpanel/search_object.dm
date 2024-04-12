/**
 * ## Search Object
 * An object for content lists. Compacted item data.
 */
/datum/search_object
	/// Weakref to the client
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


/datum/search_object/New(client/owner, atom/item)
	. = ..()

	client_ref = WEAKREF(owner)
	item_ref = WEAKREF(item)
	name = item.name
	if(isobj(item)) // Grouping in the ui is for objects only
		path = item.type
	string_ref = REF(item)

	// Icon generation conditions //////////////	
	// Condition 1: Icon is complex
	if(ismob(item) || length(item.overlays) > 2)
		return

	// Condition 2: Can't get icon path
	if(!isfile(item.icon) || !length("[item.icon]"))
		return

	// Condition 3: Using opendream
#ifdef OPENDREAM
	return
#endif

	// Condition 4: Using older byond version
	var/build = owner.byond_build
	var/version = owner.byond_version
	if(build < 515 || (build == 515 && version < 1635))
		return

	icon = "[item.icon]"
	icon_state = item.icon_state


/// Generates the icon for the search object. This is the expensive part.
/datum/search_object/proc/generate_icon()
	var/atom/item = item_ref?.resolve()
	if(QDELETED(item))
		return FALSE

	var/client/owner = client_ref?.resolve()
	if(isnull(owner))
		return FALSE

	if(ismob(item) || length(item.overlays) > 2)
		icon = costly_icon2html(item, owner, sourceonly = TRUE)
	else // our pre 515.1635 fallback for normal items
		icon = icon2html(item, owner, sourceonly = TRUE)

	return TRUE
