/// This is the only ruleset that should be picked this round, used by admins and should not be on rulesets in code.
#define ONLY_RULESET 1

/// Only one ruleset with this flag will be picked.
#define HIGHLANDER_RULESET 2

/// Used for "Dynamic secret", where only one roundstart ruleset is picked, with the rest being midround traitors and minor rulesets.
#define TRAITOR_RULESET 4

/// Used for "Dynamic secret", where only one roundstart ruleset is picked, with the rest being midround traitors and minor rulesets.
#define MINOR_RULESET 8

/// This ruleset can only be picked once. Anything that does not have a scaling_cost MUST have this.
#define LONE_RULESET 16
