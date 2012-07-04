
/////////////////Juggernaut///////////////

/mob/living/simple_animal/constructarmoured
	name = "Juggernaut"
	real_name = "Juggernaut"
	original_name = "Juggernaut"
	desc = "A possessed suit of armour driven by the will of the restless dead"
	icon = 'mob.dmi'
	icon_state = "armour"
	icon_living = "armour"
	icon_dead = "shade_dead"
	maxHealth = 250
	health = 250
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "harmlessly punches the"
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armoured gauntlet into"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 3
	wall_smash = 1
	nopush = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPARALYSE


	Life()
		..()
		if(stat == 2)
			new /obj/item/weapon/ectoplasm (src.loc)
			for(var/mob/M in viewers(src, null))
				if((M.client && !( M.blinded )))
					M.show_message("\red [src] collapses in a shattered heap ")
					ghostize(0)
			del src
			return

/mob/living/simple_animal/constructarmoured/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		if(O.force >= 11)
			health -= O.force
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b The [O] bounces harmlessly off of [src]. ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with the [O]. ")


/mob/living/simple_animal/constructarmoured/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(5))
					src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(tmob.nopush)
				now_pushing = 0
				return

			tmob.LAssailant = src
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return


/mob/living/simple_animal/constructarmoured/attack_animal(mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/constructbuilder))
		health += 10
		M.emote("mends some of \the <EM>[src]'s</EM> wounds")
	else
		if(M.melee_damage_upper <= 0)
			M.emote("[M.friendly] \the <EM>[src]</EM>")
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			health -= damage


/mob/living/simple_animal/constructarmoured/examine()
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/constructarmoured/proc/mind_initialize(mob/G)
	mind = new
	mind.current = src
	mind.assigned_role = "Juggernaut"
	mind.key = G.key

////////////////////////Wraith/////////////////////////////////////////////



/mob/living/simple_animal/constructwraith
	name = "Wraith"
	real_name = "Wraith"
	original_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit"
	icon = 'mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	icon_dead = "shade_dead"
	maxHealth = 75
	health = 75
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches the"
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = -1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPARALYSE
	see_in_dark = 7

	Life()
		..()
		if(stat == 2)
			new /obj/item/weapon/ectoplasm (src.loc)
			for(var/mob/M in viewers(src, null))
				if((M.client && !( M.blinded )))
					M.show_message("\red [src] collapses in a shattered heap ")
					ghostize(0)
			del src
			return


/mob/living/simple_animal/constructwraith/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		health -= O.force
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with the [O]. ")

/mob/living/simple_animal/constructwraith/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (FAT in tmob.mutations))
				if(prob(50))
					src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(tmob.nopush)
				now_pushing = 0
				return

			tmob.LAssailant = src
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/simple_animal/constructwraith/attack_animal(mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/constructbuilder))
		health += 10
		M.emote("mends some of \the <EM>[src]'s</EM> wounds")
	else
		if(M.melee_damage_upper <= 0)
			M.emote("[M.friendly] \the <EM>[src]</EM>")
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			health -= damage



/mob/living/simple_animal/constructwraith/examine()
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/constructwraith/proc/mind_initialize(mob/G)
	mind = new
	mind.current = src
	mind.assigned_role = "Wraith"
	mind.key = G.key

/////////////////////////////Artificer/////////////////////////

/mob/living/simple_animal/constructbuilder
	name = "Artificer"
	real_name = "Artificer"
	original_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining The Cult of Nar-Sie's armies"
	icon = 'mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "viciously beats"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 0
	wall_smash = 1
	nopush = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPARALYSE

	Life()
		..()
		if(stat == 2)
			new /obj/item/weapon/ectoplasm (src.loc)
			for(var/mob/M in viewers(src, null))
				if((M.client && !( M.blinded )))
					M.show_message("\red [src] collapses in a shattered heap ")
					ghostize(0)
			del src
			return

/mob/living/simple_animal/constructbuilder/attack_animal(mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/constructbuilder))
		health += 5
		M.emote("mends some of \the <EM>[src]'s</EM> wounds")
	else
		if(M.melee_damage_upper <= 0)
			M.emote("[M.friendly] \the <EM>[src]</EM>")
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			health -= damage

/mob/living/simple_animal/constructbuilder/examine()
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/constructbuilder/proc/mind_initialize(mob/G)
	mind = new
	mind.current = src
	mind.assigned_role = "Artificer"
	mind.key = G.key