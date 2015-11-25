/obj/item/projectile/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/changetype=null

/obj/item/projectile/change/on_hit(var/atom/change)
	spawn(1)//fixes bugs caused by the target ceasing to exist before the projectile has died.
		wabbajack(change)


/obj/item/projectile/change/proc/wabbajack(var/mob/living/M) //WHY: as mob in living_mob_list
	if(istype(M, /mob/living) && M.stat != DEAD)
		if(M.monkeyizing)
			return
		if(M.has_brain_worms())
			return //Borer stuff - RR
		if(istype(M, /mob/living/carbon/human/manifested))
			visible_message("<span class='caution'>The bolt of change doesn't seem to affect [M] in any way.</span>")
			return

		// TODO: This needs to be standardized, sort of a premorph() proc or something.
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.overlays.len = 0
		M.invisibility = 101

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)
				del(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					del(W)
					continue
				W.layer = initial(W.layer)
				W.loc = M.loc
				W.dropped(M)
		// END TODO

		var/mob/living/new_mob

		// Random chance of fucking up
		if(changetype!=null && prob(10))
			changetype = null

		var/randomize = changetype==null?pick(available_staff_transforms):changetype

		switch(randomize)
			if("monkey")
				new_mob = new /mob/living/carbon/monkey(M.loc)
				new_mob.setGender(M.gender)
				var/mob/living/carbon/monkey/Monkey = new_mob
				Monkey.languages |= M.languages
				if(M.default_language) Monkey.default_language = M.default_language
			if("robot")
				new_mob = new /mob/living/silicon/robot(M.loc)
				new_mob.setGender(M.gender)
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi = new /obj/item/device/mmi(new_mob)
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
				Robot.languages |= M.languages
				if(M.default_language) Robot.default_language = M.default_language
			if("mommi")
				new_mob = new /mob/living/silicon/robot/mommi(M.loc)
				new_mob.setGender(M.gender)
				new_mob.invisibility = 0
				new_mob.job = "MoMMI"
				var/mob/living/silicon/robot/mommi/MoMMI = new_mob
				MoMMI.mmi = new /obj/item/device/mmi(new_mob)
				MoMMI.mmi.transfer_identity(M)	//Does not transfer key/client.
				MoMMI.languages |= M.languages
				if(M.default_language) MoMMI.default_language = M.default_language
			if("slime")
				var/slimey = pick("",\
				                 "/purple",\
				                 "/metal",\
				                 "/orange",\
				                 "/blue",\
				                 "/darkblue",\
				                 "/darkpurple",\
				                 "/yellow",\
				                 "/silver",\
				                 "/pink",\
				                 "/red",\
				                 "/gold",\
				                 "/green",\
				                 "/lightpink",\
				                 "/oil",\
				                 "/black",\
				                 "/adamantine",\
				                 "/bluespace",\
				                 "/pyrite",\
				                 "/cerulean",\
				                 "/sepia"\
				                 )

				if (prob(50))
					slimey = "/adult[slimey]"

				slimey = text2path("/mob/living/carbon/slime[slimey]")
				new_mob = new slimey(M.loc)
				new_mob.setGender(M.gender)
				var/mob/living/carbon/slime/Slime = new_mob
				Slime.languages |= M.languages
				if(M.default_language) Slime.default_language = M.default_language
			if("xeno")
				var/alien_caste = pick("Hunter","Sentinel","Drone","Larva")
				switch(alien_caste)
					if("Hunter")	new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
					if("Sentinel")	new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
					if("Drone")		new_mob = new /mob/living/carbon/alien/humanoid/drone(M.loc)
					else			new_mob = new /mob/living/carbon/alien/larva(M.loc)
				var/mob/living/carbon/alien/Alien = new_mob
				Alien.languages |= M.languages
				if(M.default_language) Alien.default_language = M.default_language
			if("human")
				new_mob = new /mob/living/carbon/human(M.loc, delay_ready_dna=1)

				if((M.gender == MALE) || (M.gender == FEMALE)) //If the transformed mob is MALE or FEMALE
					new_mob.setGender(M.gender) //The new human will inherit its gender
				else //If its gender is NEUTRAL or PLURAL,
					new_mob.setGender(pick(MALE, FEMALE)) //The new human's gender will be random

				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.randomize_appearance_for(new_mob)

				var/mob/living/carbon/human/H = new_mob
				var/newspecies = pick(all_species-/datum/species/krampus)
				H.set_species(newspecies)
				H.generate_name()
				H.languages |= M.languages
				if(M.default_language) H.default_language = M.default_language
			if("furry")
				new_mob = new /mob/living/carbon/human(M.loc, delay_ready_dna=1)

				if((M.gender == MALE) || (M.gender == FEMALE)) //If the transformed mob is MALE or FEMALE
					new_mob.setGender(M.gender) //The new human will inherit its gender
				else //If its gender is NEUTRAL or PLURAL,
					new_mob.setGender(pick(MALE, FEMALE)) //The new human's gender will be random

				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.randomize_appearance_for(new_mob)

				var/mob/living/carbon/human/H = new_mob
				H.set_species("Tajaran") // idfk
				H.languages |= M.languages
				if(M.default_language) H.default_language = M.default_language
				H.generate_name()
			/* RIP
			if("cluwne")
				new_mob = new /mob/living/simple_animal/hostile/retaliate/cluwne(M.loc)
				new_mob.setGender(gender)
				new_mob.name = pick(clown_names)
				new_mob.real_name = new_mob.name
				new_mob.mutations += M_CLUMSY
				new_mob.mutations += M_FAT
				new_mob.setBrainLoss(100)
			*/
			else
				return
		if(M.mind && M.mind.wizard_spells && M.mind.wizard_spells.len)
			for (var/spell/S in M.mind.wizard_spells)
				new_mob.spell_list += new S.type

		new_mob.a_intent = I_HURT
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		to_chat(new_mob, "<B>Your form morphs into that of a [randomize].</B>")

		del(M)
		return new_mob

