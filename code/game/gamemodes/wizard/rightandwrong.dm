//In this file: Summon Magic/Summon Guns/Summon Events

/proc/rightandwrong(var/summon_type, var/mob/user) //0 = Summon Guns, 1 = Summon Magic
	var/list/gunslist 			= list("taser","egun","laser","revolver","detective","smg","nuclear","deagle","gyrojet","pulse","suppressed","cannon","doublebarrel","shotgun","combatshotgun","mateba","smg","uzi","crossbow","saw")
	var/list/magiclist 			= list("fireball","smoke","blind","mindswap","forcewall","knock","horsemask","charge","wandnothing", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "staffchange", "staffhealing", "armor", "scrying", "staffdoor", "special")
	var/list/magicspeciallist	= list("staffchange","staffanimation", "wandbelt", "contract", "staffchaos")

	if(user) //in this case either someone holding a spellbook or a badmin
		user << "<B>You summoned [summon_type ? "magic" : "guns"]!</B>"
		message_admins("[key_name_admin(user, 1)] summoned [summon_type ? "magic" : "guns"]!")
		log_game("[key_name(user)] summoned [summon_type ? "magic" : "guns"]!")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(H.mind)
			if(H.mind.special_role == "Wizard" || H.mind.special_role == "apprentice") continue
		if(prob(25) && !(H.mind in ticker.mode.traitors))
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a survivor, and trusts no one!</font>"
			H << "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>"
			var/obj_count = 1
			for(var/datum/objective/OBJ in H.mind.objectives)
				H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++
		var/randomizeguns 			= pick(gunslist)
		var/randomizemagic 			= pick(magiclist)
		var/randomizemagicspecial 	= pick(magicspeciallist)
		if(!summon_type)
			switch (randomizeguns)
				if("taser")
					new /obj/item/weapon/gun/energy/taser(get_turf(H))
				if("egun")
					new /obj/item/weapon/gun/energy/gun(get_turf(H))
				if("laser")
					new /obj/item/weapon/gun/energy/laser(get_turf(H))
				if("revolver")
					new /obj/item/weapon/gun/projectile/revolver(get_turf(H))
				if("detective")
					new /obj/item/weapon/gun/projectile/revolver/detective(get_turf(H))
				if("smg")
					new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
				if("nuclear")
					new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
				if("deagle")
					new /obj/item/weapon/gun/projectile/automatic/deagle/camo(get_turf(H))
				if("gyrojet")
					new /obj/item/weapon/gun/projectile/automatic/gyropistol(get_turf(H))
				if("pulse")
					new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
				if("suppressed")
					new /obj/item/weapon/gun/projectile/automatic/pistol(get_turf(H))
					new /obj/item/weapon/suppressor(get_turf(H))
				if("cannon")
					new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
				if("doublebarrel")
					new /obj/item/weapon/gun/projectile/revolver/doublebarrel(get_turf(H))
				if("shotgun")
					new /obj/item/weapon/gun/projectile/shotgun/(get_turf(H))
				if("combatshotgun")
					new /obj/item/weapon/gun/projectile/shotgun/combat(get_turf(H))
				if("mateba")
					new /obj/item/weapon/gun/projectile/revolver/mateba(get_turf(H))
				if("smg")
					new /obj/item/weapon/gun/projectile/automatic(get_turf(H))
				if("uzi")
					new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
				if("crossbow")
					new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
				if("saw")
					new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(H))
		else
			switch (randomizemagic)
				if("fireball")
					new /obj/item/weapon/spellbook/oneuse/fireball(get_turf(H))
				if("smoke")
					new /obj/item/weapon/spellbook/oneuse/smoke(get_turf(H))
				if("blind")
					new /obj/item/weapon/spellbook/oneuse/blind(get_turf(H))
				if("mindswap")
					new /obj/item/weapon/spellbook/oneuse/mindswap(get_turf(H))
				if("forcewall")
					new /obj/item/weapon/spellbook/oneuse/forcewall(get_turf(H))
				if("knock")
					new /obj/item/weapon/spellbook/oneuse/knock(get_turf(H))
				if("horsemask")
					new /obj/item/weapon/spellbook/oneuse/horsemask(get_turf(H))
				if("charge")
					new /obj/item/weapon/spellbook/oneuse/charge(get_turf(H))
				if("wandnothing")
					new /obj/item/weapon/gun/magic/wand(get_turf(H))
				if("wanddeath")
					new /obj/item/weapon/gun/magic/wand/death(get_turf(H))
				if("wandresurrection")
					new /obj/item/weapon/gun/magic/wand/resurrection(get_turf(H))
				if("wandpolymorph")
					new /obj/item/weapon/gun/magic/wand/polymorph(get_turf(H))
				if("wandteleport")
					new /obj/item/weapon/gun/magic/wand/teleport(get_turf(H))
				if("wanddoor")
					new /obj/item/weapon/gun/magic/wand/door(get_turf(H))
				if("wandfireball")
					new /obj/item/weapon/gun/magic/wand/fireball(get_turf(H))
				if("staffhealing")
					new /obj/item/weapon/gun/magic/staff/healing(get_turf(H))
				if("staffdoor")
					new /obj/item/weapon/gun/magic/staff/door(get_turf(H))
				if("armor")
					new /obj/item/clothing/suit/space/hardsuit/wizard(get_turf(H))
					new /obj/item/clothing/head/helmet/space/hardsuit/wizard(get_turf(H))
				if("scrying")
					new /obj/item/weapon/scrying(get_turf(H))
					if (!(XRAY in H.mutations))
						H.mutations.Add(XRAY)
						H.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
						H.see_in_dark = 8
						H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
						H << "<span class='notice'>The walls suddenly disappear.</span>"

				if("special")
					magiclist -= "special" //only one super OP item per summoning max
					switch (randomizemagicspecial)
						if("staffchange")
							new /obj/item/weapon/gun/magic/staff/change(get_turf(H))
						if("staffanimation")
							new /obj/item/weapon/gun/magic/staff/animate(get_turf(H))
						if("wandbelt")
							new /obj/item/weapon/storage/belt/wands/full(get_turf(H))
						if("contract")
							new /obj/item/weapon/antag_spawner/contract(get_turf(H))
						if("staffchaos")
							new /obj/item/weapon/gun/magic/staff/chaos(get_turf(H))
					H << "<span class='notice'>You suddenly feel lucky.</span>"

/mob/proc/summonevents()
	if(events) 																//if there isn't something is very wrong
		if(!events.wizardmode)
			events.toggleWizardmode()
			events.frequency_lower = 600									//1 minute lower bound
			events.frequency_upper = 3000									//5 minutes upper bound
			events.reschedule()

		else 																//Speed it up
			events.frequency_lower = round(events.frequency_lower * 0.8)	//1 minute | 48 seconds | 34.8 seconds | 30.7 seconds | 24.6 seconds
			events.frequency_upper = round(events.frequency_upper * 0.6)	//5 minutes | 3 minutes | 1 minute 48 seconds | 1 minute 4.8 seconds | 38.9 seconds
			if(events.frequency_upper < events.frequency_lower)
				events.frequency_upper = events.frequency_lower				//this can't happen unless somehow multiple spellbooks are used, but just in case

			events.reschedule()
