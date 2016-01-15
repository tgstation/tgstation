//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/landmark/corpse
	name = "Unknown"
	var/mobname = "default"  //Use for the ghost spawner variant, so they don't come out named "sleeper"
	var/mobgender = MALE //Set to male by default due to the patriarchy. Other options include FEMALE and NEUTER
	var/mob_species = null //Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/corpseuniform = null //Set this to an object path to have the slot filled with said object on the corpse.
	var/corpsesuit = null
	var/corpseshoes = null
	var/corpsegloves = null
	var/corpseradio = null
	var/corpseglasses = null
	var/corpsemask = null
	var/corpsehelmet = null
	var/corpsebelt = null
	var/corpsepocket1 = null
	var/corpsepocket2 = null
	var/corpseback = null
	var/corpseid = 0     //Just set to 1 if you want them to have an ID
	var/corpseidjob = null // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/corpseidaccess = null //This is for access. See access.dm for which jobs give what access. Again, put in quotes. Use "Captain" if you want it to be all access.
	var/corpseidicon = null //For setting it to be a gold, silver, centcom etc ID
	var/corpsehusk = null
	var/corpsebrute = null //set brute damage on the corpse
	var/corpseoxy = null //set suffocation damage on the corpse
	var/roundstart = TRUE
	var/death = TRUE
	var/flavour_text = "The mapper forgot to set this!"
	var/faction = null
	var/list/implants = list()
	density = 1

/obj/effect/landmark/corpse/initialize()
	if(roundstart)
		createCorpse(death = src.death)
	else
		return

/obj/effect/landmark/corpse/New()
	..()
	invisibility = 0

/obj/effect/landmark/corpse/proc/createCorpse(death, ckey) //Creates a mob and checks for gear in each slot before attempting to equip it.
	var/mob/living/carbon/human/M = new /mob/living/carbon/human (src.loc)
	if(mobname != "default")
		M.real_name = mobname
	else
		M.real_name = src.name
	M.gender = src.mobgender
	if(mob_species)
		M.set_species(mob_species)
	if(death)
		M.death(1) //Kills the new mob
		if(src.corpsehusk)
			M.Drain()
	if(faction)
		M.faction = list(src.faction)
	M.adjustBruteLoss(src.corpsebrute)
	M.adjustOxyLoss(src.corpseoxy)
	if(src.corpseuniform)
		M.equip_to_slot_or_del(new src.corpseuniform(M), slot_w_uniform)
	if(src.corpsesuit)
		M.equip_to_slot_or_del(new src.corpsesuit(M), slot_wear_suit)
	if(src.corpseshoes)
		M.equip_to_slot_or_del(new src.corpseshoes(M), slot_shoes)
	if(src.corpsegloves)
		M.equip_to_slot_or_del(new src.corpsegloves(M), slot_gloves)
	if(src.corpseradio)
		M.equip_to_slot_or_del(new src.corpseradio(M), slot_ears)
	if(src.corpseglasses)
		M.equip_to_slot_or_del(new src.corpseglasses(M), slot_glasses)
	if(src.corpsemask)
		M.equip_to_slot_or_del(new src.corpsemask(M), slot_wear_mask)
	if(src.corpsehelmet)
		M.equip_to_slot_or_del(new src.corpsehelmet(M), slot_head)
	if(src.corpsebelt)
		M.equip_to_slot_or_del(new src.corpsebelt(M), slot_belt)
	if(src.corpsepocket1)
		M.equip_to_slot_or_del(new src.corpsepocket1(M), slot_r_store)
	if(src.corpsepocket2)
		M.equip_to_slot_or_del(new src.corpsepocket2(M), slot_l_store)
	if(src.corpseback)
		M.equip_to_slot_or_del(new src.corpseback(M), slot_back)
	if(src.corpseid == 1)
		var/obj/item/weapon/card/id/W = new(M)
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(J.title == corpseidaccess)
				jobdatum = J
				break
		if(src.corpseidicon)
			W.icon_state = corpseidicon
		if(src.corpseidaccess)
			if(jobdatum)
				W.access = jobdatum.get_access()
			else
				W.access = list()
		if(corpseidjob)
			W.assignment = corpseidjob
		W.registered_name = M.real_name
		W.update_label()
		M.equip_to_slot_or_del(W, slot_wear_id)

	for(var/I in implants)
		var/obj/item/weapon/implant/X = new I
		X.implant(M)

	if(ckey)
		M.ckey = ckey
		M << "[flavour_text]"
	qdel(src)

