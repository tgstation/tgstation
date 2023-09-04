/mob/living/simple_animal/crab/spycrab
	name = "spy crab"
	desc = "hon hon hon"
	icon = 'monkestation/icons/mob/simple/animals.dmi'
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"


/mob/living/simple_animal/crab/spycrab/Initialize(mapload)
	. = ..()
	var/random_icon = pick("crab_red","crab_blue")
	icon_state = random_icon
