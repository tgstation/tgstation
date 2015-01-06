/mob/living/simple_animal/slime
	name = "pet slime"
	desc = "A lovable, domesticated slime."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	speak_emote = list("chirps")
	health = 100
	maxHealth = 100
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	ventcrawler = 2
	var/colour = "grey"

/mob/living/simple_animal/slime/adult
	health = 200
	maxHealth = 200
	icon_state = "grey adult slime"
	icon_living = "grey adult slime"

/mob/living/simple_animal/slime/adult/New()
	..()
	overlays += "aslime-:33"

/mob/living/simple_animal/slime/adult/Die()
	for(var/i = 0, i<=1, i++)
		var/mob/living/simple_animal/slime/S1 = new /mob/living/simple_animal/slime (src.loc)
		S1.icon_state = "[colour] baby slime"
		S1.icon_living = "[colour] baby slime"
		S1.icon_dead = "[colour] baby slime dead"
		S1.colour = "[colour]"
	qdel(src)
