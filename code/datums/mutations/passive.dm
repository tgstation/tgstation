/datum/mutation/human/biotechcompat
	name = "Biotech Compatibility"
	desc = "Subject is more compatibile with biotechnology such as skillchips."
	quality = POSITIVE
	instability = 5

/datum/mutation/human/biotechcompat/on_acquiring(mob/living/carbon/human/H)
	. = ..()
	H.max_skillchip_slots += 1
	H.update_skillchips()

/datum/mutation/human/biotechcompat/on_losing(mob/living/carbon/human/owner)
	owner.max_skillchip_slots -= 1
	owner.update_skillchips()
	return ..()
