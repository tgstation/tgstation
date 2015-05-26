//In this file: Summon Magic/Summon Guns/Summon Events

/proc/rightandwrong(var/summon_type, var/mob/user, var/survivor_probability) //0 = Summon Guns, 1 = Summon Magic
	var/list/gunslist 			= list("taser","egun","laser","revolver","detective","c20r","nuclear","deagle","gyrojet","pulse","suppressed","cannon","doublebarrel","shotgun","combatshotgun","bulldog","mateba","sabr","crossbow","saw","car","boltaction","speargun","arg")
	var/list/magiclist 			= list("fireball","smoke","blind","mindswap","forcewall","knock","horsemask","charge", "summonitem", "wandnothing", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "staffchange", "staffhealing", "armor", "scrying","staffdoor", "special")
	var/list/magicspeciallist	= list("staffchange","staffanimation", "wandbelt", "contract", "staffchaos", "necromantic")

	if(user) //in this case either someone holding a spellbook or a badmin
		user << "<B>You summoned [summon_type ? "magic" : "guns"]!</B>"
		message_admins("[key_name_admin(user, 1)] summoned [summon_type ? "magic" : "guns"]!")
		log_game("[key_name(user)] summoned [summon_type ? "magic" : "guns"]!")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(H.mind)
			if(H.mind.special_role == "Wizard" || H.mind.special_role == "apprentice") continue
		if(prob(survivor_probability) && !(H.mind in ticker.mode.traitors))
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
					new /obj/item/weapon/gun/energy/gun/advtaser(get_turf(H))
				if("egun")
					new /obj/item/weapon/gun/energy/gun(get_turf(H))
				if("laser")
					new /obj/item/weapon/gun/energy/laser(get_turf(H))
				if("revolver")
					new /obj/item/weapon/gun/projectile/revolver(get_turf(H))
				if("detective")
					new /obj/item/weapon/gun/projectile/revolver/detective(get_turf(H))
				if("deagle")
					new /obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo(get_turf(H))
				if("gyrojet")
					new /obj/item/weapon/gun/projectile/automatic/gyropistol(get_turf(H))
				if("pulse")
					new /obj/item/weapon/gun/energy/pulse(get_turf(H))
				if("suppressed")
					new /obj/item/weapon/gun/projectile/automatic/pistol(get_turf(H))
					new /obj/item/weapon/suppressor(get_turf(H))
				if("doublebarrel")
					new /obj/item/weapon/gun/projectile/revolver/doublebarrel(get_turf(H))
				if("shotgun")
					new /obj/item/weapon/gun/projectile/shotgun(get_turf(H))
				if("combatshotgun")
					new /obj/item/weapon/gun/projectile/shotgun/combat(get_turf(H))
				if("arg")
					new /obj/item/weapon/gun/projectile/automatic/ar(get_turf(H))
				if("mateba")
					new /obj/item/weapon/gun/projectile/revolver/mateba(get_turf(H))
				if("boltaction")
					new /obj/item/weapon/gun/projectile/shotgun/boltaction(get_turf(H))
				if("speargun")
					new /obj/item/weapon/gun/projectile/automatic/speargun(get_turf(H))
				if("cannon")
					var/obj/item/weapon/gun/energy/lasercannon/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin //no authentication pins for spawned guns. fun allowed.
				if("crossbow")
					var/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin
				if("nuclear")
					var/obj/item/weapon/gun/energy/gun/nuclear/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin
				if("sabr")
					var/obj/item/weapon/gun/projectile/automatic/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin
				if("bulldog")
					var/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin
				if("c20r")
					var/obj/item/weapon/gun/projectile/automatic/c20r/gat = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin
				if("saw")
					var/obj/item/weapon/gun/projectile/automatic/l6_saw/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin
				if("car")
					var/obj/item/weapon/gun/projectile/automatic/m90/gat  = new(get_turf(H))
					gat.pin = new /obj/item/device/firing_pin

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
					new /obj/item/weapon/spellbook/oneuse/barnyard(get_turf(H))
				if("charge")
					new /obj/item/weapon/spellbook/oneuse/charge(get_turf(H))
				if("summonitem")
					new /obj/item/weapon/spellbook/oneuse/summonitem(get_turf(H))
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
				if("scrying")
					new /obj/item/weapon/scrying(get_turf(H))
					if (!(H.dna.check_mutation(XRAY)))
						H.dna.add_mutation(XRAY)
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
						if("necromantic")
							new /obj/item/device/necromantic_stone(get_turf(H))
					H << "<span class='notice'>You suddenly feel lucky.</span>"

/proc/summonevents()
	if(!SSevent.wizardmode)
		SSevent.frequency_lower = 600									//1 minute lower bound
		SSevent.frequency_upper = 3000									//5 minutes upper bound
		SSevent.toggleWizardmode()
		SSevent.reschedule()

	else 																//Speed it up
		SSevent.frequency_upper -= 600	//The upper bound falls a minute each time, making the AVERAGE time between events lessen
		if(SSevent.frequency_upper < SSevent.frequency_lower) //Sanity
			SSevent.frequency_upper = SSevent.frequency_lower

		SSevent.reschedule()
		message_admins("Summon Events intensifies, events will now occur every [SSevent.frequency_lower / 600] to [SSevent.frequency_upper / 600] minutes.")
		log_game("Summon Events was increased!")
