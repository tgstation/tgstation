/// Physical statuses
#define PHYSICAL_ACTIVE "Active"
#define PHYSICAL_DEBILITATED "Debilitated"
#define PHYSICAL_UNCONSCIOUS "Unconscious"
#define PHYSICAL_DECEASED "Deceased"

/// List of available physical statuses
#define PHYSICAL_STATUSES list(\
	PHYSICAL_ACTIVE, \
	PHYSICAL_DEBILITATED, \
	PHYSICAL_UNCONSCIOUS, \
	PHYSICAL_DECEASED, \
)

/// Mental statuses
#define MENTAL_STABLE "Stable"
#define MENTAL_WATCH "Watch"
#define MENTAL_UNSTABLE "Unstable"
#define MENTAL_INSANE "Insane"

/// List of available mental statuses
#define MENTAL_STATUSES list(\
	MENTAL_STABLE, \
	MENTAL_WATCH, \
	MENTAL_UNSTABLE, \
	MENTAL_INSANE, \
)

/// The percentage amount of health required for a mob to be considered to be
#define CLEAN_BILL_OF_HEALTH_RATIO 0.9

///Cooldown for being on the recently treated trait for the purposes for bounty submission
#define RECENTLY_HEALED_COOLDOWN 5 MINUTES

// Return values for the limb_applicable component's callback can_apply
/// Block the standard application of this item
#define LIMB_APPLICABLE_BLOCK_APPLICATION (1<<0)
/// Block the rest of the item_interaction chain, if application is not being done.
#define LIMB_APPLICABLE_BLOCK_ITEM_INTERACTION (1<<1)
