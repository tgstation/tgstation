/// Unit coverage for ai_control_policy datum enforcing scaling and reset behavior.

/datum/unit_test/ai_control_policy_unit/reset_defaults
	name = "AI Control Policy: reset_to_defaults restores baseline configuration"

/datum/unit_test/ai_control_policy_unit/reset_defaults/Run()
	var/datum/ai_control_policy/policy = new(list(
		"exploration_multipliers" = list(
			AI_ACTION_CATEGORY_ROUTINE = 2,
			AI_ACTION_CATEGORY_LOGISTICS = 2,
			AI_ACTION_CATEGORY_MEDICAL = 2,
			AI_ACTION_CATEGORY_SECURITY = 0.3,
			AI_ACTION_CATEGORY_SUPPORT = 2,
		),
		"telemetry_retention_minutes" = 15,
		"cadence_seconds" = 3,
	))
	policy.enabled = FALSE
	policy.action_category_defaults[AI_ACTION_CATEGORY_ROUTINE] = 5
	policy.telemetry_retention_minutes = 999

	policy.reset_to_defaults()

	TEST_ASSERT(policy.enabled, "reset_to_defaults should re-enable policy")
	TEST_ASSERT_EQUAL(policy.telemetry_retention_minutes, AI_CONTROL_DEFAULT_TELEMETRY_MINUTES, "telemetry window reset to default minutes")

	for(var/category in GLOB.ai_control_action_categories)
		var/default_value = GLOB.ai_control_default_multipliers[category]
		TEST_ASSERT_EQUAL(policy.action_category_defaults[category], default_value, "default multiplier restored for [category]")

	return UNIT_TEST_PASSED

/datum/unit_test/ai_control_policy_unit/multiplier_scaling
	name = "AI Control Policy: alert scaling clamps security multipliers"

/datum/unit_test/ai_control_policy_unit/multiplier_scaling/Run()
	var/datum/ai_control_policy/policy = new

	policy.apply_config(list(
		"exploration_multipliers" = list(
			AI_ACTION_CATEGORY_ROUTINE = 0.2,
			AI_ACTION_CATEGORY_LOGISTICS = 1.8,
			AI_ACTION_CATEGORY_MEDICAL = 1.1,
			AI_ACTION_CATEGORY_SECURITY = 1.75,
			AI_ACTION_CATEGORY_SUPPORT = 0.95,
		),
		"telemetry_retention_minutes" = 500,
	))

	TEST_ASSERT_EQUAL(policy.telemetry_retention_minutes, AI_CONTROL_MAX_TELEMETRY_MINUTES, "telemetry retention clamps to maximum bound")

	var/security_base = policy.action_category_defaults[AI_ACTION_CATEGORY_SECURITY]
	TEST_ASSERT_EQUAL(security_base, 1, "security multiplier clamped to 1.0 before alert scaling")

	var/security_red = policy.get_category_multiplier(AI_ACTION_CATEGORY_SECURITY, "red")
	var/expected_red = security_base * policy.get_alert_scale("red")
	TEST_ASSERT_EQUAL(security_red, expected_red, "red alert scaling honors emergency modifier")

	var/routine_base = policy.action_category_defaults[AI_ACTION_CATEGORY_ROUTINE]
	TEST_ASSERT_EQUAL(routine_base, 0.2, "routine multiplier preserved above minimum bound")
	var/routine_no_alert = policy.get_category_multiplier(AI_ACTION_CATEGORY_ROUTINE, null)
	TEST_ASSERT_EQUAL(routine_no_alert, routine_base, "no alert keeps base multiplier value")

	policy.apply_config(list("exploration_multipliers" = list(AI_ACTION_CATEGORY_SUPPORT = -3)))
	var/support_base = policy.action_category_defaults[AI_ACTION_CATEGORY_SUPPORT]
	TEST_ASSERT_EQUAL(support_base, 0.1, "negative multiplier inputs clamp to minimum 0.1")

	return UNIT_TEST_PASSED
