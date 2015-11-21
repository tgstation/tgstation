/mob/living/simple_animal/hostile/slime
	name = "rabid slime"
	desc = "you won't be petting that one."
	speak_emote = list("angrily chirps")
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime eat"
	icon_living = "grey baby slime eat"
	icon_dead = "grey baby slime dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_damage_type = CLONE
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	attacktext = "glomps"
	attack_sound = 'sound/weapons/welderattack.ogg'
	faction = "slimesummon"
	speed = 4
	can_butcher = 0
	meat_type = null

	var/colour = "grey"

/mob/living/simple_animal/hostile/slime/New()
	..()
	overlays = 0
	overlays += "bloodlust"


/mob/living/simple_animal/hostile/slime/adult
	health = 200
	maxHealth = 200
	icon_state = "grey adult slime eat"
	icon_living = "grey adult slime eat"
	icon_dead = "grey baby slime dead"

/mob/living/simple_animal/hostile/slime/adult/New()
	..()
	overlays = 0
	overlays += "bloodlust-adult"


/mob/living/simple_animal/hostile/slime/adult/Die()
	for(var/i=0;i<2;i++)
		var/mob/living/simple_animal/hostile/slime/rabid = new /mob/living/simple_animal/hostile/slime (src.loc)
		rabid.icon_state = "[src.colour] baby slime eat"
		rabid.icon_living = "[src.colour] baby slime eat"
		rabid.icon_dead = "[src.colour] baby slime dead"
		rabid.colour = "[src.colour]"
		for(var/mob/M in friends)
			rabid.friends += M
	qdel(src)

/mob/living/simple_animal/hostile/slime/Life()
	if(timestopped) return 0 //under effects of time magick
	..()
	if(bodytemperature < 273.15)
		calm()


/mob/living/simple_animal/hostile/slime/MoveToTarget()
	..()
	if(target && target.Adjacent(src))
		forceMove(get_turf(target))

/mob/living/simple_animal/hostile/slime/AttackingTarget()
	forceMove(get_turf(target))
	..()

/mob/living/simple_animal/hostile/slime/proc/calm()
	var/calmed_type = /mob/living/carbon/slime
	if(colour != "grey")
		var/path_end = replacetext(colour, " ", "")
		calmed_type = text2path("/mob/living/carbon/slime/" + path_end)

	var/mob/living/carbon/slime/calmed = new calmed_type(loc)
	for(var/mob/M in friends)
		calmed.Friends += M

	qdel(src)

/mob/living/simple_animal/hostile/slime/adult/calm()
	var/calmed_type = /mob/living/carbon/slime/adult
	if(colour != "grey")
		var/path_end = replacetext(colour, " ", "")
		calmed_type = text2path("/mob/living/carbon/slime/adult/" + path_end)

	var/mob/living/carbon/slime/calmed = new calmed_type(loc)
	for(var/mob/M in friends)
		calmed.Friends += M

	qdel(src)
