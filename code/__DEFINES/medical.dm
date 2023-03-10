/// Physical statuses
#define PHYSICAL_ACTIVE "Active"
#define PHYSICAL_PHYSICALLY_UNFIT "Physically Unfit"
#define PHYSICAL_UNCONSCIOUS "*Unconscious*"
#define PHYSICAL_DECEASED "*Deceased*"
#define PHYSICAL_CANCEL "Cancel"

/// List of available physical statuses
#define PHYSICAL_STATUSES(...) list(\
	PHYSICAL_ACTIVE, \
	PHYSICAL_PHYSICALLY_UNFIT, \
	PHYSICAL_UNCONSCIOUS, \
	PHYSICAL_DECEASED, \
	PHYSICAL_CANCEL, \
)

/// Mental statuses
#define MENTAL_STABLE "Stable"
#define MENTAL_WATCH "*Watch*"
#define MENTAL_UNSTABLE "*Unstable*"
#define MENTAL_INSANE "*Insane*"
#define MENTAL_CANCEL "Cancel"

/// List of available mental statuses
#define MENTAL_STATUSES(...) list(\
	MENTAL_STABLE, \
	MENTAL_WATCH, \
	MENTAL_UNSTABLE, \
	MENTAL_INSANE, \
	MENTAL_CANCEL, \
)
