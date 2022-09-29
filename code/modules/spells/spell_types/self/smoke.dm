/// Basic smoke spell.
/datum/action/cooldown/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of smoke at your location. \
		People within will begin to choke and drop their items."
	button_icon_state = "smoke"

	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS

	invocation_type = INVOCATION_NONE

	smoke_type = /datum/effect_system/fluid_spread/smoke/bad
	smoke_amt = 4

/// Chaplain smoke.
/datum/action/cooldown/spell/smoke/lesser
	name = "Holy Smoke"
	desc = "This spell spawns a small cloud of smoke at your location."

	school = SCHOOL_HOLY
	cooldown_time = 36 SECONDS
	spell_requirements = NONE

	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 2

/// Unused smoke that makes people sleep. Used to be for cult?
/datum/action/cooldown/spell/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."
	background_icon_state = "bg_cult"

	cooldown_time = 20 SECONDS

	smoke_type = /datum/effect_system/fluid_spread/smoke/sleeping
