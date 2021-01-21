/// This is the only ruleset that should be picked this round, used by admins and should not be on rulesets in code.
#define ONLY_RULESET 1

/// Only one ruleset with this flag will be picked.
#define HIGH_IMPACT_RULESET 2

/// This ruleset can only be picked once. Anything that does not have a scaling_cost MUST have this.
#define LONE_RULESET 4
