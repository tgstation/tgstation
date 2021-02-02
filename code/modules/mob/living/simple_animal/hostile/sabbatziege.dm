/mob/living/simple_animal/hostile/megafauna/sabbat
	name = "Sabbatziege"
	desc = "Looking at this hulking beast makes you feel more at ease. Almost too much at ease. Better keep a hold of yourself- Oh, no wait. That's just Zev."
	icon = 'icons/mob/sabbatziege.dmi'
	icon_state = "sabbat"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	AIStatus = AI_OFF
	maxHealth = 1000000
	health = 1000000
	pixel_y = -32
	pixel_x= -96
	speed = 5
	gender = MALE
	move_to_delay = 5
	dextrous = TRUE
	light_color = COLOR_WHITE
	light_range = 10
	ranged = TRUE
	held_items = list(null, null)
	weather_immunities = list("lava","ash")
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	movement_type = UNSTOPPABLE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("neutral","silicon","turret","sabbatziege")
	speak_chance = 50
	speak_emote = list("preaches")
	minbodytemp = 0
	maxbodytemp = INFINITY
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	attack_action_types = list(/datum/action/innate/megafauna_attack/blessing,
							   /datum/action/innate/megafauna_attack/summon)

/datum/action/innate/megafauna_attack/blessing
	name = "Blessing"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now blessing all around you.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/summon
	name = "Summon"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='colossus'>You are now summoning your apostles.</span>"
	chosen_attack_num = 2

/mob/living/simple_animal/hostile/megafauna/sabbat/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				blessing()
			if(2)
				summon_apostle1()
				summon_apostle2()
				summon_apostle3()
		return

/mob/living/simple_animal/hostile/megafauna/sabbat/proc/blessing()

/mob/living/simple_animal/hostile/megafauna/sabbat/proc/summon_apostle1()
	for(var/mob/living/L in get_hearers_in_view(7, src) - src)
		to_chat(L, "<span class='danger'>Sabbatziege summons his apostles!</span>")
	var/mob/living/simple_animal/hostile/largeapostle/tzaphkiel/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/sabbat/proc/summon_apostle2()
	var/mob/living/simple_animal/hostile/largeapostle/tzadkiel/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/sabbat/proc/summon_apostle3()
	var/mob/living/simple_animal/hostile/largeapostle/khamael/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction
