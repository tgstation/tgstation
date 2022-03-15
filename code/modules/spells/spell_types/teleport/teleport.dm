/datum/action/cooldown/spell/teleport/area_teleport/wizard
	name = "Teleport"
	desc = "This spell teleports you to an area of your selection."
	action_icon_state = "teleport"
	sound = 'sound/magic/teleport_diss.ogg'

	school = SCHOOL_FORBIDDEN
	charge_max = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "SCYAR NILA"
	invocation_type = INVOCATION_SHOUT

	smoke_type = SMOKE_HARMLESS
	smoke_amt = 2

	post_teleport_sound = 'sound/magic/teleport_app.ogg'

/datum/action/cooldown/spell/teleport/area_teleport/wizard/santa
	name = "Santa Teleport"

	school = SCHOOL_TRANSLOCATION // Santa magic is NOT forbidden arts

	invocation = "HO HO HO"
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

	invocation_says_area = FALSE // Santa moves in mysterious ways
