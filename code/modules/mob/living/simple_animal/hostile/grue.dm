/mob/living/simple_animal/hostile/grue
	name = "grue"
	desc = "grue vulgaris: a sinister, lurking presence in the dark places of the galaxy with insatiable appetite. Its appetite is only tempered by its fear of light."
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	icon_dead = "nothing"
	gender = NEUTER
	health = 500
	maxHealth = 500
	melee_damage_lower = 60
	melee_damage_upper = 70
	speed = -1
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	obj_damage = 0//no apc cheesing mr grue!
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("gurgles", "slavers")
	ventcrawler = VENTCRAWLER_ALWAYS
	deathmessage = "retreats into the night with a wicked yowl!"
	del_on_death = 1
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	var/playstyle_string = "<span class='grue'>I am a grue! As a creature of pure evil, I cannot exist in the light. But by dwelling in and embracing the darkest dark, I have grown to be disgustingly strong, nigh unstoppable and able to sense when someone enters the dark without a light. </span><span class='gruehunt'>I must sate the hunger.</span>"
	var/datum/action/innate/grue/gruesight/gruesight
	var/datum/action/innate/grue/gruewalk/gruewalk

/mob/living/simple_animal/hostile/grue/Login()
	. = ..()
	to_chat(usr, playstyle_string)

/mob/living/simple_animal/hostile/grue/Initialize()
	. = ..()
	gruesight = new
	gruesight.Grant(src)
	gruewalk = new
	gruewalk.Grant(src)

/mob/living/simple_animal/hostile/grue/Destroy()
	QDEL_NULL(gruesight)
	QDEL_NULL(gruewalk)
	playsound(get_turf(src), 'sound/creatures/grue_screech.ogg', 50, 1, 0.5)
	return ..()

/mob/living/simple_animal/hostile/grue/compose_message(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mode)
	return "<span class='grue'>[..()]</span>"

/mob/living/simple_animal/hostile/grue/Life()
	. = ..()
	check_light_level()

/mob/living/simple_animal/hostile/grue/Move()
	. = ..()
	check_light_level()
	for(var/mob/living/M in range(7, src))
		if(istype(M, src)) //no spooking yourself
			return
		var/turf/T = get_turf(M)
		var/light_amount = T.get_lumcount()
		if(light_amount > 0.1)
			return
		M.apply_status_effect(STATUS_EFFECT_GRUE_IS_COMING)

/mob/living/simple_animal/hostile/grue/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.1 && !istype(src.loc, /obj/effect/dummy/grue))
		to_chat(src, "<span class='gruehunt'><b>THE LIGHT!</b></span>")
		playsound(get_turf(src), 'sound/creatures/grue_screech.ogg', 50, 1, -1)
		gruewalk.Activate()

/datum/action/innate/grue
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_shadow"

/datum/action/innate/grue/gruesight
	name = "Grue Sight"
	desc = "A grue who knows the light but does not know the darkness, is lost! A grue who knows the darkness but does not know the light is in great danger."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "gruesight1"

/datum/action/innate/grue/gruesight/Activate()
	switch(owner.lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			owner.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			button_icon_state = "gruesight2"
			name = "Grue Sight \[More]"
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			owner.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			button_icon_state = "gruesight3"
			name = "Grue Sight \[Full]"
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			owner.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			button_icon_state = "gruesight4"
			name = "Grue Sight \[OFF]"
		else
			owner.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			button_icon_state = "gruesight1"
			name = "Grue Sight \[ON]"
	owner.update_sight()

/datum/action/innate/grue/gruewalk
	name = "Grue Walk"
	desc = "Grants unlimited jaunting, but you may only corporealize in the darkness."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "gruewalk"

/datum/action/innate/grue/gruewalk/Activate()
	var/L = owner.loc
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	if(!istype(owner.loc, /obj/effect/dummy/grue))
		var/mob/living/simple_animal/hostile/grue/grue = owner
		grue.SetStun(0, FALSE)
		grue.SetKnockdown(0, FALSE)
		grue.setStaminaLoss(0, 0)
		var/obj/effect/dummy/grue/S2 = new(get_turf(grue.loc))
		grue.forceMove(S2)
		S2.jaunter = grue
	else //so we are dummy grue
		if(light_amount < 0.1)
			var/obj/effect/dummy/grue/G = L
			G.end_jaunt()
			to_chat(owner, "<span class='grue'>The hunt begins.</span>")
			return
		else
			to_chat(owner, "<span class='grue'>I can't do that, it's too bright!</span>")

/obj/effect/dummy/grue
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	var/mob/living/jaunter
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/grue/relaymove(mob/user, direction)
	var/turf/newLoc = get_step(src,direction)
	forceMove(newLoc)

/obj/effect/dummy/grue/proc/end_jaunt()
	jaunter.forceMove(get_turf(src))
	jaunter = null
	qdel(src)


/obj/effect/dummy/grue/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/grue/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/grue/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)

/obj/effect/dummy/grue/ex_act()
	return

/obj/effect/dummy/grue/bullet_act()
	return

/obj/effect/dummy/grue/singularity_act()
	return