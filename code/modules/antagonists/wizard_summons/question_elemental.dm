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
	var/phased

/mob/living/simple_animal/question_elemental/Login()
	..()
	to_chat(src, "<span class='big bold'>Did you know that you are a question elemental?</span>")
	to_chat(src, "<b>Have you finally been unleashed from your capture by those terrible wizards?</b>")
	to_chat(src, "<b>Are you free again to maim those who do not question the wonderful universe we exist in? Is it time for some revenge?</b>")
	to_chat(src, "<b>Could you be beyond the veil these mortals walk in? And are you aware that any time they say something that isn't a question you are able to enter their realm?</b>")
	to_chat(src, "<b>Wanna know the drawback? It seems staying in the mortal world saps your strength, so you will be using hit and run tactics... right?</b>")
	to_chat(src, "<b>I guess asking a question will let you leave the mortal world? Would dragging bodies into the veil when you leave heal you?</b>")

/mob/living/simple_animal/question_elemental/death(gibbed)
	say(pick("Why me?!", "How did this happen?!", "I'm unwinding?!", "Does this mean i'm dying?!"))
	..()

/mob/living/simple_animal/question_elemental/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(!phased)//every message will be treated as a question, so we don't need to check again
		phaseout()

/mob/living/simple_animal/question_elemental/treat_message(message)
	message = ..(message)
	//how could a question elemental say something that isn't a question? Does that make any sort of sense to you?
	var/regex/reg = regex("?")
	if(!findtext(copytext(message, -1), stun_words))//the last character must be a question mark
		to_chat(src, "<span class='warning'>Are you sure that's a question?</span>")
		return
	return message

/mob/living/simple_animal/question_elemental/phasein(turf/T)
	if(src.notransform)
		to_chat(src, "<span class='warning'>Are you sure you're done feasting on your last target?</span>")
		return 0
	T.visible_message("<span class='warning'>Is [T] shimmering..?</span>")
	if(!do_after(src, 20, target = T))
		return
	if(!T)
		return
	forceMove(T)
	src.client.eye = src
	src.visible_message("<span class='warning'><B>Do I see [src] rising out of [T]!?</B></span>")
	exit_blood_effect()
	qdel(src.holder)
	src.holder = null
	add_movespeed_modifier(MOVESPEED_ID_SLAUGHTER, update=TRUE, priority=100, multiplicative_slowdown=-1)
	addtimer(CALLBACK(src, .proc/remove_movespeed_modifier, MOVESPEED_ID_SLAUGHTER, TRUE), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	return 1

/mob/living/simple_animal/question_elemental/exit_blood_effect()
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 50, 1, -1)
	var/newcolor = rgb(10, 10, 186)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	addtimer(CALLBACK(src, /atom/.proc/remove_atom_colour, TEMPORARY_COLOUR_PRIORITY, newcolor), 6 SECONDS)

/mob/living/simple_animal/question_elemental/phaseout()
	src.notransform = TRUE
	spawn(0)
		bloodpool_sink()
		notransform = FALSE
	return 1

/mob/living/simple_animal/question_elemental/bloodpool_sink()
	var/turf/mobloc = get_turf(src.loc)

	src.visible_message("<span class='warning'>Did [src] just sink into [mobloc]!?</span>")
	playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 50, 1, -1)
	// Extinguish, unbuckle, stop being pulled, set our location into the
	// dummy object
	var/obj/effect/dummy/phased_mob/question/holder = new /obj/effect/dummy/phased_mob/question(mobloc)
	src.ExtinguishMob()

	// Keep a reference to whatever we're pulling, because forceMove()
	// makes us stop pulling
	var/pullee = src.pulling

	src.holder = holder
	src.forceMove(holder)

	// if we're not pulling anyone, or we can't eat anyone
	if(!pullee || src.bloodcrawl != BLOODCRAWL_EAT)
		return

	// if the thing we're pulling isn't alive
	if (!isliving(pullee))
		return

	var/mob/living/victim = pullee
	var/kidnapped = FALSE

	if(victim.stat == CONSCIOUS)
		src.visible_message("<span class='warning'>[victim] hits the floor, and yet is not dragged in?</span>", null, "<span class='notice'>You hear struggling?</span>")
	else
		victim.forceMove(src)
		victim.emote("scream")
		src.visible_message("<span class='warning'><b>Did [src] just drag [victim] into the floor!?</b></span>")
		kidnapped = TRUE

	if(kidnapped)
		if(!bloodcrawl_consume(victim))
			to_chat(src, "<span class='danger'>Where did your meal go!?</span>")
	return 1

/obj/effect/proc_holder/spell/targeted/questionwalk
	name = "Questionable Advance?"
	desc = "Since when did this grant unlimited movement? Why can you only exit when someone doesn't ask a question? You can enter by asking a question?"
	charge_max = 0
	clothes_req = FALSE
	antimagic_allowed = TRUE
	phase_allowed = TRUE
	selection_type = "range"
	range = -1
	include_user = TRUE
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	action_background_icon_state = "bg_alien"
	var/ready_to_emerge = FALSE

/obj/effect/proc_holder/spell/targeted/questionwalk/cast(list/targets,mob/living/user = usr)
	if(istype(user.loc, /obj/effect/dummy/phased_mob/question))
		to_chat(user, "<span class='warning'>Have you asked a question to go back to questionwalking yet?</span>")
		return
	else
		if(ready_to_emerge)
			user.phasein(get_turf(user))
		else
			to_chat(user, "<span class='warning'>Are you sure someone has asked a question in the last 5 seconds?</span>")

/obj/effect/dummy/phased_mob/question
	name = "anomaly?"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = TRUE
	var/mob/living/jaunter
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/phased_mob/question/relaymove(mob/user, direction)
	var/turf/newLoc = get_step(src,direction)
	forceMove(newLoc)

/obj/effect/dummy/phased_mob/question/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/question/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/phased_mob/question/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)

/obj/effect/dummy/phased_mob/question/ex_act()
	return

/obj/effect/dummy/phased_mob/question/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/question/singularity_act()
	return

