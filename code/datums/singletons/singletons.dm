GLOBAL_REAL(singleton_repo, /list) = list()

///The abstract singleton class
/singleton

/singleton/New()
	global.singleton_repo[type] = src

/singleton/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("Something tried to delete a singleton")
	return QDEL_HINT_LETMELIVE

/proc/_singleton(datatype)
	var/singleton/singleton = FIND_SINGLETON(datatype)
	singleton ||= new datatype()
	return singleton

///Complex singletons can be given arguments, and are stored by a key based on their arguments.
/singleton/complex

/singleton/complex/New(...)
	if(!global.singleton_repo[type])
		global.singleton_repo[type] = list()

	global.singleton_repo[type][args.Join()] = src

/proc/_complex_singleton(list/data_args, datatype)
	var/key = data_args.Join()
	var/singleton/complex/singleton = FIND_SINGLETON(datatype, key)
	singleton ||= new datatype(arglist(data_args))
	return singleton

///Datum singletons. Use these for if the singleton is holding an existing type, instead of being an abstract type.
/singleton/datum
	///The type of datum this singleton is holding
	VAR_FINAL/datatype
	///The reference to this singleton's data
	VAR_FINAL/dataref

/singleton/datum/New(key, _datatype, list/data_args)
	if(!global.singleton_repo[_datatype])
		global.singleton_repo[_datatype] = list()

	global.singleton_repo[_datatype][key] = src
	datatype = _datatype
	dataref = new datatype(arglist(data_args))

///Find or create a singleton, DO NOT USE. Use the SINGLETON() macro.
/proc/_singleton_datum(list/data_args, datatype)
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
	singleton ||= new(key, datatype, data_args)
	return singleton.dataref

