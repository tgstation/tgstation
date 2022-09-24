GLOBAL_LIST_INIT(immutable_list_repo, list())

/datum/immutable_list
	VAR_PRIVATE/list/data

/datum/immutable_list/New(list/data)
	src.data = data

///Constructor for immutable lists. Returns an ilist with the desired arguments.
/proc/immutable_list(list/data)
	var/static/datum/immutable_list/holder = new
	return holder.newme(data)

///Constructor for immutable associative lists. Returns an associative ilist with the desired arguments.
/proc/immutable_assoc_list(list/data)
	var/static/datum/immutable_list/assoc/holder = new
	return holder.newme(data)

///Constructor for immutable lists containing ONLY strings, skips the expensive \ref bits. Returns a string ilist with the desired arguments.
/proc/immutable_string_list(list/data)
	var/static/datum/immutable_list/string/holder = new
	return holder.newme(data)

/////////////////////////////////////////////////CLASS PROCS////////////////////////////////////////////////////////////

///The actual constructor. Why is it like this? We can't hijack the return value of New(), so this is the best I could think of.
/datum/immutable_list/proc/newme(list/immutize)
	var/list/refs = list()
	for(var/argument in immutize)
		#ifdef UNIT_TESTS
		if(isdatum(argument) && !isweakref(argument))
			stack_trace("Sent a hardref of [argument:type] to an immutable list, this will cause a harddel if the referenced object is deleted!")
		#endif
		refs += ref(argument) //Ignore datum tags, we don't care.

	var/key = refs.Join("-")
	. = GLOB.immutable_list_repo[key]
	if(!.)
		. = new /datum/immutable_list(immutize)
		GLOB.immutable_list_repo[key] = .
	return .

/datum/immutable_list/assoc/newme(list/immutize)
	var/list/refs = list()
	for(var/key in immutize)
		refs += "\ref[(key)]=\ref[immutize[key]]"
		#ifdef UNIT_TESTS
		if((isdatum(key) && !isweakref(key)))
			stack_trace("Sent a hardref of [key:type] to an immutable list, this will cause a harddel if the referenced object is deleted!")
		else if(isdatum(immutize[key]) && !isweakref(immutize[key]))
			stack_trace("Sent a hardref of [immutize[key]:type] to an immutable list, this will cause a harddel if the referenced object is deleted!")
		#endif

	var/key = refs.Join()
	. = GLOB.immutable_list_repo[key]
	if(!.)
		. = new /datum/immutable_list/assoc(immutize)
		GLOB.immutable_list_repo[key] = .
	return .

/datum/immutable_list/string/newme(list/immutize)
	#ifdef UNIT_TESTS
	for(var/element in immutize)
		if(isnull(element))
			stack_trace("Null found in immutable string list, full list: [json_encode(immutize)]")
		if(!istext(element))
			stack_trace("Non-string found in immutable string list! [element]")
	#endif

	var/key = immutize.Join()
	. = GLOB.immutable_list_repo[key]
	if(!.)
		. = new /datum/immutable_list/string(immutize)
		GLOB.immutable_list_repo[key] = .
	return .

///Access an element from data.
/datum/immutable_list/proc/Index(key)
	return data[key]

///Return the contained list.
/datum/immutable_list/proc/Get()
	return data.Copy()

///Return the length of the contained list
/datum/immutable_list/proc/Length()
	return length(data)

///Find and return a needle
/datum/immutable_list/proc/Locate(needle)
	return (needle in data)

///Return the position of a needle in the list
/datum/immutable_list/proc/Find(needle, start, end)
	return data.Find(needle, start, end)

///Set data[key] equal to [value]
/datum/immutable_list/proc/Set(key, value)
	. = data.Copy()
	.[key] = value
	return newme(.)

///Add any number of items to data
/datum/immutable_list/proc/Add(...)
	. = data.Copy()
	for(var/argument in args)
		. += argument
	return newme(.)

///Remove any number of items from data
/datum/immutable_list/proc/Remove(...)
	. = data.Copy()
	for(var/argument in args)
		. -= argument
	return newme(.)

///Functional equivalent of [list_A | list_B]
/datum/immutable_list/proc/Or(list/other)
	. = data.Copy() | other
	return newme(.)

///Functional equivalent of [list_A & list_B]
/datum/immutable_list/proc/And(list/other)
	. = data.Copy() & other
	return newme(.)

///Functional equivlanet of [list_A ^ list_B]
/datum/immutable_list/proc/Xor(list/other)
	. = data.Copy() ^ other
	return newme(.)

/datum/immutable_list/proc/operator[]()
	CRASH("You're attempting to index vars[], use Index() to index the list!")
