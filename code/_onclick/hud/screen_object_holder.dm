/// A helper instance that will handle adding objects from the client's screen
/// to easily remove from later.
/datum/screen_object_holder
	VAR_PRIVATE
		client/client
		list/screen_objects = list()
		list/protected_screen_objects = list()

/datum/screen_object_holder/New(client/client)
	ASSERT(istype(client))

	src.client = client

	RegisterSignal(client, COMSIG_QDELETING, PROC_REF(on_parent_qdel))

/datum/screen_object_holder/Destroy()
	clear()
	client = null

	return ..()

/// Gives the screen object to the client, qdel'ing it when it's cleared
/datum/screen_object_holder/proc/give_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))

	screen_objects += screen_object
	client?.screen += screen_object

/// Gives the screen object to the client, but does not qdel it when it's cleared
/datum/screen_object_holder/proc/give_protected_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))

	protected_screen_objects += screen_object
	client?.screen += screen_object

/datum/screen_object_holder/proc/remove_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))
	ASSERT((screen_object in screen_objects) || (screen_object in protected_screen_objects))

	screen_objects -= screen_object
	protected_screen_objects -= screen_object
	client?.screen -= screen_object

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
