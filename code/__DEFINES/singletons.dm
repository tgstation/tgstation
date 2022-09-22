///Find or create a datum singleton and return its data.
#define SINGLETON_DATUM(_datatype, args...) _singleton_datum(_datatype, list(##args))

///Return null or a singleton with the desired args
#define FIND_SINGLETON(_datatype, args...) global.singleton_repo[_datatype]?[list(##args).Join()]

///Return null or a singleton's data with the desired args
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
