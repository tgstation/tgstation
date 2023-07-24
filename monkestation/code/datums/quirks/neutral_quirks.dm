/datum/quirk/gigantism
	name = "Gigantism"
	desc = "Your cells take up more space than others', giving you a larger appearance. You find it difficult to avoid looking down on others. Literally."
	value = 0
	icon = FA_ICON_CHEVRON_CIRCLE_UP
	quirk_flags = QUIRK_CHANGES_APPEARANCE

/datum/quirk/gigantism/add()
	. = ..()
	if (ishuman(quirk_holder))
		var/mob/living/carbon/human/gojira = quirk_holder
		if(gojira.dna)
			gojira.dna.add_mutation(/datum/mutation/human/gigantism)
