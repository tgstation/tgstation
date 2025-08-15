// Config values, don't change these randomly
/// Configuring "roundstart" type rulesets
#define ROUNDSTART "roundstart"
/// Configuring "light midround" type rulesets
#define LIGHT_MIDROUND "light_midround"
/// Configuring "heavy midround" type rulesets
#define HEAVY_MIDROUND "heavy_midround"
/// Configuring "latejoin" type rulesets
#define LATEJOIN "latejoin"

/// Lower end for how many of a ruleset type can be selected
#define LOW_END "low"
/// Upper end for how many of a ruleset type can be selected
#define HIGH_END "high"
/// Population threshold for ruleset types - below this, only a quarter of the low to high end is used
#define HALF_RANGE_POP_THRESHOLD "half_range_pop_threshold"
/// Population threshold for ruleset types - below this, only a half of the low to high end is used
#define FULL_RANGE_POP_THRESHOLD "full_range_pop_threshold"
/// Round time threshold for which a ruleset type will be selected
#define TIME_THRESHOLD "time_threshold"
/// Lower end for cooldown duration for a ruleset type
#define EXECUTION_COOLDOWN_LOW "execution_cooldown_low"
/// Upper end for cooldown duration for a ruleset type
#define EXECUTION_COOLDOWN_HIGH "execution_cooldown_high"

// Tiers, don't change these randomly
/// Tier 0, no antags at all
#define DYNAMIC_TIER_GREEN 0
/// Tier 1, low amount of antags
#define DYNAMIC_TIER_LOW 1
/// Tier 2, medium amount of antags
#define DYNAMIC_TIER_LOWMEDIUM 2
/// Tier 3, high amount of antags
#define DYNAMIC_TIER_MEDIUMHIGH 3
/// Tier 4, maximum amount of antags
#define DYNAMIC_TIER_HIGH 4

// Ruleset flags
/// Ruleset denotes that it involves an outside force spawning in to attack the station
#define RULESET_INVADER (1<<0)
/// Multiple high impact rulesets cannot be selected unless we're at the highest tier
#define RULESET_HIGH_IMPACT (1<<1)
/// Ruleset can be configured by admins (implements /proc/configure_ruleset)
/// Only implemented for midrounds currently
#define RULESET_ADMIN_CONFIGURABLE (1<<2)

/// Href for cancelling midround rulesets before execution
#define MIDROUND_CANCEL_HREF(...) "(<a href='byond://?src=[REF(src)];admin_cancel_midround=[REF(picked_ruleset)]'>CANCEL</a>)"
/// Href for rerolling midround rulesets before execution
#define MIDROUND_REROLL_HREF(rulesets) "[length(rulesets) \
	? "(<a href='byond://?src=[REF(src)];admin_reroll=[REF(picked_ruleset)]'>SOMETHING ELSE</a>)" \
	: "([span_tooltip("There are no more rulesets to pick from!", "NOTHING ELSE")])"\
]"

#define RULESET_CONFIG_CANCEL "Cancel"

/// Used to easily get a config entry for a dynamic ruleset or tier
#define GET_DYNAMIC_CONFIG(some_typepath, var_name) SSdynamic.get_config_value(some_typepath, NAMEOF(some_typepath, ##var_name), some_typepath::##var_name)
