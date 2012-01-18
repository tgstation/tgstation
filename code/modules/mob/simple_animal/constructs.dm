/mob/living/simple_animal/constructarmoured
	name = "Dread Armour"
	desc = "A possessed suit of armour driven by the will of the restless dead"
	icon = 'mob.dmi'
	icon_state = "armour"
	icon_living = "armour"
	icon_dead = "shade_dead"
	max_health = 300
	health = 300
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