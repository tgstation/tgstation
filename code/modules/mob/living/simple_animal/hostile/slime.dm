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
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	attacktext = "glomps"
	attack_sound = 'sound/weapons/welderattack.ogg'
	faction = "slimesummon"
	speed = 4
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
	var/mob/living/simple_animal/hostile/slime/S1 = new /mob/living/simple_animal/hostile/slime (src.loc)
	S1.icon_state = "[src.colour] baby slime eat"
	S1.icon_living = "[src.colour] baby slime eat"
	S1.icon_dead = "[src.colour] baby slime dead"
	S1.colour = "[src.colour]"
	var/mob/living/simple_animal/hostile/slime/S2 = new /mob/living/simple_animal/hostile/slime (src.loc)
	S2.icon_state = "[src.colour] baby slime eat"
	S2.icon_living = "[src.colour] baby slime eat"
	S2.icon_dead = "[src.colour] baby slime dead"
	S2.colour = "[src.colour]"
	del(src)

/mob/living/simple_animal/hostile/slime/Life()
	..()
	if(bodytemperature < 273.15)
		calm()

/mob/living/simple_animal/hostile/slime/proc/calm()
	switch(colour)
		if("grey")
			new /mob/living/carbon/slime(loc)
		if("metal")
			new /mob/living/carbon/slime/metal(loc)
		if("orange")
			new /mob/living/carbon/slime/orange(loc)
		if("purple")
			new /mob/living/carbon/slime/purple(loc)
		if("blue")
			new /mob/living/carbon/slime/blue(loc)
		if("dark purple")
			new /mob/living/carbon/slime/darkpurple(loc)
		if("dark blue")
			new /mob/living/carbon/slime/darkblue(loc)
		if("yellow")
			new /mob/living/carbon/slime/yellow(loc)
		if("silver")
			new /mob/living/carbon/slime/silver(loc)
		if("gold")
			new /mob/living/carbon/slime/gold(loc)
		if("pink")
			new /mob/living/carbon/slime/pink(loc)
		if("red")
			new /mob/living/carbon/slime/red(loc)
		if("green")
			new /mob/living/carbon/slime/green(loc)
		if("light pink")
			new /mob/living/carbon/slime/lightpink(loc)
		if("oil")
			new /mob/living/carbon/slime/oil(loc)
		if("black")
			new /mob/living/carbon/slime/black(loc)
		if("adamantine")
			new /mob/living/carbon/slime/adamantine(loc)
		if("bluespace")
			new /mob/living/carbon/slime/bluespace(loc)
		if("pyrite")
			new /mob/living/carbon/slime/pyrite(loc)
		if("cerulean")
			new /mob/living/carbon/slime/cerulean(loc)
		if("sepia")
			new /mob/living/carbon/slime/sepia(loc)
	del(src)

/mob/living/simple_animal/hostile/slime/adult/calm()
	switch(colour)
		if("grey")
			new /mob/living/carbon/slime/adult(loc)
		if("metal")
			new /mob/living/carbon/slime/adult/metal(loc)
		if("orange")
			new /mob/living/carbon/slime/adult/orange(loc)
		if("purple")
			new /mob/living/carbon/slime/adult/purple(loc)
		if("blue")
			new /mob/living/carbon/slime/adult/blue(loc)
		if("dark purple")
			new /mob/living/carbon/slime/adult/darkpurple(loc)
		if("dark blue")
			new /mob/living/carbon/slime/adult/darkblue(loc)
		if("yellow")
			new /mob/living/carbon/slime/adult/yellow(loc)
		if("silver")
			new /mob/living/carbon/slime/adult/silver(loc)
		if("gold")
			new /mob/living/carbon/slime/adult/gold(loc)
		if("pink")
			new /mob/living/carbon/slime/adult/pink(loc)
		if("red")
			new /mob/living/carbon/slime/adult/red(loc)
		if("green")
			new /mob/living/carbon/slime/adult/green(loc)
		if("light pink")
			new /mob/living/carbon/slime/adult/lightpink(loc)
		if("oil")
			new /mob/living/carbon/slime/adult/oil(loc)
		if("black")
			new /mob/living/carbon/slime/adult/black(loc)
		if("adamantine")
			new /mob/living/carbon/slime/adult/adamantine(loc)
		if("bluespace")
			new /mob/living/carbon/slime/adult/bluespace(loc)
		if("pyrite")
			new /mob/living/carbon/slime/adult/pyrite(loc)
		if("cerulean")
			new /mob/living/carbon/slime/adult/cerulean(loc)
		if("sepia")
			new /mob/living/carbon/slime/adult/sepia(loc)
	del(src)