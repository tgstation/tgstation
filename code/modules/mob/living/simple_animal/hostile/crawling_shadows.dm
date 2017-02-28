/mob/living/simple_animal/hostile/crawling_shadows
	name = "crawling shadows"
	desc = "A formless mass of blackness with two huge, clawed hands and piercing white eyes."
	icon = 'icons/effects/effects.dmi' //Placeholder sprite
	icon_state = "blank"
	icon_living = "blank"
	response_help = "backs away from"
	response_disarm = "shoves away"
	response_harm = "flails at"
	speed = 2
	ventcrawler = 1
	maxHealth = 125
	health = 125

	harm_intent_damage = 5
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "claws"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("whispers")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY

	faction = list("umbrage")
	movement_type = FLYING
	pressure_resistance = INFINITY
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	gold_core_spawnable = FALSE

	del_on_death = TRUE
	deathmessage = "tremble, break form, and disperse!"
	death_sound = 'sound/magic/devour_will_victim.ogg'

	var/move_count = 0 //For spooky sound effects
	var/knocking_out = FALSE
	var/mob/living/umbrage_mob

/mob/living/simple_animal/hostile/crawling_shadows/New()
	..()
	addtimer(CALLBACK(src, .proc/check_umbrage), 1)

/mob/living/simple_animal/hostile/crawling_shadows/Destroy()
	if(umbrage_mob && mind)
		visible_message("<span class='warning'>[src] transforms into a humanoid figure!</span>", "<span class='warning'>You return to your normal form.</span>")
		playsound(src, 'sound/magic/devour_will_end.ogg', 50, 1)
		if(mind)
			mind.transfer_to(umbrage_mob)
		umbrage_mob.forceMove(get_turf(src))
		umbrage_mob.status_flags &= ~GODMODE
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
	if(lums < 2)
		invisibility = INVISIBILITY_OBSERVER //Invisible in complete darkness
		speed = 1 //Faster, too
		alpha = 255
	else
		invisibility = initial(invisibility)
		speed = 2
		alpha = min(lums * 60, 255) //Slowly becomes more visible in brighter light

/mob/living/simple_animal/hostile/crawling_shadows/death(gibbed)
	if(umbrage_mob)
		mind.transfer_to(umbrage_mob)
	..(gibbed)

/mob/living/simple_animal/hostile/crawling_shadows/proc/check_umbrage()
	if(!umbrage_mob && !admin_spawned)
		qdel(src)
		return
	umbrage_mob.forceMove(src)
	umbrage_mob.status_flags |= GODMODE
	umbrage_mob.mind.transfer_to(src)
	src << "<span class='warning'>This will last for around a minute.</span>"
	QDEL_IN(src, 600)

/mob/living/simple_animal/hostile/crawling_shadows/AttackingTarget()
	if(ishuman(target) && !knocking_out)
		var/mob/living/carbon/human/H = target
		if(H.stat)
			return ..()
		knocking_out = TRUE
		visible_message("<span class='warning'>[src] pick up [H] and dangle \him in the air!</span>", "<span class='notice'>You pluck [H] from the ground...</span>")
		H << "<span class='userdanger'>[src] grab you and dangle you in the air!</span>"
		H.Stun(3)
		H.pixel_y += 4
		if(!do_after(src, 10, target = target))
			H.pixel_y -= 4
			knocking_out = FALSE
			return
		visible_message("<span class='warning'>[src] gently press a hand against [H]'s face, and \he falls limp...</span>", "<span class='notice'>You quietly incapacitate [H].</span>")
		H.pixel_y -= 4
		H << "<span class='userdanger'>[src] press a hand to your face, and docility comes over you...</span>"
		H.Paralyse(20)
		knocking_out = FALSE
		return 1
	else if(istype(target, /obj/machinery/door))
		forceMove(get_turf(target))
		visible_message("<span class='warning'>Shadows creep through [target]...</span>", "<span class='notice'>You slip through [target].</span>")
		return
	..()
