///Real globals have no datum access overhead, so we do both to maintain GLOB having all the important bits.
GLOBAL_REAL(_immutable_list_repo, /list) = list()
GLOBAL_LIST_INIT(immutable_list_repo, global._immutable_list_repo)

/datum/immutable_list
	VAR_FINAL/list/data

/datum/immutable_list/New(list/_data)
	data = _data

///Constructor for immutable lists, use the macro IMMUTABLE_LIST().
/proc/__immutable_list(list/data)
	var/list/refs = list()
	for(var/argument in data)
		refs += ref(argument) //Ignore datum tags, we don't care.

	. = global._immutable_list_repo[refs.Join()]
	. ||= new /datum/immutable_list(data)
	return .

///Constructor for immutable associative lists, use the macro IMMUTABLE_ASSOC_LIST()
/proc/__immutable_assoc_list(list/data)
	var/list/refs = list()
	for(var/key in data)
		refs += ref(key)
		refs += "PAIR" // This is required, otherwise list("Foo", "Bar")` would be keyed the same as `list("Foo" = "Bar")
		refs += ref(data[key])

	. = global._immutable_list_repo[refs.Join()]
	. ||= new /datum/immutable_list(data)
	return .

///Constructor for immutable lists containing ONLY strings, skips the expensive \ref bits. Use IMMUTABLE_STRING_LIST().
/proc/__immutable_string_list(list/data)
	. = global._immutable_list_repo[data.Join()]
	. ||= new /datum/immutable_list/string(data)
	return .

///Directly access a data member from data. []= is a different operator, and will throw a compile error if someone tries to use it.
/datum/immutable_list/proc/operator[](key)
	return data[key]

///Return the contained list.
/datum/immutable_list/proc/Get()
	return data.Copy()

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
	return __immutable_list(.)

///Add any number of items to data
/datum/immutable_list/proc/Add(...)
	. = data.Copy()
	for(var/argument in args)
		. += argument
	return __immutable_list(.)

///Remove any number of items from data
/datum/immutable_list/proc/Remove(...)
	. = data.Copy()
	for(var/argument in args)
		. -= argument
	return __immutable_list(.)

///Functional equivalent of [list_A | list_B]
/datum/immutable_list/proc/Or(list/other)
	. = data.Copy() | other
	return __immutable_list(.)

///Functional equivalent of [list_A & list_B]
/datum/immutable_list/proc/And(list/other)
	. = data.Copy() & other
	return __immutable_list(.)

///Functional equivlanet of [list_A ^ list_B]
/datum/immutable_list/proc/Xor(list/other)
	. = data.Copy() ^ other
	return __immutable_list(.)


///Set data[key] equal to [value]
/datum/immutable_list/proc/string/Set(key, value)
	. = data.Copy()
	.[key] = value
	return __immutable_string_list(.)

///Add any number of items to data
/datum/immutable_list/string/proc/Add(...)
	. = data.Copy()
	for(var/argument in args)
		. += argument
	return __immutable_string_list(.)

///Remove any number of items from data
/datum/immutable_list/string/proc/Remove(...)
	. = data.Copy()
	for(var/argument in args)
		. -= argument
	return __immutable_string_list(.)

///Functional equivalent of [list_A | list_B]
/datum/immutable_list/string/proc/Or(list/other)
	. = data.Copy() | other
	return __immutable_string_list(.)

///Functional equivalent of [list_A & list_B]
/datum/immutable_list/string/proc/And(list/other)
	. = data.Copy() & other
	return __immutable_string_list(.)

///Functional equivlanet of [list_A ^ list_B]
/datum/immutable_list/string/proc/Xor(list/other)
	. = data.Copy() ^ other
	return __immutable_string_list(.)
