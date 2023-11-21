/datum/symptom
	// How dangerous the symptom is.
		// 0 = generally helpful (ex: full glass syndrome)
		// 1 = neutral, just flavor text (ex: headache)
		// 2 = minor inconvenience (ex: tourettes)
		// 3 = severe inconvenience (ex: random tripping)
		// 4 = likely to indirectly lead to death (ex: Harlequin Ichthyosis)
		// 5 = will definitely kill you (ex: gibbingtons/necrosis)
	var/badness = EFFECT_DANGER_ANNOYING
	///are we a restricted type
	var/restricted = FALSE
	var/encyclopedia = ""
	var/stage = -1
		// Diseases start at stage 1. They slowly and cumulatively proceed their way up.
		// Try to keep more severe effects in the later stages.

	var/chance = 3
		// Under normal conditions, the percentage chance per tick to activate.
	var/max_chance = 6
		// Maximum percentage chance per tick.
	
	var/multiplier = 1
		// How strong the effects are. Use this in activate().
	var/max_multiplier = 1
		// Maximum multiplier.

/datum/symptom/proc/minormutate()
	if (prob(20))
		chance = rand(initial(chance), max_chance)

/datum/symptom/proc/multiplier_tweak(tweak)
	multiplier = clamp(multiplier+tweak,1,max_multiplier)
