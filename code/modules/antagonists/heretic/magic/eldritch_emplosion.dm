// Given to heretic monsters.
/datum/action/cooldown/spell/emp/eldritch
	name = "Потусторонний импульс"
	desc = "Заклинание, которое вызывает вокруг вас сильное ЭМИ, выводящее из строя электронику."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "E'P."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	emp_heavy = 6
	emp_light = 10
