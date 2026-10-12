/// Checks if potential_autoref is a autoref of thing.
#define IS_AUTOREF_OF(thing, potential_autoref) (isdatum(thing) && !isnull(potential_autoref) && thing.auto_reference == potential_autoref)

//For these two procs refs MUST be ref = TRUE format like typecaches!
/proc/autoref_filter_list(list/things, list/refs)
	if(!islist(things) || !islist(refs))
		return
	if(!refs.len)
		return things
	if(things.len > refs.len)
		var/list/f = list()
		for(var/i in refs)
			var/datum/autoref/r = i
			var/datum/d = r.resolve()
			if(d)
				f |= d
		return things & f

	else
		. = list()
		for(var/i in things)
			if(!refs[AUTOREF(i)])
				continue
			. |= i

/proc/autoref_filter_list_reverse(list/things, list/refs)
	if(!islist(things) || !islist(refs))
		return
	if(!refs.len)
		return things
	if(things.len > refs.len)
		var/list/f = list()
		for(var/i in refs)
			var/datum/autoref/r = i
			var/datum/d = r.resolve()
			if(d)
				f |= d

		return things - f
	else
		. = list()
		for(var/i in things)
			if(refs[AUTOREF(i)])
				continue
			. |= i
