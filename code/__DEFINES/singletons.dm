#define SINGTYPE_ABSTRACT "abstract"
#define SINGTYPE_COMPLEX "complex"

///Find or create an abstract singleton of the desired type.
#define SINGLETON(_datatype) _singleton(_datatype)
///Return a single or null using the given search arguments.
#define FIND_SINGLETON(_datatype, args...) (islist(global.singleton_repo[_datatype]) ? (global.singleton_repo[_datatype][list(##args).Join()]) : (global.singleton_repo[_datatype]))
///Find or create a datum singleton and return its data.
#define SINGLETON_DATUM(_datatype, args...) _singleton_datum(list(##args), _datatype)
///Find or create an abstract complex singleton with the desired args
#define SINGLETON_COMPLEX(_datatype, args...) _complex_singleton(list(##args), _datatype)
///Return null or a singleton with the desired args.
#define FIND_SINGLETON_DATA(_datatype, args...) FIND_SINGLETON(_datatype, ##args)?:data


/////Singleton List macros, replaces many list functions.
///Find or create a list singleton and return it.
#define SINGLETON_LIST(list) _singleton_list(list)

///Change a value by key
#define SINGLETON_LIST_MUTATE(singleton, key, value) \
	do{ \
		var/list/mutation = singleton.Copy(); \
		mutation[key] = value; \
		singleton = _singleton_list(mutation); \
	}while(FALSE)

///Add a value
#define SINGLETON_LIST_ADD(singleton, addition) \
	do{ \
		var/list/mutation = singleton.Copy(); \
		mutation += addition; \
		singleton = _singleton_list(mutation); \
	}while(FALSE)

///Remove a value
#define SINGLETON_LIST_REMOVE(singleton, removal) \
	do{ \
		var/list/mutation = singleton.Copy(); \
		mutation -= removal; \
		singleton = _singleton_list(mutation); \
	}while(FALSE)
