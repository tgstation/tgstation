/datum/objective/revenant

/datum/objective/revenant/New()
	target_amount = rand(350, 600)
	explanation_text = "Absorb [target_amount] points of essence from humans."
	return ..()

/datum/objective/revenant/check_completion()
	if(!isrevenant(owner.current))
		return FALSE
	var/mob/living/basic/revenant/owner_mob = owner.current
	if(QDELETED(owner_mob) || owner_mob.stat == DEAD)
		return FALSE
	var/essence_stolen = owner_mob.essence_accumulated
	return essence_stolen >= target_amount

/datum/objective/revenant_fluff

/datum/objective/revenant_fluff/New()
	var/list/explanation_texts = list(
		"Assist and exacerbate existing threats at critical moments.",
		"Cause as much chaos and anger as you can without being killed.",
		"Damage and render as much of the station rusted and unusable as possible.",
		"Disable and cause malfunctions in as many machines as possible.",
		"Ensure that any holy weapons are rendered unusable.",
		"Heed and obey the requests of the dead, provided that carrying them out wouldn't be too inconvenient or self-destructive.",
		"Impersonate or be worshipped as a God.",
		"Make the captain as miserable as possible.",
		"Make the clown as miserable as possible.",
		"Make the crew as miserable as possible.",
		"Prevent the use of energy weapons where possible.",
	)
	explanation_text = pick(explanation_texts)
	return ..()

/datum/objective/revenant_fluff/check_completion()
	return TRUE
