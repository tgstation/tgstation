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