/obj/effect/landmark/corpse/AICorpse/createCorpse() //Creates a corrupted AI
	var/A = locate(/mob/living/silicon/ai) in loc //variable A looks for an AI at the location of the landmark
	if(A) //if variable A is true
		return //stop executing the proc
	var/L = new /datum/ai_laws/default/asimov/ //variable L is a new Asimov lawset
	var/B = new /obj/item/device/mmi/ //variable B is a new MMI
	var/mob/living/silicon/ai/M = new(src.loc, L, B, 1) //spawn new AI at landmark as var M
	M.name = src.name
	M.real_name = src.name
	M.aiPDA.toff = 1 //turns the AI's PDA messenger off, stopping it showing up on player PDAs
	M.death() //call the AI's death proc
	qdel(src)

/obj/effect/landmark/corpse/slimeCorpse
	var/mobcolour = "grey"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime" //sets the icon in the map editor

/obj/effect/landmark/corpse/slimeCorpse/createCorpse() //proc creates a dead slime
	var/A = locate(/mob/living/simple_animal/slime/) in loc //variable A looks for a slime at the location of the landmark
	if(A) //if variable A is true
		return //stop executing the proc
	var/mob/living/simple_animal/slime/M = new(src.loc) //variable M is a new slime at the location of the landmark
	M.colour = src.mobcolour //slime colour is set by landmark's mobcolour var
	M.adjustToxLoss(9001) //kills the slime, death() doesn't update its icon correctly
	qdel(src)

/obj/effect/landmark/corpse/facehugCorpse/createCorpse() //Creates a squashed facehugger
	var/obj/item/clothing/mask/facehugger/O = new(src.loc) //variable O is a new facehugger at the location of the landmark
	O.name = src.name
	O.Die() //call the facehugger's death proc
	qdel(src)


// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.

/obj/effect/landmark/corpse/syndicatesoldier
	name = "Syndicate Operative"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/swat
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



/obj/effect/landmark/corpse/syndicatecommando
	name = "Syndicate Commando"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/space/hardsuit/syndi
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/syndicate
	corpsehelmet = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	corpseback = /obj/item/weapon/tank/jetpack/oxygen
	corpsepocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



///////////Civilians//////////////////////

/obj/effect/landmark/corpse/cook
	name = "Cook"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/apron/chef
	corpseshoes = /obj/item/clothing/shoes/sneakers/black
	corpsehelmet = /obj/item/clothing/head/chefhat
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Cook"
	corpseidaccess = "Cook"


/obj/effect/landmark/corpse/doctor
	name = "Doctor"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/medical
	corpsesuit = /obj/item/clothing/suit/toggle/labcoat
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/sneakers/black
	corpseid = 1
	corpseidjob = "Medical Doctor"
	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpse/engineer
	name = "Engineer"
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseuniform = /obj/item/clothing/under/rank/engineer
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/sneakers/orange
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/color/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Station Engineer"
	corpseidaccess = "Station Engineer"

/obj/effect/landmark/corpse/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/hardsuit/engine
	corpsemask = /obj/item/clothing/mask/breath

/obj/effect/landmark/corpse/clown
	name = "Clown"
	corpseuniform = /obj/item/clothing/under/rank/clown
	corpseshoes = /obj/item/clothing/shoes/clown_shoes
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/clown_hat
	corpsepocket1 = /obj/item/weapon/bikehorn
	corpseback = /obj/item/weapon/storage/backpack/clown
	corpseid = 1
	corpseidjob = "Clown"
	corpseidaccess = "Clown"

