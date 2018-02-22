/mob/living/simple_animal/hostile/grue
	name = "grue"
	desc = "grue vulgaris: a sinister, lurking presence in the dark places of the galaxy with insatiable appetite. Its appetite is only tempered by its fear of light."
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	icon_dead = "nothing"
	gender = NEUTER
	health = 500
	maxHealth = 500
	melee_damage_lower = 68
	melee_damage_upper = 83
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
	var/playstyle_string = "<span class='grue'>I am a grue! As a creature of pure evil, I cannot exist in the light. But by dwelling in and embracing the darkest dark, I have grown to be disgustingly strong, nigh unstoppable and able to sense when someone enters the dark without a light. </span><span class='gruehunt'>I must sate the hunger.</span>"
	var/datum/action/innate/grue/gruewalk/gruewalk

/mob/living/simple_animal/hostile/grue/Login()
	. = ..()
	to_chat(usr, playstyle_string)

/mob/living/simple_animal/hostile/grue/Initialize()
	. = ..()
	mob_spell_list += new /obj/effect/proc_holder/spell/targeted/night_vision/grue(src)
	gruewalk = new
	gruewalk.Grant(src)

/mob/living/simple_animal/hostile/grue/Destroy()
	QDEL_NULL(gruewalk)
	return ..()

/mob/living/simple_animal/hostile/grue/compose_message(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mode)
	return "<span class='grue'>[..()]</span>"

/mob/living/simple_animal/hostile/grue/Life()
	. = ..()
	check_light_level()

/mob/living/simple_animal/hostile/grue/Move()
	. = ..()
	check_light_level()

/mob/living/simple_animal/hostile/grue/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.1 && !istype(src.loc, /obj/effect/dummy/grue))
		to_chat(src, "<span class='gruehunt'><b>THE LIGHT!</b></span>")
		playsound(get_turf(src), 'sound/creatures/grue_screech.ogg', 50, 1, -1)
		gruewalk.Activate()

/obj/effect/proc_holder/spell/targeted/night_vision/grue
	charge_max = 0
	panel = "Grue"
	message = "<span class='grue'>I toggle my night vision.</span>"
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "gruesight1"
	action_background_icon_state = "bg_shadow"

/obj/effect/proc_holder/spell/targeted/night_vision/grue/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		switch(target.lighting_alpha)
			if (LIGHTING_PLANE_ALPHA_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				action_icon_state = "gruesight2"
				name = "Toggle Nightvision \[More]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
				action_icon_state = "gruesight3"
				name = "Toggle Nightvision \[Full]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
				action_icon_state = "gruesight4"
				name = "Toggle Nightvision \[OFF]"
			else
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
				action_icon_state = "gruesight1"
				name = "Toggle Nightvision \[ON]"
		target.update_sight()

/datum/action/innate/grue
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_shadow"

/datum/action/innate/grue/gruewalk
	name = "Grue Walk"
	desc = "Grants unlimited jaunting, but you may only corporealize in the darkness."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "gruewalk"

/datum/action/innate/grue/gruewalk/Activate()
	var/L = owner.loc
	var/turf/T = get_turf(owner)
	var/light_amount = T.get_lumcount()
	if(istype(owner.loc, /obj/effect/dummy/grue) && light_amount < 0.2)
		var/obj/effect/dummy/grue/G = L
		G.end_jaunt()
		to_chat(owner, "<span class='grue'>I'm now out of hiding...</span>")
		return
	if(!istype(owner, /mob/living/simple_animal/hostile/grue))
		return //you've broken everything, fuck you
	var/mob/living/simple_animal/hostile/grue/grue = owner
	grue.SetStun(0, FALSE)
	grue.SetKnockdown(0, FALSE)
	grue.setStaminaLoss(0, 0)
	var/obj/effect/dummy/grue/S2 = new(get_turf(grue.loc))
	grue.forceMove(S2)
	S2.jaunter = grue

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