// Given to heretic monsters.
/datum/action/cooldown/spell/shapeshift/eldritch
	name = "Shapechange"
	desc = "A spell that allows you to take on the form of another creature, gaining their abilities. \
		After making your choice, you will be unable to change to another."
	background_icon_state = "bg_ecult"

	school = SCHOOL_FORBIDDEN
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	possible_shapes = list(
		/mob/living/basic/mouse,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/pet/cat,
	)
