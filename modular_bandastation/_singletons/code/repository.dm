/repository/New()
	return

/*
/datum/cache_entry
	var/timestamp
	var/data

/datum/cache_entry/New()
	timestamp = world.time

/datum/cache_entry/proc/is_valid()
	return FALSE

/datum/cache_entry/valid_until/New(valid_duration)
	..()
	timestamp += valid_duration

/datum/cache_entry/valid_until/is_valid()
	return world.time < timestamp
*/


GLOBAL_DATUM_INIT(Singletons, /repository/singletons, new)

/repository/singletons
	/// A cache of individual singletons as (/singleton/path = Instance, ...)
	var/list/instances = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for instances.
	var/list/resolved_instances = list()

	/// A cache of singleton types according to a parent type as (/singleton/path = list(/singleton/path = Instance, /singleton/path/foo = Instance, ...))
	var/list/type_maps = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for type_maps.
	var/list/resolved_type_maps = list()

	/// A cache of singleton subtypes according to a parent type as (/singleton/path = list(/singleton/path/foo = Instance, ...))
	var/list/subtype_maps = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for subtype_maps.
	var/list/resolved_subtype_maps = list()

	/// A cache of singleton types according to a parent type as (/singleton/path = list(Parent Instance, Subtype Instance, ...))
	var/list/type_lists = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for type_lists.
	var/list/resolved_type_lists = list()

	/// A cache of singleton subtypes according to a parent type as (/singleton/path = list(Subtype Instance, Subtype Instance, ...))
	var/list/subtype_lists = list()

	/// A map of (/singleton/path = TRUE, ...). Indicates whether a path has been tried for subtype_lists.
	var/list/resolved_subtype_lists = list()


/**
* Get a singleton instance according to path. Creates it if necessary. Null if abstract or not a singleton.
* Prefer the GET_SINGLETON macro to minimize proc calls.
*/
/repository/singletons/proc/GetInstance(datum/singleton/path)
	if(!ispath(path, /datum/singleton))
		return
	if(resolved_instances[path])
		return instances[path]
	resolved_instances[path] = TRUE
	if(path == initial(path.abstract_type))
		return
	var/datum/singleton/result = new path
	instances[path] = result
	result.Initialize()
	return result


/// Get a (path = instance) map of valid singletons according to paths.
/repository/singletons/proc/GetMap(list/datum/singleton/paths)
	var/list/result = list()
	for(var/path in paths)
		var/datum/singleton/instance = GetInstance(path)
		if (!instance)
			continue
		result[path] = instance
	return result


/// Get a list of valid singletons according to paths.
/repository/singletons/proc/GetList(list/datum/singleton/paths)
	var/list/result = list()
	for(var/path in paths)
		var/datum/singleton/instance = GetInstance(path)
		if(!instance)
			continue
		result += instance
	return result


/**
* Get a (path = instance) map of valid singletons according to typesof(path).
* Prefer the GET_SINGLETON_TYPE_MAP macro to minimize proc calls.
*/
/repository/singletons/proc/GetTypeMap(datum/singleton/path)
	if(resolved_type_maps[path])
		return type_maps[path] || list()
	resolved_type_maps[path] = TRUE
	var/result = GetMap(typesof(path))
	type_maps[path] = result
	return result


/**
* Get a (path = instance) map of valid singletons according to subtypesof(path).
* Prefer the GET_SINGLETON_TYPE_MAP macro to minimize proc calls.
*/
/repository/singletons/proc/GetSubtypeMap(datum/singleton/path)
	if(resolved_subtype_maps[path])
		return subtype_maps[path] || list()
	resolved_subtype_maps[path] = TRUE
	var/result = GetMap(subtypesof(path))
	subtype_maps[path] = result
	return result


/**
* Get a list of valid singletons according to typesof(path).
* Prefer the GET_SINGLETON_TYPE_LIST macro to minimize proc calls.
*/
/repository/singletons/proc/GetTypeList(datum/singleton/path)
	if(resolved_type_lists[path])
		return type_lists[path] || list()
	resolved_type_lists[path] = TRUE
	var/result = GetList(typesof(path))
	type_lists[path] = result
	return result


/**
* Get a list of valid singletons according to subtypesof(path).
* Prefer the GET_SINGLETON_SUBTYPE_LIST macro to minimize proc calls.
*/
/repository/singletons/proc/GetSubtypeList(datum/singleton/path)
	if(resolved_subtype_lists[path])
		return subtype_lists[path] || list()
	resolved_subtype_lists[path] = TRUE
	var/result = GetList(subtypesof(path))
	subtype_lists[path] = result
	return result
