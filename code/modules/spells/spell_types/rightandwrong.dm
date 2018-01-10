//In this file: Summon Magic/Summon Guns/Summon Events

<<<<<<< HEAD
/proc/rightandwrong(summon_type, mob/user, survivor_probability) //0 = Summon Guns, 1 = Summon Magic
	var/list/gunslist 			= list("taser","gravgun","egun","laser","revolver","detective","c20r","nuclear","deagle","gyrojet","pulse","suppressed","cannon","doublebarrel","shotgun","combatshotgun","bulldog","mateba","sabr","crossbow","saw","car","boltaction","speargun","arg","uzi","g17","alienpistol","dragnet","turret","pulsecarbine","decloner","mindflayer","hyperkinetic","advplasmacutter","wormhole","wt550","bulldog","grenadelauncher","goldenrevolver","sniper","medibeam","scatterbeam")
	var/list/magiclist 			= list("fireball","smoke","blind","mindswap","forcewall","knock","horsemask","charge", "summonitem", "wandnothing", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "staffchange", "staffhealing", "armor", "scrying","staffdoor","voodoo", "whistle", "battlemage", "immortality", "ghostsword", "special")
	var/list/magicspeciallist	= list("staffchange","staffanimation", "wandbelt", "contract", "staffchaos", "necromantic", "bloodcontract")
=======
// 1 in 50 chance of getting something really special.
#define SPECIALIST_MAGIC_PROB 2
>>>>>>> 41b06b0c31... Merge pull request #33933 from coiax/wizard-late-joining

GLOBAL_LIST_INIT(summoned_guns, list(
	/obj/item/gun/energy/e_gun/advtaser,
	/obj/item/gun/energy/e_gun,
	/obj/item/gun/energy/laser,
	/obj/item/gun/ballistic/revolver,
	/obj/item/gun/ballistic/revolver/detective,
	/obj/item/gun/ballistic/automatic/pistol/deagle/camo,
	/obj/item/gun/ballistic/automatic/gyropistol,
	/obj/item/gun/energy/pulse,
	/obj/item/gun/ballistic/automatic/pistol/suppressed,
	/obj/item/gun/ballistic/revolver/doublebarrel,
	/obj/item/gun/ballistic/shotgun,
	/obj/item/gun/ballistic/shotgun/automatic/combat,
	/obj/item/gun/ballistic/automatic/ar,
	/obj/item/gun/ballistic/revolver/mateba,
	/obj/item/gun/ballistic/shotgun/boltaction,
	/obj/item/gun/ballistic/automatic/speargun,
	/obj/item/gun/ballistic/automatic/mini_uzi,
	/obj/item/gun/energy/lasercannon,
	/obj/item/gun/energy/kinetic_accelerator/crossbow/large,
	/obj/item/gun/energy/e_gun/nuclear,
	/obj/item/gun/ballistic/automatic/proto,
	/obj/item/gun/ballistic/automatic/shotgun/bulldog,
	/obj/item/gun/ballistic/automatic/c20r,
	/obj/item/gun/ballistic/automatic/l6_saw,
	/obj/item/gun/ballistic/automatic/m90,
	/obj/item/gun/energy/alien,
	/obj/item/gun/energy/e_gun/dragnet,
	/obj/item/gun/energy/e_gun/turret,
	/obj/item/gun/energy/pulse/carbine,
	/obj/item/gun/energy/decloner,
	/obj/item/gun/energy/mindflayer,
	/obj/item/gun/energy/kinetic_accelerator,
	/obj/item/gun/energy/plasmacutter/adv,
	/obj/item/gun/energy/wormhole_projector,
	/obj/item/gun/ballistic/automatic/wt550,
	/obj/item/gun/ballistic/automatic/shotgun,
	/obj/item/gun/ballistic/revolver/grenadelauncher,
	/obj/item/gun/ballistic/revolver/golden,
	/obj/item/gun/ballistic/automatic/sniper_rifle,
	/obj/item/gun/medbeam,
	/obj/item/gun/energy/laser/scatter,
	/obj/item/gun/energy/gravity_gun))

