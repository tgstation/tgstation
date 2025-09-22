/// Configuration entries for the AI-Controlled Human Crew Foundation feature.

/datum/config_entry/flag/ai_control_enabled
	default = TRUE

/datum/config_entry/number/ai_control_cadence_seconds
	default = 1.5
	integer = FALSE
	min_val = 0.1
	max_val = 10

/datum/config_entry/number/ai_control_max_rollouts
	default = 200
	integer = TRUE
	min_val = 1
	max_val = 200

/datum/config_entry/number/ai_control_task_queue_limit
	default = 4
	integer = TRUE
	min_val = 1
	max_val = 10

/datum/config_entry/number/ai_control_telemetry_minutes
	default = 30
	integer = TRUE
	min_val = 10
	max_val = 120

/datum/config_entry/number/ai_control_multiplier_routine
	default = 1.6
	integer = FALSE
	min_val = 0.1
	max_val = 4

/datum/config_entry/number/ai_control_multiplier_logistics
	default = 1.35
	integer = FALSE
	min_val = 0.1
	max_val = 4

/datum/config_entry/number/ai_control_multiplier_medical
	default = 0.9
	integer = FALSE
	min_val = 0.1
	max_val = 4

/datum/config_entry/number/ai_control_multiplier_security
	default = 0.8
	integer = FALSE
	min_val = 0.1
	max_val = 4

/datum/config_entry/number/ai_control_multiplier_support
	default = 1.1
	integer = FALSE
	min_val = 0.1
	max_val = 4

/datum/config_entry/number/ai_control_emergency_blue
	default = 0.85
	integer = FALSE
	min_val = 0
	max_val = 2

/datum/config_entry/number/ai_control_emergency_red
	default = 0.7
	integer = FALSE
	min_val = 0
	max_val = 2

/datum/config_entry/number/ai_control_emergency_delta
	default = 0.6
	integer = FALSE
	min_val = 0
	max_val = 2

/datum/config_entry/number/ai_control_max_hazard
	default = 0.65
	integer = FALSE
	min_val = 0
	max_val = 1

/datum/config_entry/number/ai_control_max_chain_failures
	default = 2
	integer = TRUE
	min_val = 0
	max_val = 10

/datum/config_entry/number/ai_control_item_toggle_seconds
	default = 5
	integer = TRUE
	min_val = 0
	max_val = 60

/datum/config_entry/number/ai_control_aggressive_seconds
	default = 8
	integer = TRUE
	min_val = 0
	max_val = 120

/datum/config_entry/number/ai_control_reservation_seconds
	default = 5
	integer = TRUE
	min_val = 1
	max_val = 60

/datum/config_entry/number/ai_control_reservation_retry_seconds
	default = 3
	integer = TRUE
	min_val = 1
	max_val = 60

/datum/config_entry/string/ai_gateway_planner_url
	default = "http://127.0.0.1:15151/plan"

/datum/config_entry/string/ai_gateway_parser_url
	default = "http://127.0.0.1:15152/parse"

/datum/config_entry/number/ai_gateway_planner_timeout_ds
	default = 50
	integer = TRUE
	min_val = 5
	max_val = 300

/datum/config_entry/number/ai_gateway_parser_timeout_ds
	default = 50
	integer = TRUE
	min_val = 5
	max_val = 300

/datum/config_entry/number/ai_gateway_retry_ds
	default = 20
	integer = TRUE
	min_val = 1
	max_val = 100

