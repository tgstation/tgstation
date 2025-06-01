/// A helper instance that will handle adding objects from the client's screen
/// to easily remove from later.
/datum/screen_object_holder
	///The lowest point this can scroll to. 0 disables scrolling.
	var/lowest_point
	VAR_PRIVATE
		///Used for menus with a scrollwheel, this is how much we've scrolled.
		amount_scrolled = 0
		client/client
		list/screen_objects = list()
		list/protected_screen_objects = list()

/datum/screen_object_holder/New(client/client)
	ASSERT(istype(client))

	src.client = client

	RegisterSignal(client, COMSIG_QDELETING, PROC_REF(on_parent_qdel))
	RegisterSignal(client.mob, COMSIG_MOUSE_SCROLL_ON, PROC_REF(on_mouse_wheel))

/datum/screen_object_holder/Destroy()
	clear()
	client = null

	return ..()

/// Gives the screen object to the client, qdel'ing it when it's cleared
/datum/screen_object_holder/proc/give_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))

	screen_objects += screen_object
	client?.screen += screen_object
	return screen_object

/// Gives the screen object to the client, but does not qdel it when it's cleared,
/// this is used for screen object instances you plan on giving to multiple mobs.
/datum/screen_object_holder/proc/give_protected_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))

	protected_screen_objects += screen_object
	client?.screen += screen_object
	return screen_object

/datum/screen_object_holder/proc/remove_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))
	ASSERT((screen_object in screen_objects) || (screen_object in protected_screen_objects))

	client?.screen -= screen_object
	screen_objects -= screen_object
	//protected objects don't get qdel'ed
	if(screen_object in protected_screen_objects)
		protected_screen_objects -= screen_object
	else
		qdel(screen_object)

/datum/screen_object_holder/proc/clear()
	client?.screen -= screen_objects
	client?.screen -= protected_screen_objects

	QDEL_LIST(screen_objects)
	protected_screen_objects.Cut()

// We don't qdel here, as clients leaving should not be a concern for consumers
// Consumers ought to be qdel'ing this on their own Destroy, but we shouldn't
// hard del because they aren't watching for the client, that's our job.
/datum/screen_object_holder/proc/on_parent_qdel()
	PRIVATE_PROC(TRUE)
	SIGNAL_HANDLER

	clear()
	client = null

/datum/screen_object_holder/proc/on_mouse_wheel(mob/source_mob, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	if(!lowest_point)
		return

	if(delta_y < 0)
		scroll(up = FALSE)
	else if(delta_y > 0)
		scroll(up = TRUE)

/datum/screen_object_holder/proc/scroll(up = FALSE)
	if(up)
		//going up at highest point.
		if(amount_scrolled == 0)
			return
		for(var/atom/movable/screen/escape_menu/text/screen_atom in screen_objects + protected_screen_objects)
			screen_atom.scroll_up()
		amount_scrolled += 120
		return
	//scrolling down to rock bottom, plus three scrolls up so they don't just get rid of the UI
	else if(amount_scrolled < (lowest_point + 360))
		return
	for(var/atom/movable/screen/escape_menu/text/screen_atom in screen_objects + protected_screen_objects)
		screen_atom.scroll_down()
	amount_scrolled -= 120
