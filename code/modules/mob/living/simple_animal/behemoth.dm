/mob/living/simple_animal/constructbehemoth
	name = "Behemoth"
	real_name = "Behemoth"
	original_name = "Behemoth"
	desc = "The pinnacle of occult technology, Behemoths are the ultimate weapon in the Cult of Nar-Sie's arsenal."
	icon = 'mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	icon_dead = "shade_dead"
	maxHealth = 750
	health = 750
	speak_emote = list("rumbles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "harmlessly punches the"
	harm_intent_damage = 0
	melee_damage_lower = 50
	melee_damage_upper = 50
	attacktext = "brutally crushes"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 5
	wall_smash = 1
	nopush = 1
	a_intent = "harm"
	stop_automated_movement = 1
	canstun = 0
	canweaken = 0
	var/energy = 0
	var/max_energy = 1000


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

/mob/living/simple_animal/constructbehemoth/attackby(var/obj/item/O as obj, var/mob/user as mob)
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


/mob/living/simple_animal/constructbehemoth/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
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


////////////////Powers//////////////////


/*
/client/proc/summon_cultist()
	set category = "Behemoth"
	set name = "Summon Cultist (300)"
	set desc = "Teleport a cultist to your location"
	if (istype(usr,/mob/living/simple_animal/constructbehemoth))

		if(usr.energy<300)
			usr << "\red You do not have enough power stored!"
			return

		if(usr.stat)
			return

		usr.energy -= 300
	var/list/mob/living/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living))
			cultists+=H.current
			var/mob/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - usr)
			if(!cultist)
				return
			if (cultist == usr) //just to be sure.
				return
			cultist.loc = usr.loc
			usr.visible_message("/red [cultist] appears in a flash of red light as [usr] glows with power")*/
