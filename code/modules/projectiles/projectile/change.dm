/obj/item/projectile/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/change)
		wabbajack(change)


/obj/item/projectile/change/proc/wabbajack (mob/M as mob in living_mob_list)
	if(istype(M, /mob/living) && M.stat != DEAD)
		if(M.monkeyizing)	return
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.overlays = null
		M.invisibility = 101

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)	del(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					del(W)
					continue
				W.layer = initial(W.layer)
				W.loc = M.loc
				W.dropped(M)

		var/mob/living/new_mob

		var/randomize = pick("monkey","robot","metroid","xeno","human")
		switch(randomize)
			if("monkey")
				new_mob = new /mob/living/carbon/monkey(M.loc)
				new_mob.universal_speak = 1
			if("robot")
				new_mob = new /mob/living/silicon/robot(M.loc)
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi = new /obj/item/device/mmi(new_mob)
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
			if("metroid")
				if(prob(50))		new_mob = new /mob/living/carbon/metroid/adult(M.loc)
				else				new_mob = new /mob/living/carbon/metroid(M.loc)
				new_mob.universal_speak = 1
			if("xeno")
				var/alien_caste = pick("Hunter","Sentinel","Drone","Larva")
				switch(alien_caste)
					if("Hunter")	new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
					if("Sentinel")	new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
					if("Drone")		new_mob = new /mob/living/carbon/alien/humanoid/drone(M.loc)
					else			new_mob = new /mob/living/carbon/alien/larva(M.loc)
				new_mob.universal_speak = 1
			if("human")
				new_mob = new /mob/living/carbon/human(M.loc)
				if(M.gender == MALE)
					new_mob.gender = MALE
					new_mob.name = pick(first_names_male)
				else
					new_mob.gender = FEMALE
					new_mob.name = pick(first_names_female)
				new_mob.name += " [pick(last_names)]"
				new_mob.real_name = new_mob.name

				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.randomize_appearance_for(new_mob)

				var/mob/living/carbon/human/H = new_mob
				if(H.dna)
					H.dna.mutantrace = pick("lizard","golem","metroid","plant",4;"")
			else
				return

		new_mob.a_intent = "hurt"
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		new_mob << "<B>Your form morphs into that of a [randomize].</B>"

		del(M)
		return new_mob

