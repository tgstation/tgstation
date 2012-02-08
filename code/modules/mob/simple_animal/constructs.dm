/mob/living/simple_animal/constructarmoured
	name = "Juggernaut"
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
	response_harm   = "punches the"
	melee_damage_lower = 15
	melee_damage_upper = 30
	attacktext = "smashes their armoured gauntlet into"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 3
	destroyer = 1
	relentless = 1
	a_intent = "harm"
	stop_automated_movement = 1

	Life()
		..()
		if(stat == 2)
			for(var/mob/M in viewers(src, null))
				if((M.client && !( M.blinded )))
					M.show_message("\red [src] collapses in a shattered heap ")
					ghostize(0)
			del src
			return

/mob/living/simple_animal/constructarmoured/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/storage/bible))
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			health -= 75
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] lets out a pained screech, its armoured skin fizzling and melting. ")
		else
			usr << "\red Your faith is not strong enough!"
	else
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
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
				if(prob(5))
					src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(tmob.relentless)
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



/mob/living/simple_animal/constructwraith
	name = "Wraith"
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

	Life()
		..()
		if(stat == 2)
			for(var/mob/M in viewers(src, null))
				if((M.client && !( M.blinded )))
					M.show_message("\red [src] collapses in a shattered heap ")
					ghostize(0)
			del src
			return


/mob/living/simple_animal/constructwraith/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/storage/bible))
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			health -= 75
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] lets out a pained screech, its armoured skin fizzling and melting. ")
		else
			usr << "\red Your faith is not strong enough!"

	else
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
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
				if(prob(50))
					src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
			if(tmob.relentless)
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
