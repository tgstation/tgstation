// Given to heretic monsters.
/datum/action/cooldown/spell/emp/eldritch
	name = "Energetic Pulse"
	desc = "A spell that causes a large EMP around you, disabling electronics."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "E'P."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	emp_heavy = 6
	emp_light = 10