GLOBAL_LIST_INIT(summoned_magic, list(
	/obj/item/spellbook/oneuse/fireball,
	/obj/item/spellbook/oneuse/smoke,
	/obj/item/spellbook/oneuse/blind,
	/obj/item/spellbook/oneuse/mindswap,
	/obj/item/spellbook/oneuse/forcewall,
	/obj/item/spellbook/oneuse/knock,
	/obj/item/spellbook/oneuse/barnyard,
	/obj/item/spellbook/oneuse/charge,
	/obj/item/spellbook/oneuse/summonitem,
	/obj/item/gun/magic/wand,
	/obj/item/gun/magic/wand/death,
	/obj/item/gun/magic/wand/resurrection,
	/obj/item/gun/magic/wand/polymorph,
	/obj/item/gun/magic/wand/teleport,
	/obj/item/gun/magic/wand/door,
	/obj/item/gun/magic/wand/fireball,
	/obj/item/gun/magic/staff/healing,
	/obj/item/gun/magic/staff/door,
	/obj/item/scrying,
	/obj/item/voodoo,
	/obj/item/warpwhistle,
	/obj/item/clothing/suit/space/hardsuit/shielded/wizard,
	/obj/item/device/immortality_talisman,
	/obj/item/melee/ghost_sword))

GLOBAL_LIST_INIT(summoned_special_magic, list(
	/obj/item/gun/magic/staff/change,
	/obj/item/gun/magic/staff/animate,
	/obj/item/storage/belt/wands/full,
	/obj/item/antag_spawner/contract,
	/obj/item/gun/magic/staff/chaos,
	/obj/item/device/necromantic_stone,
	/obj/item/blood_contract))

// If true, it's the probability of triggering "survivor" antag.
GLOBAL_VAR_INIT(summon_guns_triggered, FALSE)
GLOBAL_VAR_INIT(summon_magic_triggered, FALSE)

/proc/give_guns(mob/living/carbon/human/H)
	if(H.stat == DEAD || !(H.client))
		return
	if(H.mind)
		if(iswizard(H) || H.mind.special_role == "survivalist")
			return

	if(prob(GLOB.summon_guns_triggered) && !(H.mind in SSticker.mode.traitors))
		SSticker.mode.traitors += H.mind

		var/datum/objective/steal_five_of_type/summon_guns/guns = new
		guns.owner = H.mind
		H.mind.objectives += guns
		H.mind.special_role = "survivalist"
		H.mind.add_antag_datum(/datum/antagonist/auto_custom)
		to_chat(H, "<B>You are the survivalist! Your own safety matters above all else, and the only way to ensure your safety is to stockpile weapons! Grab as many guns as possible, by any means necessary. Kill anyone who gets in your way.</B>")

		var/datum/objective/survive/survive = new
		survive.owner = H.mind
		H.mind.objectives += survive
		H.log_message("<font color='red'>Was made into a survivalist, and trusts no one!</font>", INDIVIDUAL_ATTACK_LOG)
		H.mind.announce_objectives()

	var/gun_type = pick(GLOB.summoned_guns)
	var/obj/item/gun/G = new gun_type(get_turf(H))
	G.unlock()
	playsound(get_turf(H),'sound/magic/summon_guns.ogg', 50, 1)

	var/in_hand = H.put_in_hands(G) // not always successful

	to_chat(H, "<span class='warning'>\A [G] appears [in_hand ? "in your hand" : "at your feet"]!</span>")

/proc/give_magic(mob/living/carbon/human/H)
	if(H.stat == DEAD || !(H.client))
		return
	if(H.mind)
		if(iswizard(H) || H.mind.special_role == "survivalist")
			return

	if(prob(GLOB.summon_magic_triggered) && !(H.mind in SSticker.mode.traitors))
		var/datum/objective/steal_five_of_type/summon_magic/magic = new
		magic.owner = H.mind
		H.mind.objectives += magic
		H.mind.special_role = "amateur magician"
		H.mind.add_antag_datum(/datum/antagonist/auto_custom)
		to_chat(H, "<B>You are the amateur magician! Grow your newfound talent! Grab as many magical artefacts as possible, by any means necessary. Kill anyone who gets in your way.</B>")

		var/datum/objective/survive/survive = new
		survive.owner = H.mind
		H.mind.objectives += survive
		H.log_message("<font color='red'>Was made into a survivalist, and trusts no one!</font>", INDIVIDUAL_ATTACK_LOG)
		H.mind.announce_objectives()

	var/magic_type = pick(GLOB.summoned_magic)
	var/lucky = FALSE
	if(prob(SPECIALIST_MAGIC_PROB))
		magic_type = pick(GLOB.summoned_special_magic)
		lucky = TRUE

	var/obj/item/M = new magic_type(get_turf(H))
	playsound(get_turf(H),'sound/magic/summon_magic.ogg', 50, 1)

	var/in_hand = H.put_in_hands(M)

	to_chat(H, "<span class='warning'>\A [M] appears [in_hand ? "in your hand" : "at your feet"]!</span>")
	if(lucky)
		to_chat(H, "<span class='notice'>You feel incredibly lucky.</span>")


