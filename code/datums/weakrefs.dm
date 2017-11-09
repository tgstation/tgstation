
//obtain a weak reference to a datum
/proc/weakref(datum/D)
	if(!istype(D))
		return
	if(QDELETED(D))
		return
	if(!D.weakref)
		D.weakref = new/datum/weakref(D)
	return D.weakref

/datum/weakref
	var/ref

/datum/weakref/New(datum/D)
	ref = REF(D)

/datum/weakref/Destroy(force)
	// A weakref datum should not be manually destroyed as it is a shared resource,
	//  rather it should be automatically collected by the BYOND GC when all references are gone.
	return force ? QDEL_HINT_HARDDEL : QDEL_HINT_LETMELIVE

/datum/weakref/proc/resolve()
	var/datum/D = locate(ref)
	if(D && D.weakref == src)
		return D
	return null
