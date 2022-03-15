/datum/action/cooldown/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of smoke at your location. \
		People within will begin to choke and drop their items."
	action_icon_state = "smoke"

	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS

	invocation_type = INVOCATION_NONE

	smoke_spread = SMOKE_HARMFUL
	smoke_amt = 4

/// Chaplain smoke.
/datum/action/cooldown/spell/smoke/lesser
	desc = "This spell spawns a small cloud of smoke at your location."

	school = SCHOOL_HOLY
	cooldown_time = 36 SECONDS

	spell_requirements = NONE

	smoke_spread = SMOKE_HARMFUL
	smoke_amt = 2