/proc/rightandwrong(summon_type, mob/user, survivor_probability)
	if(user) //in this case either someone holding a spellbook or a badmin
<<<<<<< HEAD
		to_chat(user, "<B>You summoned [summon_type ? "magic" : "guns"]!</B>")
		message_admins("[key_name_admin(user, 1)] summoned [summon_type ? "magic" : "guns"]!")
		log_game("[key_name(user)] summoned [summon_type ? "magic" : "guns"]!")
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		if(H.mind)
			if(iswizard(H) || H.mind.special_role == "survivalist")
				continue
		if(prob(survivor_probability) && !(H.mind in SSticker.mode.traitors))
			SSticker.mode.traitors += H.mind
			if(!summon_type)
				var/datum/objective/steal_five_of_type/summon_guns/guns = new
				guns.owner = H.mind
				H.mind.objectives += guns
				H.mind.special_role = "survivalist"
				H.mind.add_antag_datum(/datum/antagonist/auto_custom)
				to_chat(H, "<B>You are the survivalist! Your own safety matters above all else, and the only way to ensure your safety is to stockpile weapons! Grab as many guns as possible, by any means necessary. Kill anyone who gets in your way.</B>")
			else
				var/datum/objective/steal_five_of_type/summon_magic/magic = new
				magic.owner = H.mind
				H.mind.objectives += magic
				H.mind.special_role = "amateur magician"
				H.mind.add_antag_datum(/datum/antagonist/auto_custom)
				to_chat(H, "<B>You are the amateur magician! Grow your newfound talent! Grab as many magical artefacts as possible, by any means necessary. Kill anyone who gets in your way.</B>")
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H.log_message("<font color='red'>Was made into a survivalist, and trusts no one!</font>", INDIVIDUAL_ATTACK_LOG)
			H.mind.announce_objectives()
		var/randomizeguns 			= pick(gunslist)
		var/randomizemagic 			= pick(magiclist)
		var/randomizemagicspecial 	= pick(magicspeciallist)
		if(!summon_type)
			var/obj/item/gun/G
			switch (randomizeguns)
				if("taser")
					G = new /obj/item/gun/energy/e_gun/advtaser(get_turf(H))
				if("egun")
					G = new /obj/item/gun/energy/e_gun(get_turf(H))
				if("laser")
					G = new /obj/item/gun/energy/laser(get_turf(H))
				if("revolver")
					G = new /obj/item/gun/ballistic/revolver(get_turf(H))
				if("detective")
					G = new /obj/item/gun/ballistic/revolver/detective(get_turf(H))
				if("deagle")
					G = new /obj/item/gun/ballistic/automatic/pistol/deagle/camo(get_turf(H))
				if("gyrojet")
					G = new /obj/item/gun/ballistic/automatic/gyropistol(get_turf(H))
				if("pulse")
					G = new /obj/item/gun/energy/pulse(get_turf(H))
				if("suppressed")
					G = new /obj/item/gun/ballistic/automatic/pistol(get_turf(H))
					new /obj/item/suppressor(get_turf(H))
				if("doublebarrel")
					G = new /obj/item/gun/ballistic/revolver/doublebarrel(get_turf(H))
				if("shotgun")
					G = new /obj/item/gun/ballistic/shotgun(get_turf(H))
				if("combatshotgun")
					G = new /obj/item/gun/ballistic/shotgun/automatic/combat(get_turf(H))
				if("arg")
					G = new /obj/item/gun/ballistic/automatic/ar(get_turf(H))
				if("mateba")
					G = new /obj/item/gun/ballistic/revolver/mateba(get_turf(H))
				if("boltaction")
					G = new /obj/item/gun/ballistic/shotgun/boltaction(get_turf(H))
				if("speargun")
					G = new /obj/item/gun/ballistic/automatic/speargun(get_turf(H))
				if("uzi")
					G = new /obj/item/gun/ballistic/automatic/mini_uzi(get_turf(H))
				if("cannon")
					G = new /obj/item/gun/energy/lasercannon(get_turf(H))
				if("crossbow")
					G = new /obj/item/gun/energy/kinetic_accelerator/crossbow/large(get_turf(H))
				if("nuclear")
					G = new /obj/item/gun/energy/e_gun/nuclear(get_turf(H))
				if("sabr")
					G = new /obj/item/gun/ballistic/automatic/proto(get_turf(H))
				if("bulldog")
					G = new /obj/item/gun/ballistic/automatic/shotgun/bulldog(get_turf(H))
				if("c20r")
					G = new /obj/item/gun/ballistic/automatic/c20r(get_turf(H))
				if("saw")
					G = new /obj/item/gun/ballistic/automatic/l6_saw(get_turf(H))
				if("car")
					G = new /obj/item/gun/ballistic/automatic/m90(get_turf(H))
				if("glock17")
					G = new /obj/item/gun/ballistic/automatic/pistol/g17(get_turf(H))
				if("alienpistol")
					G = new /obj/item/gun/energy/alien(get_turf(H))
				if("dragnet")
					G = new /obj/item/gun/energy/e_gun/dragnet(get_turf(H))
				if("turret")
					G = new /obj/item/gun/energy/e_gun/turret(get_turf(H))
				if("pulsecarbine")
					G = new /obj/item/gun/energy/pulse/carbine(get_turf(H))
				if("decloner")
					G = new /obj/item/gun/energy/decloner(get_turf(H))
				if("mindflayer")
					G = new /obj/item/gun/energy/mindflayer(get_turf(H))
				if("hyperkinetic")
					G = new /obj/item/gun/energy/kinetic_accelerator(get_turf(H))
				if("advplasmacutter")
					G = new /obj/item/gun/energy/plasmacutter/adv(get_turf(H))
				if("wormhole")
					G = new /obj/item/gun/energy/wormhole_projector(get_turf(H))
				if("wt550")
					G = new /obj/item/gun/ballistic/automatic/wt550(get_turf(H))
				if("bulldog")
					G = new /obj/item/gun/ballistic/automatic/shotgun(get_turf(H))
				if("grenadelauncher")
					G = new /obj/item/gun/ballistic/revolver/grenadelauncher(get_turf(H))
				if("goldenrevolver")
					G = new /obj/item/gun/ballistic/revolver/golden(get_turf(H))
				if("sniper")
					G = new /obj/item/gun/ballistic/automatic/sniper_rifle(get_turf(H))
				if("medibeam")
					G = new /obj/item/gun/medbeam(get_turf(H))
				if("scatterbeam")
					G = new /obj/item/gun/energy/laser/scatter(get_turf(H))
				if("gravgun")
					G = new /obj/item/gun/energy/gravity_gun(get_turf(H))
			G.unlock()
			playsound(get_turf(H),'sound/magic/summon_guns.ogg', 50, 1)
