
// CATEGORY HEADERS

/// Fingerpints detected
#define DETSCAN_CATEGORY_FINGERS "Prints"
/// Displays any bloodprints found and their uefi
#define DETSCAN_CATEGORY_BLOOD "Blood"
/// Clothing and glove fibers
#define DETSCAN_CATEGORY_FIBER "Fibers"
/// Liquids detected
#define DETSCAN_CATEGORY_DRINK "Reagents"
/// ID Access
#define DETSCAN_CATEGORY_ACCESS "ID Access"

// The categories below do not have hard rules on what info is displayed, and are for categorizing info thematically.

/// Generic extra information category
#define DETSCAN_CATEGORY_NOTES "Additional Notes"
/// Attributes that might be illegal, but don't have ties to syndicate/aren't exclusively produced by them
#define DETSCAN_CATEGORY_ILLEGAL "Illegal Tech"
/// The emags and other in-house technology from the syndicate
#define DETSCAN_CATEGORY_SYNDIE "Syndicate Tech"
/// praise be
#define DETSCAN_CATEGORY_HOLY "Holy Data"
/// The mode that the items in, what kind of item is dispensed, etc
#define DETSCAN_CATEGORY_SETTINGS "Active Settings"

// If your category is not in this list it WILL NOT BE DISPLAYED
/// defines the order categories are displayed, with the original categories, then custom ones, then finally the extra info.
#define DETSCAN_DEFAULT_ORDER(...) list(\
	DETSCAN_CATEGORY_FINGERS, \
	DETSCAN_CATEGORY_BLOOD, \
	DETSCAN_CATEGORY_FIBER, \
	DETSCAN_CATEGORY_DRINK, \
	DETSCAN_CATEGORY_ACCESS, \
	DETSCAN_CATEGORY_SETTINGS, \
	DETSCAN_CATEGORY_HOLY, \
	DETSCAN_CATEGORY_ILLEGAL, \
	DETSCAN_CATEGORY_SYNDIE, \
	DETSCAN_CATEGORY_NOTES, \
)

/// the order departments show up in for the id scan (its sorted by red to blue on the color wheel)
#define DETSCAN_ACCESS_ORDER(...) list(\
	REGION_SECURITY, \
	REGION_ENGINEERING, \
	REGION_SUPPLY, \
	REGION_GENERAL, \
	REGION_MEDBAY, \
	REGION_COMMAND, \
	REGION_RESEARCH, \
	REGION_CENTCOM, \
)

/// if any categories list has this entry, it will be hidden
#define DETSCAN_BLOCK "DETSCAN_BLOCK"

/// Wanted statuses
#define WANTED_ARREST "Arrest"
#define WANTED_DISCHARGED "Discharged"
#define WANTED_NONE "None"
#define WANTED_PAROLE "Parole"
#define WANTED_PRISONER "Incarcerated"
#define WANTED_SUSPECT "Suspected"

/// List of available wanted statuses
#define WANTED_STATUSES(...) list(\
	WANTED_NONE, \
	WANTED_SUSPECT, \
	WANTED_ARREST, \
	WANTED_PRISONER, \
	WANTED_PAROLE, \
	WANTED_DISCHARGED, \
)
