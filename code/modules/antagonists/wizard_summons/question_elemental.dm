//////////////////The Monster?

/mob/living/simple_animal/question_elemental
	name = "question elemental?"
	real_name = "question elemental?"
	desc = "What the hell is that thing?"
	speak_emote = list("asks")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	mob_biotypes = list(MOB_SPIRIT)
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	var/feast_sound = 'sound/magic/demon_consume.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "discomposes"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	bloodcrawl = BLOODCRAWL_EAT
	del_on_death = 1

/mob/living/simple_animal/question_elemental/Login()
	..()
	to_chat(src, "<span class='big bold'>Did you know that you are a question elemental?</span>")
	to_chat(src, "<b>Have you finally been unleashed from your capture by those terrible wizards?</b>")
	to_chat(src, "<b>Are you free again to maim those who do not question the wonderful universe we exist in? Is it time for some revenge?</b>")
	to_chat(src, "<b>Could you be beyond the veil these mortals walk in? And are you aware that any time they say something that isn't a question you are able to enter their realm?</b>")
	to_chat(src, "<b>Wanna know the drawback? It seems staying in the mortal world saps your strength, so you will be using hit and run tactics... right?</b>")
	to_chat(src, "<b>I guess asking a question will let you leave the mortal world? Would dragging bodies into the veil when you leave heal you?</b>")

/mob/living/simple_animal/question_elemental/death(gibbed)
	say(pick("Why me?!", "How did this happen?!", "I think i'm unwinding?!", "Does this mean i'm dying?!"))
	..()

/mob/living/simple_animal/question_elemental/treat_message(message)
	message = ..(message)
	message = " [message] "
	//only questions allowed thanks
	message = replacetext(message,"... ","...? ")
	message = replacetext(message,"!! ","!? ")
	message = replacetext(message,"! ","!? ")
	message = replacetext(message,". ","? ")
	return trim(message)

/mob/living/simple_animal/question_elemental/phasein()
	. = ..()
	add_movespeed_modifier(MOVESPEED_ID_SLAUGHTER, update=TRUE, priority=100, multiplicative_slowdown=-1)
	addtimer(CALLBACK(src, .proc/remove_movespeed_modifier, MOVESPEED_ID_SLAUGHTER, TRUE), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
