/datum/mood_event/drankblood
	description = span_nicegreen("Я жадно питался тем, что питает меня.")
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = span_boldwarning("Я выпил кровь низшего существа. Омерзительно.")
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = span_boldwarning("Я пил кровь мертвецов. Я достоин лучшего.")
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = span_boldwarning("Я пил синтетическую кровь. Что со мной не так?")
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = span_boldwarning("Я питался кем-то до его смерти. Я чувствую себя... менее человечным.")
	mood_change = -20
	timeout = 15 MINUTES

/datum/mood_event/madevamp
	description = span_boldwarning("Смертный достиг апофеоза — нежизни — моей собственной рукой..")
	mood_change = 15
	timeout = 10 MINUTES

/datum/mood_event/coffinsleep
	description = span_nicegreen("Днем я спал в гробу. Я снова чувствую себя целым.")
	mood_change = 10
	timeout = 5 MINUTES

/datum/mood_event/daylight_1
	description = span_boldwarning("Днем я плохо спал в импровизированном гробу.")
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/daylight_2
	description = span_boldwarning("Меня атаковали неумолимые лучи солнца.")
	mood_change = -7
	timeout = 5 MINUTES

///Candelabrum's mood event to non Bloodsucker/Vassals
/datum/mood_event/vampcandle
	description = span_boldwarning("Что-то заставляет твой разум чувствовать себя... вольным.")
	mood_change = -15
	timeout = 5 MINUTES

//Blood mirror's mood event to non-bloodsuckers/vassals that attempt to use it and get randomly warped.
/datum/mood_event/bloodmirror
	description = span_boldwarning("ПРОРОЧЕСТВО О КРОВИ РАЗЛИЛО СВОИ ПЯТНА НА МОЕЙ ПСИХИКЕ.")
	mood_change = -30
	timeout = 7 MINUTES