=======
		to_chat(user, "<span class='warning'>You summoned [summon_type]!</span>")
		message_admins("[key_name_admin(user, 1)] summoned [summon_type]!")
		log_game("[key_name(user)] summoned [summon_type]!")
>>>>>>> 41b06b0c31... Merge pull request #33933 from coiax/wizard-late-joining

	if(summon_type == SUMMON_MAGIC)
		GLOB.summon_magic_triggered = survivor_probability
	else if(summon_type == SUMMON_GUNS)
		GLOB.summon_guns_triggered = survivor_probability
	else
		CRASH("Bad summon_type given: [summon_type]")

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(summon_type == SUMMON_MAGIC)
			give_magic(H)
		else
			give_guns(H)

/proc/summonevents()
	if(!SSevents.wizardmode)
		SSevents.frequency_lower = 600									//1 minute lower bound
		SSevents.frequency_upper = 3000									//5 minutes upper bound
		SSevents.toggleWizardmode()
		SSevents.reschedule()

	else 																//Speed it up
		SSevents.frequency_upper -= 600	//The upper bound falls a minute each time, making the AVERAGE time between events lessen
		if(SSevents.frequency_upper < SSevents.frequency_lower) //Sanity
			SSevents.frequency_upper = SSevents.frequency_lower

		SSevents.reschedule()
		message_admins("Summon Events intensifies, events will now occur every [SSevents.frequency_lower / 600] to [SSevents.frequency_upper / 600] minutes.")
		log_game("Summon Events was increased!")

#undef SPECIALIST_MAGIC_PROB
