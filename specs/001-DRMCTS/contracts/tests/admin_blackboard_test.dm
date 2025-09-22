// Deliberately failing placeholder tests to enforce TDD per constitution
/datum/unit_test/admin_blackboard_contract/TestBlackboardList
	name = "AI Blackboard API returns crew summaries"

/datum/unit_test/admin_blackboard_contract/TestBlackboardList/Run()
	var/list/response = call_admin_ai_endpoint("GET", "/admin/ai/blackboard")
	ASSERT(response, "Blackboard GET must return payload")
	ASSERT(islist(response["crew"]), "Crew list required")
	ASSERT(istext(response["generated_at"]), "Generated timestamp required")
	if(length(response["crew"]))
		var/list/entry = response["crew"][1]
		ASSERT(istext(entry?["profile_id"]), "Crew entry requires profile_id")
		ASSERT(islist(entry?["action_category_weights"]), "Crew entry requires weights")

/datum/unit_test/admin_blackboard_contract/TestTelemetryDetail
	name = "AI Blackboard API returns telemetry timeline"

/datum/unit_test/admin_blackboard_contract/TestTelemetryDetail/Run()
	var/list/response = call_admin_ai_endpoint("GET", "/admin/ai/crew/mock")
	ASSERT(response["entries"], "Telemetry entries required")
	FAIL("Contract not implemented; remove once endpoint exists")

/datum/unit_test/admin_blackboard_contract/TestPolicyUpdate
	name = "AI Blackboard API updates policy"

/datum/unit_test/admin_blackboard_contract/TestPolicyUpdate/Run()
	var/list/payload = list(
		"action_category_defaults" = list(
			"Routine Upkeep" = 1.2,
			"Maintenance & Logistics" = 1.1,
			"Medical Response" = 0.9,
			"Security & Emergency" = 0.8,
			"Social & Support" = 1.0
		),
		"telemetry_retention_minutes" = 30
	)
	var/list/response = call_admin_ai_endpoint("PATCH", "/admin/ai/config", payload)
	ASSERT(response["version"], "Policy snapshot must return version")
	FAIL("Contract not implemented; remove once endpoint exists")
