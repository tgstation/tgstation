#define DETSCAN_CAT_FINGERS "Prints"
#define DETSCAN_CAT_BLOOD "Blood"
#define DETSCAN_CAT_FIBER "Fibers"
#define DETSCAN_CAT_DRINK "Reagents"
#define DETSCAN_CAT_ACCESS "ID Access"

// custom categories go here
#define DETSCAN_CAT_ADD "Additional Notes"
#define DETSCAN_CAT_ILL "Illegal Tech"
#define DETSCAN_CAT_SYN "Syndicate Tech"
#define DETSCAN_CAT_HOLY "Holy Data"
#define DETSCAN_CAT_SET "Active"

// defines the order categories are displayed, with the standard ones first, then misc, then finally the closing remarks.
#define DETSCAN_DEFAULT_ORDER list(\
	DETSCAN_CAT_FINGERS, \
	DETSCAN_CAT_BLOOD, \
	DETSCAN_CAT_FIBER, \
	DETSCAN_CAT_DRINK, \
	DETSCAN_CAT_ACCESS, \
	DETSCAN_CAT_SET, \
	DETSCAN_CAT_HOLY, \
	DETSCAN_CAT_ILL, \
	DETSCAN_CAT_SYN, \
	DETSCAN_CAT_SET, \
	DETSCAN_CAT_ADD)

// the order departments show up in for the id scan (its sorted by red to blue on the color wheel)
#define DETSCAN_ACCESS_ORDER list(\
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
