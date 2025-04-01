/**
 * The order in which these lists are defined matters. When attempting to add a wildcard access to a card
 * and not specifying an explicit wildcard slot in which to include it, the code will iterate over the list
 * and stop at the first wildcard flag that can hold the access.
 *
 * The lower level the access, the earlier in the list it should be so that low level wildcards get
 * added to the lowest wildcard flag that can take them.

 * A limit of -1 means infinite slots. The system is designed to reject a wildcard when the slot limit
 * explicitly equal 0 for all compatible wildcard slots.
 */

/// Wildcard slot define for basic grey cards. Only hold 4 common wildcards.
#define WILDCARD_LIMIT_GREY list(WILDCARD_NAME_COMMON = list(limit = 4, usage = list()))
/// Wildcard slot define for Head of Staff silver cards. Can hold 6 common, 2 command and 1 private command.
#define WILDCARD_LIMIT_SILVER list( \
	WILDCARD_NAME_COMMON = list(limit = 6, usage = list()), \
	WILDCARD_NAME_COMMAND = list(limit = 2, usage = list()), \
	WILDCARD_NAME_PRV_COMMAND = list(limit = 1, usage = list()) \
)
/// The Platinum card, an in between of silver and gold, which can have infinite common but is still limited in command
#define WILDCARD_LIMIT_PLATINUM list( \
	WILDCARD_NAME_COMMON = list(limit = -1, usage = list()), \
	WILDCARD_NAME_COMMAND = list(limit = 2, usage = list()), \
	WILDCARD_NAME_PRV_COMMAND = list(limit = 1, usage = list()) \
)
/// Wildcard slot define for Captain gold cards. Can hold infinite of any Captain level wildcard.
#define WILDCARD_LIMIT_GOLD list(WILDCARD_NAME_CAPTAIN = list(limit = -1, usage = list()))
/// Wildcard slot define for select Syndicate-affiliated cards. Can hold infinite of any Syndicate level wildcard. Syndicate includes all station accesses.
#define WILDCARD_LIMIT_SYNDICATE list(WILDCARD_NAME_SYNDICATE = list(limit = -1, usage = list()))
/// Wildcard slot define for Deathsquad black cards. Can hold infinite of any Centcom level wildcard. Centcom includes all station accesses.
#define WILDCARD_LIMIT_DEATHSQUAD list(WILDCARD_NAME_CENTCOM = list(limit = -1, usage = list()))
/// Wildcard slot define for Centcom blue cards. Can hold infinite of any Centcom level wildcard. Centcom includes all station accesses.
#define WILDCARD_LIMIT_CENTCOM list(WILDCARD_NAME_CENTCOM = list(limit = -1, usage = list()))
/// Wildcard slot define for Prisoner orange cards. No wildcard slots.
#define WILDCARD_LIMIT_PRISONER list()
/// Wildcard slot define for the cargo variant of agent ID. Can hold 6 common, 2 command and 1 captain access.
#define WILDCARD_LIMIT_CHAMELEON list( \
	WILDCARD_NAME_COMMON = list(limit = 6, usage = list()), \
	WILDCARD_NAME_COMMAND = list(limit = 2, usage = list()), \
	WILDCARD_NAME_CAPTAIN = list(limit = 1, usage = list()) \
)
/// Wildcard slot define for admin/debug/weird, special abstract cards. Can hold infinite of any access.
#define WILDCARD_LIMIT_ADMIN list(WILDCARD_NAME_ALL = list(limit = -1, usage = list()))

/**
 * x1, y1, x2, y2 - Represents the bounding box for the ID card's non-transparent portion of its various icon_states.
 * Used to crop the ID card's transparency away when chaching the icon for better use in tgui chat.
 */
#define ID_ICON_BORDERS 1, 9, 32, 24

///Honorific will display next to the first name.
#define HONORIFIC_POSITION_FIRST (1<<0)
///Honorific will display next to the last name.
#define HONORIFIC_POSITION_LAST (1<<1)
///Honorific will not be displayed.
#define HONORIFIC_POSITION_NONE (1<<2)
///Honorific will be appended to the full name at the start.
#define HONORIFIC_POSITION_FIRST_FULL (1<<3)
///Honorific will be appended to the full name at the end.
#define HONORIFIC_POSITION_LAST_FULL (1<<4)

#define HONORIFIC_POSITION_BITFIELDS(...) list( \
	"Honorific + First Name" = HONORIFIC_POSITION_FIRST, \
	"Honorific + Last Name" = HONORIFIC_POSITION_LAST, \
	"Honorific + Full Name" = HONORIFIC_POSITION_FIRST_FULL, \
	"Full Name + Honorific" = HONORIFIC_POSITION_LAST_FULL, \
	"Disable Honorific" = HONORIFIC_POSITION_NONE, \
)
