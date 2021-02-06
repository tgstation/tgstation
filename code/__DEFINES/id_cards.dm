// The order in which this lists are defined matters. When attempting to add a wildcard access to a card,
// the code will iterate over the list and stop at the first wildcard flag that can hold the access.
// The lower level the access, the earlier in the list it should be so that low level wildcards get
// subtracted from the lowest wildcard flag that is able to take them.
// A value of -1 means infinite slots. The system is designed to reject a wildcard when the slot counts
// explicitly equal 0 for all compatible wildcard slots.

#define WILDCARD_LIMIT_GREY list(WILDCARD_NAME_COMMON = 2)
#define WILDCARD_LIMIT_SILVER list(WILDCARD_NAME_COMMON = 5, WILDCARD_NAME_COMMAND = 1, WILDCARD_NAME_PRV_COMMAND = 1)
#define WILDCARD_LIMIT_GOLD list(WILDCARD_NAME_CAPTAIN = -1)
#define WILDCARD_LIMIT_SYNDICATE list(WILDCARD_NAME_SYNDICATE = -1)
#define WILDCARD_LIMIT_DEATHSQUAD list(WILDCARD_NAME_CENTCOM = -1)
#define WILDCARD_LIMIT_CENTCOM list(WILDCARD_NAME_CENTCOM = -1)
#define WILDCARD_LIMIT_PRISONER list()
#define WILDCARD_LIMIT_CHAMELEON list(WILDCARD_NAME_COMMON = 3, WILDCARD_NAME_COMMAND = 1, WILDCARD_NAME_CAPTAIN = 1)
#define WILDCARD_LIMIT_ADMIN list(WILDCARD_NAME_ALL = -1)
