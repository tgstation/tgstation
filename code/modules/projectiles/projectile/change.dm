/obj/item/projectile/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/change)
		wabbajack(change)


	/*Bump(atom/change)
		if(istype(change, /mob/living))
			wabbajack(change)
		else
			del(src)*/



/obj/item/projectile/change/proc/wabbajack (mob/M as mob in living_mob_list)
	if(istype(M, /mob/living) && M.stat != 2)
		for(var/obj/item/W in M)
			if (istype(M, /mob/living/silicon/robot)||istype(W, /obj/item/weapon/implant))
				del (W)
			M.drop_from_inventory(W)
		var/randomize = pick("monkey","robot","metroid","alien","human")
		switch(randomize)
			if("monkey")
				if (M.monkeyizing)
					return
//				M.regenerate_icons()
				M.monkeyizing = 1
				M.canmove = 0
				M.icon = null
				M.invisibility = 101
				var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey( M.loc )
				O.name = "monkey"
				if (M.client)
					M.client.mob = O
				if(M.mind)
					M.mind.transfer_to(O)
				O.a_intent = "hurt"
				O.universal_speak = 1
				O << "<B>You are now a monkey.</B>"
				del(M)
				return O
			if("robot")
				if (M.monkeyizing)
					return
//				M.regenerate_icons()
				M.monkeyizing = 1
				M.canmove = 0
				M.icon = null
				M.invisibility = 101
				if(M.client)
					M.client.screen -= M.hud_used.contents
					M.client.screen -= M.hud_used.adding
					M.client.screen -= list( M.oxygen, M.throw_icon, M.i_select, M.m_select, M.toxin, M.internals, M.fire, M.hands, M.healths, M.pullin, M.blind, M.flash, M.rest, M.sleep, M.mach )
					M.client.screen -= list( M.zone_sel, M.oxygen, M.throw_icon, M.i_select, M.m_select, M.toxin, M.internals, M.fire, M.hands, M.healths, M.pullin, M.blind, M.flash, M.rest, M.sleep, M.mach )

				var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( M.loc )
				O.cell = new(O)
				O.cell.maxcharge = 7500
				O.cell.charge = 7500
				O.gender = M.gender
				O.invisibility = 0
				O.name = "Cyborg"
				O.real_name = "Cyborg"
				if (M.mind)
					M.mind.transfer_to(O)
					if (M.mind.assigned_role == "Cyborg")
						M.mind.original = O
					else if (M.mind.special_role) O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
				else
					M.mind = new /datum/mind(  )
					M.mind.key = M.key
					M.mind.current = O
					M.mind.original = O
					M.mind.transfer_to(O)

				if(!(O.mind in ticker.minds))
					ticker.minds += O.mind//Adds them to regular mind list.

				O.loc = loc
				//O << "<B>You are playing a Cyborg. A Cyborg can interact with most electronic objects in its view point.</B>"
				//O << "<B>You must follow the laws that the AI has. You must follow orders the AI gives you.</B>"
				//O << "To use something, simply click on it."
				//O << {"Use say ":s to speak to fellow cyborgs and the AI through binary."}

				O.job = "Cyborg"

				O.mmi = new /obj/item/device/mmi(O)
				O.mmi.transfer_identity(M)//Does not transfer key/client.
				del(M)
				return O
			if("metroid")
				if (M.monkeyizing)
					return
//				M.regenerate_icons()
				M.monkeyizing = 1
				M.canmove = 0
				M.icon = null
				M.invisibility = 101
				if(prob(50))
					var/mob/living/carbon/metroid/adult/new_metroid = new /mob/living/carbon/metroid/adult (M.loc)
					if (M.client)
						M.client.mob = new_metroid
					if(M.mind)
						M.mind.transfer_to(new_metroid)

					new_metroid.a_intent = "hurt"
					new_metroid << "<B>You are now an adult Metroid.</B>"
					new_metroid.universal_speak = 1
					del(M)
					return new_metroid
				else
					var/mob/living/carbon/metroid/new_metroid = new /mob/living/carbon/metroid (M.loc)
					if (M.client)
						M.client.mob = new_metroid
					if(M.mind)
						M.mind.transfer_to(new_metroid)
					new_metroid.a_intent = "hurt"
					new_metroid.universal_speak = 1
					new_metroid << "<B>You are now a baby Metroid.</B>"
					del(M)
					return new_metroid
			if("alien")
				if (M.monkeyizing)
					return
//				M.regenerate_icons()
				M.monkeyizing = 1
				M.canmove = 0
				M.icon = null
				M.invisibility = 101
				var/alien_caste = pick("Hunter","Sentinel","Drone")
				var/mob/living/carbon/alien/humanoid/new_xeno
				switch(alien_caste)
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter (M.loc)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel (M.loc)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone (M.loc)
				if (M.client)
					M.client.mob = new_xeno
				if(M.mind)
					M.mind.transfer_to(new_xeno)
				new_xeno.a_intent = "hurt"
				new_xeno.universal_speak = 1
				new_xeno << "<B>You are now an alien.</B>"
				del(M)
				return new_xeno
			if("human")
				if (M.monkeyizing)
					return
//				M.regenerate_icons()
				M.monkeyizing = 1
				M.canmove = 0
				M.icon = null
				M.invisibility = 101
				var/mob/living/carbon/human/O = new /mob/living/carbon/human( M.loc )

				var/first = pick(first_names_male)
				var/last = pick(last_names)
				O.name = "[first] [last]"
				O.real_name = "[first] [last]"
				var/race = pick("lizard","golem","metroid","plant","normal")
				switch(race)
					if("lizard")
						O.mutantrace = "lizard"
					if("golem")
						O.mutantrace = "golem"
					if("metroid")
						O.mutantrace = "metroid"
					if("plant")
						O.mutantrace = "plant"
					if("normal")
						O.mutantrace = ""
				if (M.client)
					M.client.mob = O
				if(M.mind)
					M.mind.transfer_to(O)
				O.a_intent = "hurt"
				O << "<B>You are now a human.</B>"
				del(M)
				return O
		return

