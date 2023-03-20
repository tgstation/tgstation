/mob/living/simple_animal/hostile/crawling_shadows
	name = "crawling shadows"
	desc = "A formless mass of blackness with two huge, clawed hands and piercing white eyes."
	icon = 'icons/effects/effects.dmi' //Placeholder sprite
	icon_state = "blank_dspawn"
	icon_living = "blank_dspawn"
	response_help_continuous = "backs away from"
	response_help_simple = "backs away from"
	response_disarm_continuous = "shoves away"
	response_disarm_simple = "shove away"
	response_harm_continuous = "flails at"
	response_harm_simple = "flail at"
	speed = 0
	maxHealth = 125
	health = 125

	lighting_cutoff_red = 20
	lighting_cutoff_green = 10
	lighting_cutoff_blue = 40

	sight = SEE_MOBS

	harm_intent_damage = 5
	obj_damage = 50
	melee_damage_lower = 5 //it has a built in stun if you want to kill someone kill them like a man
	melee_damage_upper = 5
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("whispers")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

	movement_type = FLYING
	pressure_resistance = INFINITY
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	gold_core_spawnable = FALSE

	del_on_death = TRUE

	var/move_count = 0 //For spooky sound effects
	var/knocking_out = FALSE
	var/mob/living/darkspawn_mob

/mob/living/simple_animal/hostile/crawling_shadows/New()
	..()
	addtimer(CALLBACK(src, .proc/check_darkspawn), 1)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/crawling_shadows/Destroy()
	if(darkspawn_mob && mind)
		visible_message(span_warning("[src] transforms into a humanoid figure!"), span_warning("You return to your normal form."))
		playsound(src, 'massmeta/sounds/magic/devour_will_end.ogg', 50, 1)
		if(mind)
			mind.transfer_to(darkspawn_mob)
		darkspawn_mob.forceMove(get_turf(src))
		darkspawn_mob.status_flags &= ~GODMODE
	return ..()

/mob/living/simple_animal/hostile/crawling_shadows/Move()
	move_count++
	if(move_count >= 5)
		playsound(src, "crawling_shadows_walk", 25, 0)
		move_count = 0
	..()

/mob/living/simple_animal/hostile/crawling_shadows/Life()
	..()
	var/turf/T = get_turf(src)
	var/lums = T.get_lumcount()
	if(lums < DARKSPAWN_BRIGHT_LIGHT)
		invisibility = INVISIBILITY_OBSERVER //Invisible in complete darkness
		speed = -1 //Faster, too
		alpha = 255
	else
		invisibility = initial(invisibility)
		speed = 0
		alpha = min(lums * 60, 255) //Slowly becomes more visible in brighter light

/mob/living/simple_animal/hostile/crawling_shadows/death(gibbed)
	if(darkspawn_mob)
		mind.transfer_to(darkspawn_mob)
	..(gibbed)

/mob/living/simple_animal/hostile/crawling_shadows/proc/check_darkspawn()
	if(!darkspawn_mob)
		qdel(src)
		return
	darkspawn_mob.forceMove(src)
	darkspawn_mob.status_flags |= GODMODE
	darkspawn_mob.mind.transfer_to(src)
	to_chat(src, span_warning("This will last for around a minute."))
	var/datum/action/innate/darkspawn/end_shadows/E = new
	E.Grant(src)
	QDEL_IN(src, 600)

/mob/living/simple_animal/hostile/crawling_shadows/AttackingTarget()
	if(ishuman(target) && !knocking_out)
		var/mob/living/carbon/human/H = target
		if(H.stat)
			return ..()
		knocking_out = TRUE
		visible_message(span_warning("[src] pick up [H] and dangle \him in the air!"), span_notice("You pluck [H] from the ground..."))
		to_chat(H, span_userdanger("[src] grab you and dangle you in the air!"))
		H.Stun(30)
		H.pixel_y += 4
		if(!do_after(src, 1 SECONDS, target))
			H.pixel_y -= 4
			knocking_out = FALSE
			return
		visible_message(span_warning("[src] gently press a hand against [H]'s face, and \he falls limp..."), span_notice("You quietly incapacitate [H]."))
		H.pixel_y -= 4
		to_chat(H, span_userdanger("[src] press a hand to your face, and docility comes over you..."))
		H.Paralyze(60)
		knocking_out = FALSE
		return TRUE
	else if(istype(target, /obj/machinery/door))
		forceMove(get_turf(target))
		visible_message(span_warning("Shadows creep through [target]..."), span_notice("You slip through [target]."))
		return
	..()


/datum/action/innate/darkspawn/end_shadows
	name = "End Crawling Shadows"
	id = "end_shadows"
	desc = "Reverts you to your humanoid form."
	button_icon_state = "crawling_shadows"
	blacklisted = TRUE

/datum/action/innate/darkspawn/end_shadows/Activate()
	qdel(owner) //edgi
	qdel(src)

/datum/action/innate/darkspawn/end_shadows/IsAvailable()
	if(istype(owner, /mob/living/simple_animal/hostile/crawling_shadows))
		return TRUE
	return FALSE
