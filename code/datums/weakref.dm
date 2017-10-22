/datum
	var/weakref/weakref

/datum/Destroy()
	weakref = null // Clear this reference to ensure it's kept for as brief duration as possible.
	. = ..()

//obtain a weak reference to a datum
/proc/weakref(datum/D)
	if(!istype(D))
		return
	if(QDELETED(D))
		return
	if(!D.weakref)
		D.weakref = new/weakref(D)
	return D.weakref

/weakref
	var/ref

/weakref/New(datum/D)
	ref = "\ref[D]"

/weakref/Destroy()
	// A weakref datum should not be manually destroyed as it is a shared resource,
	//  rather it should be automatically collected by the BYOND GC when all references are gone.
	return QDEL_HINT_LETMELIVE

/weakref/proc/resolve()
	var/datum/D = locate(ref)
	if(D && D.weakref == src)
		return D
	return null