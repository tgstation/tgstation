/**
 * ## Search Object
 * An object for content lists. Compacted item data.
 */
/datum/search_object
	/// Item we're indexing
	var/atom/item
	/// Url to the image of the object
	var/icon
	/// Icon state, for inexpensive icons
	var/icon_state
	/// Name of the original object
	var/name
	/// Typepath of the original object for ui grouping
	var/path
	/// String ref of the parent item. Used to look up this obj in contents
	var/string_ref


/datum/search_object/New(client/owner, atom/item)
	. = ..()

	src.item = item
	name = item.name
	if(isobj(item))
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


/datum/search_object/Destroy(force)
	item = null

	return ..()


/// Generates the icon for the search object. This is the expensive part.
/datum/search_object/proc/generate_icon(client/owner)
	if(ismob(item) || length(item.overlays) > 2)
		icon = costly_icon2html(item, owner, sourceonly = TRUE)
	else // our pre 515.1635 fallback for normal items
		icon = icon2html(item, owner, sourceonly = TRUE)
