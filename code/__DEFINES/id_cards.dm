// The order in which this lists are defined matters. When attempting to add a wildcard access to a card,
// the code will iterate over the list and stop at the first wildcard flag that can hold the access.
// The lower level the access, the earlier in the list it should be so that low level wildcards get
// subtracted from the lowest wildcard flag that is able to take them.
// A limit of -1 means infinite slots. The system is designed to reject a wildcard when the slot limit
// explicitly equal 0 for all compatible wildcard slots. Negative numbers are infinite slots tending away
// from 0, while positive numbers are limited slots that tend towards 0.

#define WILDCARD_LIMIT_GREY list(WILDCARD_NAME_COMMON = list(limit = 2, usage = list()))
#define WILDCARD_LIMIT_SILVER list( \
	WILDCARD_NAME_COMMON = list(limit = 3, usage = list()), \
	WILDCARD_NAME_COMMAND = list(limit = 1, usage = list()), \
	WILDCARD_NAME_PRV_COMMAND = list(limit = 1, usage = list()) \
)
#define WILDCARD_LIMIT_GOLD list(WILDCARD_NAME_CAPTAIN = list(limit = -1, usage = list()))
#define WILDCARD_LIMIT_SYNDICATE list(WILDCARD_NAME_SYNDICATE = list(limit = -1, usage = list()))
#define WILDCARD_LIMIT_DEATHSQUAD list(WILDCARD_NAME_CENTCOM = list(limit = -1, usage = list()))
#define WILDCARD_LIMIT_CENTCOM list(WILDCARD_NAME_CENTCOM = list(limit = -1, usage = list()))
#define WILDCARD_LIMIT_PRISONER list()
#define WILDCARD_LIMIT_CHAMELEON list( \
	WILDCARD_NAME_COMMON = list(limit = 3, usage = list()), \
	WILDCARD_NAME_COMMAND = list(limit = 1, usage = list()), \
	WILDCARD_NAME_CAPTAIN = list(limit = 1, usage = list()) \
)
#define WILDCARD_LIMIT_ADMIN list(WILDCARD_NAME_ALL = list(limit = -1, usage = list()))
