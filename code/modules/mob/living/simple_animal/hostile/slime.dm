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
	can_butcher = 0

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
	del(src)

/mob/living/simple_animal/hostile/slime/Life()
	if(timestopped) return 0 //under effects of time magick
	..()
	if(bodytemperature < 273.15)
		calm()

/mob/living/simple_animal/hostile/slime/proc/calm()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/simple_animal/hostile/slime/proc/calm() called tick#: [world.time]")
	var/calmed_type = /mob/living/carbon/slime
	switch(colour)
		if("grey")
			calmed_type =  /mob/living/carbon/slime
		if("metal")
			calmed_type =  /mob/living/carbon/slime/metal
		if("orange")
			calmed_type =  /mob/living/carbon/slime/orange
		if("purple")
			calmed_type =  /mob/living/carbon/slime/purple
		if("blue")
			calmed_type =  /mob/living/carbon/slime/blue
		if("dark purple")
			calmed_type =  /mob/living/carbon/slime/darkpurple
		if("dark blue")
			calmed_type =  /mob/living/carbon/slime/darkblue
		if("yellow")
			calmed_type =  /mob/living/carbon/slime/yellow
		if("silver")
			calmed_type =  /mob/living/carbon/slime/silver
		if("gold")
			calmed_type =  /mob/living/carbon/slime/gold
		if("pink")
			calmed_type =  /mob/living/carbon/slime/pink
		if("red")
			calmed_type =  /mob/living/carbon/slime/red
		if("green")
			calmed_type =  /mob/living/carbon/slime/green
		if("light pink")
			calmed_type =  /mob/living/carbon/slime/lightpink
		if("oil")
			calmed_type =  /mob/living/carbon/slime/oil
		if("black")
			calmed_type =  /mob/living/carbon/slime/black
		if("adamantine")
			calmed_type =  /mob/living/carbon/slime/adamantine
		if("bluespace")
			calmed_type =  /mob/living/carbon/slime/bluespace
		if("pyrite")
			calmed_type =  /mob/living/carbon/slime/pyrite
		if("cerulean")
			calmed_type =  /mob/living/carbon/slime/cerulean
		if("sepia")
			calmed_type =  /mob/living/carbon/slime/sepia

	var/mob/living/carbon/slime/calmed = new calmed_type(loc)
	for(var/mob/M in friends)
		calmed.Friends += M

	del(src)

/mob/living/simple_animal/hostile/slime/adult/calm()
	var/calmed_type = /mob/living/carbon/slime
	switch(colour)
		if("grey")
			calmed_type =  /mob/living/carbon/slime/adult
		if("metal")
			calmed_type =  /mob/living/carbon/slime/adult/metal
		if("orange")
			calmed_type =  /mob/living/carbon/slime/adult/orange
		if("purple")
			calmed_type =  /mob/living/carbon/slime/adult/purple
		if("blue")
			calmed_type =  /mob/living/carbon/slime/adult/blue
		if("dark purple")
			calmed_type =  /mob/living/carbon/slime/adult/darkpurple
		if("dark blue")
			calmed_type =  /mob/living/carbon/slime/adult/darkblue
		if("yellow")
			calmed_type =  /mob/living/carbon/slime/adult/yellow
		if("silver")
			calmed_type =  /mob/living/carbon/slime/adult/silver
		if("gold")
			calmed_type =  /mob/living/carbon/slime/adult/gold
		if("pink")
			calmed_type =  /mob/living/carbon/slime/adult/pink
		if("red")
			calmed_type =  /mob/living/carbon/slime/adult/red
		if("green")
			calmed_type =  /mob/living/carbon/slime/adult/green
		if("light pink")
			calmed_type =  /mob/living/carbon/slime/adult/lightpink
		if("oil")
			calmed_type =  /mob/living/carbon/slime/adult/oil
		if("black")
			calmed_type =  /mob/living/carbon/slime/adult/black
		if("adamantine")
			calmed_type =  /mob/living/carbon/slime/adult/adamantine
		if("bluespace")
			calmed_type =  /mob/living/carbon/slime/adult/bluespace
		if("pyrite")
			calmed_type =  /mob/living/carbon/slime/adult/pyrite
		if("cerulean")
			calmed_type =  /mob/living/carbon/slime/adult/cerulean
		if("sepia")
			calmed_type =  /mob/living/carbon/slime/adult/sepia

	var/mob/living/carbon/slime/calmed = new calmed_type(loc)
	for(var/mob/M in friends)
		calmed.Friends += M

	del(src)