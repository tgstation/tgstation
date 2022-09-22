/proc/_singleton_list(list/data)
	RETURN_TYPE(/singleton/slist)
	var/key = data.Join()
	var/singleton/slist/singleton = FIND_SINGLETON(/list, key)
	singleton ||= new /singleton/slist(key, data)
	return singleton

/// ///Singleton lists. When these are mutated, it instead creates a new list based on the mutation and returns it, leaving the original untouched.
//Having "/list" in the typepath causes weird behavior.
/singleton/slist
	///The actual list
	VAR_PRIVATE/list/data

/singleton/slist/New(key, _data)
	..(/list, key)
	data = _data

/singleton/slist/proc/get()
	return data.Copy()

/singleton/slist/proc/Copy()
	return get()

/singleton/slist/proc/operator[](value)
	return data[value]

/singleton/slist/proc/operator[]=(key, value)
	CRASH("Unsupported operation! Use SINGLETON_LIST_MUTATE()!")

/singleton/slist/proc/operator|(list/value)
	return _singleton_list(data.Copy()|value).get()

/singleton/slist/proc/operator&(list/value)
	return _singleton_list(data.Copy()&value).get()


