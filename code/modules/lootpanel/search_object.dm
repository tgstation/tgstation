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


/datum/search_object/New(client/owner, atom/item)
	. = ..()

	src.item = item
	name = item.name
	if(isobj(item))
		path = item.type

	if(isturf(item))
		RegisterSignal(item, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	else
		// Lest we find ourselves here again, this is intentionally stupid.
		// It tracks items going out and user actions, otherwise they can refresh the lootpanel.
		// If this is to be made to track everything, we'll need to make a new signal to specifically create/delete a search object
		RegisterSignals(item, list(
			COMSIG_ITEM_PICKUP,
			COMSIG_MOVABLE_MOVED,
			COMSIG_QDELETING,
			), PROC_REF(on_item_moved))

	// Icon generation conditions //////////////
	// Condition 1: Icon is complex
	if(ismob(item) || length(item.overlays) > 2)
		return

	// Condition 2: Can't get icon path
	if(!isfile(item.icon) || !length("[item.icon]"))
		return

	// Condition 3: Using opendream
#if defined(OPENDREAM) || defined(UNIT_TESTS)
	return
#endif

	// Condition 4: Using older byond version
	var/build = owner.byond_build
	var/version = owner.byond_version
	if(build < 515 || (build == 515 && version < 1635))
		icon = "n/a"
		return

	icon = "[item.icon]"
	icon_state = item.icon_state


/datum/search_object/Destroy(force)
	item = null
	icon = null

	return ..()


/// Generates the icon for the search object. This is the expensive part.
/datum/search_object/proc/generate_icon(client/owner)
	icon = costly_icon2html(item, owner, sourceonly = TRUE)


/// Parent item has been altered, search object no longer valid
/datum/search_object/proc/on_item_moved(atom/source)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return

	qdel(src)


/// Parent tile has been altered, entire search needs reset
/datum/search_object/proc/on_turf_change(turf/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src)
