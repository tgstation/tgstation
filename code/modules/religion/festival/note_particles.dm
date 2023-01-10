///musical notes! Try to use these sparingly, gents.
/particles/musical_notes
	icon = 'icons/effects/particles/notes/note.dmi'
	icon_state = list(
		"note_1" = 1,
		"note_2" = 1,
		"note_3" = 1,
		"note_4" = 1,
		"note_5" = 1,
		"note_6" = 1,
		"note_7" = 1,
		"note_8" = 1,
	)
	width = 100
	height = 100
	count = 250
	spawning = 0.6
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)

/particles/musical_notes/holy
	icon = 'icons/effects/particles/notes/note_holy.dmi'
	icon_state = list(
		"holy_1" = 1,
		"holy_2" = 1,
		"holy_3" = 1,
		"holy_4" = 1,
		"holy_5" = 1,
		"holy_6" = 1,
		"holy_7" = 1,
		"holy_8" = 1,
		"holy_9" = 4, //holy theme specific
	)

/particles/musical_notes/nullwave
	icon = 'icons/effects/particles/notes/note_null.dmi'
	icon_state = list(
		"null_1" = 1,
		"null_2" = 1,
		"null_3" = 1,
		"null_4" = 1,
		"null_5" = 1,
		"null_6" = 1,
		"null_7" = 1,
		"null_8" = 1,
		"null_9" = 2, //heal theme specific
		"null_10" = 2, //heal theme specific
	)

/particles/musical_notes/harm
	icon = 'icons/effects/particles/notes/note_harm.dmi'
	icon_state = list(
		"harm_1" = 1,
		"harm_2" = 1,
		"harm_3" = 1,
		"harm_4" = 1,
		"harm_5" = 1,
		"harm_6" = 1,
		"harm_7" = 1,
		"harm_8" = 1,
		"harm_9" = 2, //harm theme specific
		"harm_10" = 2, //harm theme specific
	)

/particles/musical_notes/sleepy
	icon = 'icons/effects/particles/notes/note_sleepy.dmi'
	icon_state = list(
		"sleepy_1" = 1,
		"sleepy_2" = 1,
		"sleepy_3" = 1,
		"sleepy_4" = 1,
		"sleepy_5" = 1,
		"sleepy_6" = 1,
		"sleepy_7" = 1,
		"sleepy_8" = 1,
		"sleepy_9" = 2, //sleepy theme specific
		"sleepy_10" = 2, //sleepy theme specific
	)
