//////////////////The Monster

/mob/living/simple_animal/imp
	name = "imp"
	real_name = "imp"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = 1
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	see_in_dark = 8
	var/boost = 0
	bloodcrawl = BLOODCRAWL_EAT
	see_invisible = SEE_INVISIBLE_MINIMUM
	var/list/consumed_mobs = list()
	var/playstyle_string = "<B><font size=3 color='red'>You are an imp,</font> a mischevious creature from hell. You are the lowest rank on the hellish totem pole  \
							Though you are not obligated to help, perhaps by aiding a higher ranking devil, you might just get a promotion.  However, you are incapable	\
							of intentionally harming a fellow devil.</B>"

/mob/living/simple_animal/imp/Initialize()
	..()
	boost = world.time + 30

/mob/living/simple_animal/imp/Life()
	..()
	if(boost<world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/imp/death()
	..(1)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>[src] screams in agony as it sublimates into a sulfurous smoke.</span>")
	ghostize()
	qdel(src)
