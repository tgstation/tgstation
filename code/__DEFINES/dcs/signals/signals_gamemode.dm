///from base of [/datum/game_mode/dynamic/proc/init_rulesets]: ([rulesets][/list], ruleset_type)
#define COMSIG_DYNAMIC_INITIALIZING_RULESETS "dynamic_initializing_rulesets"
///from base of [/datum/game_mode/dynamic/proc/generate_threat]: (threat_level, peaceful_percentage)
#define COMSIG_DYNAMIC_GENERATE_THREAT "dynamic_generate_threat"
///from base of [/datum/game_mode/dynamic/proc/generate_budgets]: (round_start_budget, initial_round_start_budget, mid_round_budget)
#define COMSIG_DYNAMIC_GENERATE_BUDGETS "dynamic_generate_budgets"
///from base of [/datum/game_mode/dynamic/proc/setup_parameters]: ()
#define COMSIG_DYNAMIC_SETUP_PARAMS "dynamic_setup_params"
///from base of [/datum/game_mode/dynamic/proc/setup_shown_threat]: (shown_threat, threat_level, fake_report)
#define COMSIG_DYNAMIC_SETUP_SHOWN_THREAT "dynamic_setup_shown_threat"
///from base of [/datum/game_mode/dynamic/proc/set_cooldowns]: (latejoin_injection_cooldown, latejoin_injection_cooldown_middle)
#define COMSIG_DYNAMIC_SETUP_COOLDOWNS "dynamic_setup_cooldowns"
///from base of [/datum/game_mode/dynamic/proc/on_pre_random_event]: ([round_event_control][/datum/round_event_control])
#define COMSIG_DYNAMIC_TRY_HIJACK_RANDOM_EVENT "dynamic_try_hijack_random_event"
///from base of [/datum/game_mode/dynamic/proc/get_heavy_midround_injection_chance]: (chance, dry_run)
#define COMSIG_DYNAMIC_GET_HEAVY_MIDROUND_INJECTION_CHANCE "dynamic_get_heavy_midround_injection_chance"
	///Ensures that the % chance to roll a heavy midround is 0% if returned by a handler to [COMSIG_DYNAMIC_GET_HEAVY_MIDROUND_INJECTION_CHANCE].
	#define FORCE_LIGHT_MIDROUND (1<<0)
	///Ensures that the % chance to roll a heavy midround is 100% if returned by a handler to [COMSIG_DYNAMIC_GET_HEAVY_MIDROUND_INJECTION_CHANCE]. Overrides [FORCE_LIGHT_MIDROUND].
	#define FORCE_HEAVY_MIDROUND (1<<1)