/obj/effect/landmark/corpse/scientist
	name = "Scientist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/toggle/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/sneakers/white
	corpseid = 1
	corpseidjob = "Scientist"
	corpseidaccess = "Scientist"

/obj/effect/landmark/corpse/miner
	corpseradio = /obj/item/device/radio/headset/headset_cargo
	corpseuniform = /obj/item/clothing/under/rank/miner
	corpsegloves = /obj/item/clothing/gloves/fingerless
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/sneakers/black
	corpseid = 1
	corpseidjob = "Shaft Miner"
	corpseidaccess = "Shaft Miner"

/obj/effect/landmark/corpse/miner/rig
	corpsesuit = /obj/item/clothing/suit/space/hardsuit/mining
	corpsemask = /obj/item/clothing/mask/breath


/obj/effect/landmark/corpse/plasmaman
	mob_species = /datum/species/plasmaman
	corpsehelmet = /obj/item/clothing/head/helmet/space/plasmaman
	corpseuniform = /obj/item/clothing/under/plasmaman
	corpseback = /obj/item/weapon/tank/internals/plasmaman/full
	corpsemask = /obj/item/clothing/mask/breath



/////////////////Officers+Nanotrasen Security//////////////////////

/obj/effect/landmark/corpse/bridgeofficer
	name = "Bridge Officer"
	corpseradio = /obj/item/device/radio/headset/heads/hop
	corpseuniform = /obj/item/clothing/under/rank/centcom_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseshoes = /obj/item/clothing/shoes/sneakers/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Bridge Officer"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/commander
	name = "Commander"
	corpseuniform = /obj/item/clothing/under/rank/centcom_commander
	corpsesuit = /obj/item/clothing/suit/armor
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseshoes = /obj/item/clothing/shoes/combat/swat
	corpsepocket1 = /obj/item/weapon/lighter
	corpseid = 1
	corpseidjob = "Commander"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/nanotrasensoldier
	name = "Nanotrasen Private Security Officer"
	corpseuniform = /obj/item/clothing/under/rank/security
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/sechailer/swat
	corpsehelmet = /obj/item/clothing/head/helmet/swat/nanotrasen
	corpseback = /obj/item/weapon/storage/backpack/security
	corpseid = 1
	corpseidjob = "Private Security Force"
	corpseidaccess = "Security Officer"


/obj/effect/landmark/corpse/commander/alive
	death = FALSE
	roundstart = FALSE
	mobname = "Nanotrasen Commander"
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a Nanotrasen Commander!"

/obj/effect/landmark/corpse/attack_ghost(mob/user)
	if(ticker.current_state != GAME_STATE_PLAYING)
		return
	var/ghost_role = alert("Become [mobname]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No")
		return
	createCorpse(death = src.death, ckey = user.ckey)

/////////////////Spooky Undead//////////////////////

/obj/effect/landmark/corpse/skeleton
	name = "skeletal remains"
	mobname = "skeleton"
	mob_species = /datum/species/skeleton
	mobgender = NEUTER


/obj/effect/landmark/corpse/skeleton/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	flavour_text = "By unknown powers, your skeletal remains have been reanimated! Walk this mortal plain and terrorize all living adventurers who dare cross your path."


/obj/effect/landmark/corpse/zombie
	name = "rotting corpse"
	mobname = "zombie"
	mob_species = /datum/species/zombie

/obj/effect/landmark/corpse/zombie/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	flavour_text = "By unknown powers, your rotting remains have been resurrected! Walk this mortal plain and terrorize all living adventurers who dare cross your path."


/obj/effect/landmark/corpse/abductor
	name = "abductor"
	mobname = "???"
	mob_species = /datum/species/abductor
	corpseuniform = /obj/item/clothing/under/color/grey
	corpseshoes = /obj/item/clothing/shoes/combat
