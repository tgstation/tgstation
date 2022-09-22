GLOBAL_REAL(singleton_repo, /list) = list()

///The abstract singleton class
/singleton

/singleton/New(_datatype = ABSTRACT, key)
	if(!global.singleton_repo[_datatype])
		global.singleton_repo[_datatype] = list()

	global.singleton_repo[_datatype][key] = src


///Datum singletons. Use these for if the singleton is holding an existing type, instead of being an abstract type.
/singleton/datum
	///The type of datum this singleton is holding
	VAR_FINAL/datatype
	///The reference to this singleton's data
	VAR_FINAL/dataref

/singleton/datum/New(_datatype, key, list/data_args)
	..(_datatype, key)
	datatype = _datatype
	dataref = new datatype(arglist(data_args))

///Find or create a singleton, DO NOT USE. Use the SINGLETON() macro.
/proc/_singleton_datum(datatype, list/data_args)
	if(!datatype)
		CRASH("Tried to create or fetch a singleton without specifying a datatype")
	if(!ispath(datatype))
		CRASH("Tried to create or fetch a singleton with a non-path datatype")
	if(ispath(datatype, /atom))
		CRASH("Tried to create or fetch a a singleton with a non-abstract datatype")
	if(ispath(datatype, /list))
		CRASH("Use SINGLETON_LIST()!")

	if(!length(data_args))
		CRASH("Tried to create or fetch a singleton with no arguments!")

	var/key = data_args.Join()
	var/singleton/datum/singleton = FIND_SINGLETON(datatype, key)
	singleton ||= new(datatype, key, data_args)
	return singleton.dataref

///Singleton lists. When these are mutated, it instead creates a new list based on the mutation and returns it, leaving the original untouched.
/singleton/list
	///The actual list
	VAR_PRIVATE/list/data

/singleton/list/New(key, _data)
	..(/list, key)
	data = _data

/singleton/list/proc/get()
	return data.Copy()

/singleton/list/proc/Copy()
	return get()

/singleton/list/proc/operator[](value)
	return data[value]

/singleton/list/proc/operator[]=(key, value)
	CRASH("Unsupported operation! Use SINGLETON_LIST_MUTATE()!")

/singleton/list/proc/operator|(list/value)
	return _singleton_list(data.Copy()|value).get()

/singleton/list/proc/operator&(list/value)
	return _singleton_list(data.Copy()&value).get()

/proc/_singleton_list(list/data)
	RETURN_TYPE(/singleton/list)
	var/key = data.Join()
	var/singleton/list/singleton = FIND_SINGLETON(/list, key)
	singleton ||= new /singleton/list(key, data)
	return singleton

/proc/test_singleton_list(list/to_add = list("Hello", "World"))
	var/singleton/list/mylist = SINGLETON_LIST(to_add)
	to_chat(world, mylist.type)
	to_chat(world, english_list(mylist.get()))
