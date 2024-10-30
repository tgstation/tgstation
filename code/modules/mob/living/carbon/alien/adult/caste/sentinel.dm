/mob/living/carbon/alien/adult/sentinel
	name = "alien sentinel"
	RU_NAMES_LIST_INIT("alien sentinel", "страж Чужих", "стража Чужих", "стражу Чужих", "стража Чужих", "стражем Чужих", "страже Чужих")
	caste = "s"
	maxHealth = 150
	health = 150
	icon_state = "aliens"
	alien_speed = 0.2

/mob/living/carbon/alien/adult/sentinel/Initialize(mapload)
	GRANT_ACTION(/datum/action/cooldown/mob_cooldown/sneak/alien)
	return ..()

/mob/living/carbon/alien/adult/sentinel/create_internal_organs()
	organs += new /obj/item/organ/alien/plasmavessel
	organs += new /obj/item/organ/alien/acid
	organs += new /obj/item/organ/alien/neurotoxin
	..()
