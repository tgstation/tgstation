/*
* Performance behaviors for avoiding calling procs unecessarily on the Singletons global.
*/

/// Get a singleton instance according to path P. Creates it if necessary. Null if abstract or not a singleton.
#define GET_SINGLETON(P)\
	(ispath(P, /datum/singleton) ? (GLOB.Singletons.resolved_instances[P] ? GLOB.Singletons.instances[P] : GLOB.Singletons.GetInstance(P)) : null)

/// Get a (path = instance) map of valid singletons according to typesof(P).
#define GET_SINGLETON_TYPE_MAP(P)\
	(ispath(P, /datum/singleton) ? (GLOB.Singletons.resolved_type_maps[P] ? GLOB.Singletons.type_maps[P] : GLOB.Singletons.GetTypeMap(P)) : list())

/// Get a (path = instance) map of valid singletons according to subtypesof(P).
#define GET_SINGLETON_SUBTYPE_MAP(P)\
	(ispath(P, /datum/singleton) ? (GLOB.Singletons.resolved_subtype_maps[P] ? GLOB.Singletons.subtype_maps[P] : GLOB.Singletons.GetSubtypeMap(P)) : list())

/// Get a list of valid singletons according to typesof(path).
#define GET_SINGLETON_TYPE_LIST(P)\
	(ispath(P, /datum/singleton) ? (GLOB.Singletons.resolved_type_lists[P] ? GLOB.Singletons.type_lists[P] : GLOB.Singletons.GetTypeList(P)) : list())

/// Get a list of valid singletons according to subtypesof(path).
#define GET_SINGLETON_SUBTYPE_LIST(P)\
	(ispath(P, /datum/singleton) ? (GLOB.Singletons.resolved_subtype_lists[P] ? GLOB.Singletons.subtype_lists[P] : GLOB.Singletons.GetSubtypeList(P)) : list())
