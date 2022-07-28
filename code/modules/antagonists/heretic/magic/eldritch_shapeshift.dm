// Given to heretic monsters.
/datum/action/cooldown/spell/shapeshift/eldritch
	school = SCHOOL_FORBIDDEN
	background_icon_state = "bg_ecult"
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER

	possible_shapes = list(
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/pet/cat,
	)
