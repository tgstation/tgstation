/mob/living/simple_animal/hostile/handofgod
	name = "Hand of God"
	desc = "A giant hand.  Smells like a great meal."
	icon = 'icons/mob/handofgod.dmi'
	icon_state = "handofgod"
	icon_living = "handofgod"
	icon_dead = "handofgod"
	turns_per_move = 5
	response_help_continuous = "rubs"
	response_help_simple = "rub"
	response_disarm_continuous = "nudges"
	response_disarm_simple = "nudge"
	speed = 0
	maxHealth = 300
	health = 300

	harm_intent_damage = 0  //Mere mortal hands can't damage the visage of a god
	obj_damage = 500  //He isn't fucking around
	melee_damage_lower = 1
	melee_damage_upper = 20  //He rolls the dice
	attack_verb_continuous = "subjugates"
	attack_verb_simple = "subjugate"
	attack_sound = 'sound/magic/wandodeath.ogg'
	speak_emote = list("deliciously declares")

	//Hamburger helper helped her hamburger help her make a great meal
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("agoodmeal")
	movement_type = FLYING
	pressure_resistance = 200
	del_on_death = TRUE
	
	var/peopleFed = 0
	
/mob/living/simple_animal/hostile/handofgod/Initialize()
	. = ..()
	var/datum/action/innate/handofgod/feed/F = new
	F.Grant(src)
	
/datum/action/innate/handofgod
	background_icon_state = "bg_alien"
	
/datum/action/innate/handofgod/feed
	name = "Feed"

/datum/action/innate/handofgod/feed/Activate()
	var/mob/living/simple_animal/hostile/handofgod/H = owner
	H.Feed()
	
/mob/living/simple_animal/hostile/handofgod/verb/Feed()
	set category = "Hand of God"
	set desc = "This will let you feed anyone nearby you.  They want your deliciousness"

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(Adjacent(C) && C.stat != DEAD)
			choices += C

	var/mob/living/M = input(src,"Who do you wish to feed?") in null|sortNames(choices)
	if(M != null && !buckled)
		GiveFood(M)

mob/living/simple_animal/hostile/handofgod/proc/GiveFood(mob/living/carbon/foodfellow)
	if(foodfellow.buckle_mob(src, force=TRUE))
		//Stage 1: attach
		layer = foodfellow.layer+0.01 //appear above the target mob
		foodfellow.visible_message("<span class='danger'>[name] jumps on [foodfellow] and positions the bottom of its glove above [foodfellow]'s mouth!</span>", \
			"<span class='userdanger'>[name] has latched onto you, and is positioning its glove hole above your face!</span>")
		foodfellow.Paralyze(50)
		sleep(50)
	
		//Stage 2: Extend the proboscis
		if(stat == DEAD)
			if(buckled)
				layer = initial(layer)
				buckled.unbuckle_mob(src,force=TRUE)
			return
		foodfellow.visible_message("<span class='danger'>[name] begins extending his proboscis down [foodfellow]'s throat!</span>", \
			"<span class='userdanger'>[name] begins to extend his proboscis down your throat!</span>")
		foodfellow.Paralyze(50)
		sleep(50)

		//Stage 3: Meat Injection
		if(stat == DEAD)
			if(buckled)
				layer = initial(layer)
				buckled.unbuckle_mob(src,force=TRUE)
			return
		foodfellow.visible_message("<span class='danger'>[name] begins pumping delicious flavored meat down [foodfellow]'s throat!</span>", \
			"<span class='userdanger'>[name] begins to pump delicious flavored meat down your throat!</span>")
		foodfellow.Paralyze(50)
		sleep(50)
	
		//Stage 4: Bloat
		if(stat == DEAD)
			if(buckled)
				layer = initial(layer)
				buckled.unbuckle_mob(src,force=TRUE)
			return
		foodfellow.visible_message("<span class='danger'>[foodfellow]'s stomach seems swollen!  They can't handle all the delicious flavors!</span>", \
			"<span class='userdanger'>You feel too full!  Your stomach can't handle all the delicious flavors!</span>")
		foodfellow.Paralyze(50)
		sleep(50)

		//Stage 5: Flavortown
		if(stat == DEAD)
			if(buckled)
				layer = initial(layer)
				buckled.unbuckle_mob(src,force=TRUE)
			return

		ADD_TRAIT(foodfellow, TRAIT_DISFIGURED, TRAIT_GENERIC)
		foodfellow.inflate_gib()
		peopleFed++
		return

	to_chat(src, "<span class='warning'><i>I have failed to feed!</i></span>")
