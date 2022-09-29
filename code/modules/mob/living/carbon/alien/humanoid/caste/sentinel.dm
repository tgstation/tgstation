/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 150
	health = 150
	icon_state = "aliens"

/mob/living/carbon/alien/humanoid/sentinel/Initialize(mapload)
	var/datum/action/cooldown/alien/sneak/sneaky_beaky = new(src)
	sneaky_beaky.Grant(src)
	return ..()

/mob/living/carbon/alien/humanoid/sentinel/create_internal_organs()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel
	internal_organs += new /obj/item/organ/internal/alien/acid
	internal_organs += new /obj/item/organ/internal/alien/neurotoxin
	..()
