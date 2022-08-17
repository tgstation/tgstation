/// Checks if potential_weakref is a weakref of thing.
#define IS_WEAKREF_OF(thing, potential_weakref) (istype(thing, /datum) && !isnull(potential_weakref) && thing.weak_reference == potential_weakref)

//For these two procs refs MUST be ref = TRUE format like typecaches!
/proc/weakref_filter_list(list/things, list/refs)
	if(!islist(things) || !islist(refs))
		return
	if(!refs.len)
		return things
	if(things.len > refs.len)
		var/list/f = list()
		for(var/i in refs)
			var/datum/weakref/r = i
			var/datum/d = r.resolve()
			if(d)
				f |= d
		return things & f

	else
		. = list()
		for(var/i in things)
			if(!refs[WEAKREF(i)])
				continue
			. |= i

/proc/weakref_filter_list_reverse(list/things, list/refs)
	if(!islist(things) || !islist(refs))
		return
	if(!refs.len)
		return things
	if(things.len > refs.len)
		var/list/f = list()
		for(var/i in refs)
			var/datum/weakref/r = i
			var/datum/d = r.resolve()
			if(d)
				f |= d

		return things - f
	else
		. = list()
		for(var/i in things)
			if(refs[WEAKREF(i)])
				continue
			. |= i

/// sometimes delightfully (and painfully) modular systems pass in arguments that can be what we're looking for
/// ...or a weakref of what we're looking for. This helper will resolve a weakref if need be.
/// returns the instance, unless it was a weakref AND resolved to null... in which case it returns said null.
/proc/resolve_if_weakref(datum/weakref/weakref_or_not)
	if(!isweakref(weakref_or_not))
		return weakref_or_not
	return weakref_or_not.resolve()
