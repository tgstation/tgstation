//The base for clockwork mobs
/mob/living/simple_animal/hostile/clockwork
	faction = list("neutral", "ratvar")
	gender = NEUTER
	icon = 'icons/mob/clockwork_mobs.dmi'
	unique_name = 1
	minbodytemp = 0
	unsuitable_atmos_damage = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0) //Robotic
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	healable = FALSE
	del_on_death = TRUE
	speak_emote = list("clanks", "clinks", "clunks", "clangs")
	verb_ask = "requests"
	verb_exclaim = "proclaims"
	verb_whisper = "imparts"
	verb_yell = "harangues"
	initial_language_holder = /datum/language_holder/clockmob
	bubble_icon = "clock"
	light_color = "#E42742"
	death_sound = 'sound/magic/clockwork/anima_fragment_death.ogg'
	var/playstyle_string = "<span class='heavy_brass'>You are a bug, yell at whoever spawned you!</span>"

/mob/living/simple_animal/hostile/clockwork/get_spans()
	return ..() | SPAN_ROBOT

/mob/living/simple_animal/hostile/clockwork/Login()
	..()
	add_servant_of_ratvar(src, TRUE)
	to_chat(src, playstyle_string)

/mob/living/simple_animal/hostile/clockwork/ratvar_act()
	fully_heal(TRUE)

/mob/living/simple_animal/hostile/clockwork/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	return 0 //ouch, my metal-unlikely-to-be-damaged-by-electricity-body

/mob/living/simple_animal/hostile/clockwork/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_s = p_s()
	var/msg = "<span class='brass'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"
	msg += "[desc]\n"
	if(health < maxHealth)
		msg += "<span class='warning'>"
		if(health >= maxHealth/2)
			msg += "[t_He] look[t_s] slightly dented.\n"
		else
			msg += "<b>[t_He] look[t_s] severely dented!</b>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	to_chat(user, msg)
