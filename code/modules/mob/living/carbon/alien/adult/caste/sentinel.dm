/mob/living/carbon/alien/adult/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 150
	health = 150
	icon_state = "aliens"

/mob/living/carbon/alien/adult/sentinel/Initialize(mapload)
	var/datum/action/cooldown/alien/sneak/sneaky_beaky = new(src)
	sneaky_beaky.Grant(src)
	return ..()

/mob/living/carbon/alien/adult/sentinel/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel
	organs += new /obj/item/organ/internal/alien/acid
	organs += new /obj/item/organ/internal/alien/neurotoxin
	..()
