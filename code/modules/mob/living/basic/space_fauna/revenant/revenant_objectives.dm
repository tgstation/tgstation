//objectives
/datum/objective/revenant
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(350,600)
	explanation_text = "Absorb [targetAmount] points of essence from humans."
	..()

/datum/objective/revenant/check_completion()
	if(!isrevenant(owner.current))
		return FALSE
	var/mob/living/basic/revenant/R = owner.current
	if(!R || R.stat == DEAD)
		return FALSE
	var/essence_stolen = R.essence_accumulated
	if(essence_stolen < targetAmount)
		return FALSE
	return TRUE

/datum/objective/revenant_fluff

/datum/objective/revenant_fluff/New()
	var/list/explanation_texts = list(
		"Assist and exacerbate existing threats at critical moments.", \
		"Impersonate or be worshipped as a god.", \
		"Cause as much chaos and anger as you can without being killed.", \
		"Damage and render as much of the station rusted and unusable as possible.", \
		"Disable and cause malfunctions in as many machines as possible.", \
		"Ensure that any holy weapons are rendered unusable.", \
		"Heed and obey the requests of the dead, provided that carrying them out wouldn't be too inconvenient or self-destructive.", \
		"Make the crew as miserable as possible.", \
		"Make the clown as miserable as possible.", \
		"Make the captain as miserable as possible.", \
		"Prevent the use of energy weapons where possible.",
	)
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/revenant_fluff/check_completion()
	return TRUE
