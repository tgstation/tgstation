/obj/item/book/granter/martial/plasma_fist
	martial = /datum/martial_art/plasma_fist
	name = "frayed scroll"
	martial_name = "plasma fist"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	greet = "<span class='boldannounce'>You have learned the ancient martial art of Plasma Fist. Your combos are extremely hard to pull off, but include some of the most deadly moves ever seen including \
		the plasma fist, which when pulled off will make someone violently explode.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	remarks = list(
		"Balance...",
		"Power...",
		"Control...",
		"Mastery...",
		"Vigilance...",
		"Skill...",
	)

/obj/item/book/granter/martial/plasma_fist/on_reading_finished(mob/living/carbon/user)
	. = ..()
	if(uses <= 0)
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

/obj/item/book/granter/martial/plasma_fist/nobomb
	martial = /datum/martial_art/plasma_fist/nobomb
