//Kobolds are small, weak humanoids in lavaland. They are dextrous and typically prefer traps over grisly combat.
/mob/living/simple_animal/hostile/kobold
	name = "kobold"
	desc = "A tiny, scaled humanoid standing at around three feet tall."
	icon_state = "evilcrab" //Temporary until I can get actual sprites
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"

	speak_emote = list("hisses")
	languages_spoken = ASHEN
	languages_understood = ASHEN
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "hits"
	maxHealth = 50
	health = 50
	speed = 1
	status_flags = CANSTUN|CANWEAKEN|CANPARALYSE
	wander = FALSE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0) //Needs no oxygen but suffers from toxins
	faction = list("kobold")
	weather_immunities = list("ash")
	see_in_dark = 5
	see_invisible = SEE_INVISIBLE_MINIMUM
	dextrous = TRUE

	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 10
	environment_smash = 0
	attacktext = "claws"
	attack_sound = 'sound/weapons/slash.ogg'

	AIStatus = AI_OFF

/mob/living/simple_animal/hostile/kobold/New()
	create_reagents(100)
	..()

/mob/living/simple_animal/hostile/kobold/Life()
	..()
	/*AdjustStunned(-1)
	AdjustWeakened(-1)
	AdjustParalysed(-1)*/

/mob/living/simple_animal/hostile/kobold/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] <i>[src]</i>!\n"
	if(l_hand)
		msg += "It is holding \icon[l_hand][l_hand] in its left hand.\n"
	if(r_hand)
		msg += "It is holding \icon[r_hand][r_hand] in its right hand.\n"
	msg += "</span>"
	switch(health)
		if(1 to 25)
			msg += "<span class='boldwarning'>It is severely wounded!</span>\n"
		if(25 to 49)
			msg += "<span class='warning'>It is slightly wounded.</span>\n"
	if(stat)
		msg += "<span class='deadsay'>It is limp and unresponsive; there are no signs of life...</span>\n"
	msg += "<span class='info'>*---------*</span>"
	user << msg

/mob/living/simple_animal/hostile/kobold/can_throw()
	return dextrous
