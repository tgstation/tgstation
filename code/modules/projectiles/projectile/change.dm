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
		M.overlays.Cut()
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

		var/randomize = pick("monkey","robot","slime","xeno","human","animal")
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
			if("slime")
				if(prob(50))		new_mob = new /mob/living/carbon/slime/adult(M.loc)
				else				new_mob = new /mob/living/carbon/slime(M.loc)
				new_mob.universal_speak = 1
			if("xeno")
				if(prob(50))
					new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
				else
					new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
				new_mob.universal_speak = 1

				/*var/alien_caste = pick("Hunter","Sentinel","Drone","Larva")
				switch(alien_caste)
					if("Hunter")	new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
					if("Sentinel")	new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
					if("Drone")		new_mob = new /mob/living/carbon/alien/humanoid/drone(M.loc)
					else			new_mob = new /mob/living/carbon/alien/larva(M.loc)
				new_mob.universal_speak = 1*/
			if("animal")
				var/animal = pick("parrot","corgi","crab","pug","cat","carp","bear","mushroom","tomato","mouse","chicken","cow","lizard","chick")
				switch(animal)
					if("parrot")	new_mob = new /mob/living/simple_animal/parrot(M.loc)
					if("corgi")		new_mob = new /mob/living/simple_animal/corgi(M.loc)
					if("crab")		new_mob = new /mob/living/simple_animal/crab(M.loc)
					if("pug")		new_mob = new /mob/living/simple_animal/pug(M.loc)
					if("cat")		new_mob = new /mob/living/simple_animal/cat(M.loc)
					if("carp")		new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
					if("bear")		new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
					if("mushroom")	new_mob = new /mob/living/simple_animal/mushroom(M.loc)
					if("tomato")	new_mob = new /mob/living/simple_animal/tomato(M.loc)
					if("mouse")		new_mob = new /mob/living/simple_animal/mouse(M.loc)
					if("chicken")	new_mob = new /mob/living/simple_animal/chicken(M.loc)
					if("cow")		new_mob = new /mob/living/simple_animal/cow(M.loc)
					if("lizard")	new_mob = new /mob/living/simple_animal/lizard(M.loc)
					else			new_mob = new /mob/living/simple_animal/chick(M.loc)
					new_mob.universal_speak = 1
			if("human")
				new_mob = new /mob/living/carbon/human(M.loc)

				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.copy_to(new_mob)

				var/mob/living/carbon/human/H = new_mob
				ready_dna(H)
				if(H.dna)
					H.dna.mutantrace = pick("lizard","golem","slime","plant","fly","shadow","adamantine","skeleton",8;"")
					H.update_body()
			else
				return

		for (var/obj/effect/proc_holder/spell/S in M.spell_list)
			new_mob.spell_list += new S.type

		new_mob.a_intent = "harm"
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		new_mob << "<B>Your form morphs into that of a [randomize].</B>"

		del(M)
		return new_mob

