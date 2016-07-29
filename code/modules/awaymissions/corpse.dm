<<<<<<< HEAD
//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/mob_spawn
	name = "Unknown"
	var/mob_type = null
	var/mob_name = ""
	var/mob_gender = null
	var/death = TRUE //Kill the mob
	var/roundstart = TRUE //fires on initialize
	var/instant = FALSE	//fires on New
	var/flavour_text = "The mapper forgot to set this!"
	var/faction = null
	var/permanent = FALSE	//If true, the spawner will not disappear upon running out of uses.
	var/random = FALSE		//Don't set a name or gender, just go random
	var/objectives = null
	var/uses = 1			//how many times can we spawn from it. set to -1 for infinite.
	var/brute_damage = 0
	var/oxy_damage = 0
	density = 1
	anchored = 1

/obj/effect/mob_spawn/attack_ghost(mob/user)
	if(ticker.current_state != GAME_STATE_PLAYING || !loc)
		return
	if(!uses)
		user << "<span class='warning'>This spawner is out of charges!</span>"
		return
	if(jobban_isbanned(user, "lavaland"))
		user << "<span class='warning'>You are jobanned!</span>"
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No" || !loc)
		return
	log_game("[user.ckey] became [mob_name]")
	create(ckey = user.ckey)

/obj/effect/mob_spawn/spawn_atom_to_world()
	//We no longer need to spawn mobs, deregister ourself
	SSobj.atom_spawners -= src
	if(roundstart)
		create()
	else
		poi_list |= src

/obj/effect/mob_spawn/New()
	..()
	if(roundstart)
		//Add to the atom spawners register for roundstart atom spawning
		SSobj.atom_spawners += src

	if(instant)
		create()
	else
		poi_list |= src

/obj/effect/mob_spawn/Destroy()
	poi_list.Remove(src)
	. = ..()

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/mob_spawn/proc/create(ckey)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	if(!random)
		M.real_name = mob_name ? mob_name : M.name
		if(!mob_gender)
			mob_gender = pick(MALE, FEMALE)
		M.gender = mob_gender
	if(faction)
		M.faction = list(faction)
	if(death)
		M.death(1) //Kills the new mob

	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	equip(M)

	if(ckey)
		M.ckey = ckey
		M << "[flavour_text]"
		var/datum/mind/MM = M.mind
		if(objectives)
			for(var/objective in objectives)
				MM.objectives += new/datum/objective(objective)
		special(M)
		MM.name = M.real_name
	if(uses > 0)
		uses--
	if(!permanent && !uses)
		qdel(src)

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null //Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/uniform = null //Set this to an object path to have the slot filled with said object on the corpse.
	var/r_hand = null
	var/l_hand = null
	var/suit = null
	var/shoes = null
	var/gloves = null
	var/radio = null
	var/glasses = null
	var/mask = null
	var/helmet = null
	var/belt = null
	var/pocket1 = null
	var/pocket2 = null
	var/back = null
	var/has_id = 0     //Just set to 1 if you want them to have an ID
	var/id_job = null // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/id_access = null //This is for access. See access.dm for which jobs give what access. Again, put in quotes. Use "Captain" if you want it to be all access.
	var/id_icon = null //For setting it to be a gold, silver, centcom etc ID
	var/husk = null
	var/outfit_type = null // Will start with this if exists then apply specific slots
	var/list/implants = list()

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(husk)
		H.Drain()
	if(outfit_type)
		H.equipOutfit(outfit_type)
	if(uniform)
		H.equip_to_slot_or_del(new uniform(H), slot_w_uniform)
	if(suit)
		H.equip_to_slot_or_del(new suit(H), slot_wear_suit)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H), slot_shoes)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H), slot_gloves)
	if(radio)
		H.equip_to_slot_or_del(new radio(H), slot_ears)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H), slot_glasses)
	if(mask)
		H.equip_to_slot_or_del(new mask(H), slot_wear_mask)
	if(helmet)
		H.equip_to_slot_or_del(new helmet(H), slot_head)
	if(belt)
		H.equip_to_slot_or_del(new belt(H), slot_belt)
	if(pocket1)
		H.equip_to_slot_or_del(new pocket1(H), slot_r_store)
	if(pocket2)
		H.equip_to_slot_or_del(new pocket2(H), slot_l_store)
	if(back)
		H.equip_to_slot_or_del(new back(H), slot_back)
	if(l_hand)
		H.equip_to_slot_or_del(new l_hand(H), slot_l_hand)
	if(r_hand)
		H.equip_to_slot_or_del(new r_hand(H), slot_r_hand)
	if(has_id)
		var/obj/item/weapon/card/id/W = new(H)
		if(id_icon)
			W.icon_state = id_icon
		if(id_access)
			var/datum/job/jobdatum
			for(var/jobtype in typesof(/datum/job))
				var/datum/job/J = new jobtype
				if(J.title == id_access)
					jobdatum = J
					break
=======
#define G_MALE   0
#define G_FEMALE 1
#define G_BOTH   2

/obj/effect/landmark/corpse
	name = "Unknown"
	var/mobname = "Unknown"  //Unused now but it'd fuck up maps to remove it now

	var/generate_random_mob_name = 0
	var/generate_random_appearance = 0

	var/corpsegender = G_MALE

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
	var/corpseidicon = null //For setting it to be a gold, silver, centcomm etc ID
	var/mutantrace = null

	var/suit_sensors = 0 //-1 - default for the jumpsuit. 0, 1, 2, 3 - disabled, binary, vitals, tracker
	var/husk = 0

	var/oxy_dmg = 200
	var/brute_dmg = 0
	var/burn_dmg = 0
	var/toxin_dmg = 0

/obj/effect/landmark/corpse/New()
	if(ticker)
		initialize()

/obj/effect/landmark/corpse/initialize()
	var/mob/living/carbon/human/H = createCorpse()
	equipCorpse(H)


/obj/effect/landmark/corpse/proc/createCorpse() //Creates a mob and checks for gear in each slot before attempting to equip it.
	var/mob/living/carbon/human/M = new /mob/living/carbon/human(loc, mutantrace)

	M.dna.mutantrace = mutantrace
	M.real_name = src.name

	switch(corpsegender)
		if(G_BOTH)
			M.setGender(pick(MALE, FEMALE))
		if(G_MALE)
			M.setGender(MALE)
		if(G_FEMALE)
			M.setGender(FEMALE)

	if(generate_random_mob_name)
		M.real_name = random_name(M.gender, mutantrace)

	M.adjustOxyLoss(oxy_dmg) //Kills the new mob
	M.adjustBruteLoss(brute_dmg)
	M.adjustFireLoss(burn_dmg)
	M.adjustToxLoss(toxin_dmg)

	M.iscorpse = 1

	if(generate_random_appearance)
		M.dna.ResetSE()
		M.dna.ResetUI()
		M.dna.real_name = M.real_name
		M.dna.unique_enzymes = md5(M.real_name)

		M.dna.SetUIState(DNA_UI_GENDER, M.gender != MALE, 1)

		M.dna.UpdateUI()
		M.UpdateAppearance()

	if(husk)
		M.ChangeToHusk()

	qdel(src)
	return M

/obj/effect/landmark/corpse/proc/equipCorpse(mob/living/carbon/human/M)
	if(src.corpseuniform)
		var/list/L = src.corpseuniform

		if(istype(L)) src.corpseuniform = pick(L)

		var/obj/item/clothing/under/U = new src.corpseuniform(M)

		if(suit_sensors != -1)
			U.sensor_mode = suit_sensors

		M.equip_to_slot_or_del(U, slot_w_uniform)

	if(src.corpsesuit)
		var/list/L = src.corpsesuit

		if(istype(L)) src.corpsesuit = pick(L)
		M.equip_to_slot_or_del(new src.corpsesuit(M), slot_wear_suit)

	if(src.corpseshoes)
		var/list/L = src.corpseshoes

		if(istype(L)) src.corpseshoes = pick(L)
		M.equip_to_slot_or_del(new src.corpseshoes(M), slot_shoes)

	if(src.corpsegloves)
		var/list/L = src.corpsegloves

		if(istype(L)) src.corpsegloves = pick(L)
		M.equip_to_slot_or_del(new src.corpsegloves(M), slot_gloves)

	if(src.corpseradio)
		var/list/L = src.corpseradio

		if(istype(L)) src.corpseradio = pick(L)
		M.equip_to_slot_or_del(new src.corpseradio(M), slot_ears)

	if(src.corpseglasses)
		var/list/L = src.corpseglasses

		if(istype(L)) src.corpseglasses = pick(L)
		M.equip_to_slot_or_del(new src.corpseglasses(M), slot_glasses)

	if(src.corpsemask)
		var/list/L = src.corpsemask

		if(istype(L)) src.corpsemask = pick(L)
		M.equip_to_slot_or_del(new src.corpsemask(M), slot_wear_mask)

	if(src.corpsehelmet)
		var/list/L = src.corpsehelmet

		if(istype(L)) src.corpsehelmet = pick(L)

		M.equip_to_slot_or_del(new src.corpsehelmet(M), slot_head)

	if(src.corpsebelt)
		var/list/L = src.corpsebelt

		if(istype(L)) src.corpsebelt = pick(L)
		M.equip_to_slot_or_del(new src.corpsebelt(M), slot_belt)

	if(src.corpsepocket1)
		var/list/L = src.corpsepocket1

		if(istype(L)) src.corpsepocket1 = pick(L)
		M.equip_to_slot_or_del(new src.corpsepocket1(M), slot_r_store)

	if(src.corpsepocket2)
		var/list/L = src.corpsepocket2

		if(istype(L)) src.corpsepocket2 = pick(L)
		M.equip_to_slot_or_del(new src.corpsepocket2(M), slot_l_store)

	if(src.corpseback)
		var/list/L = src.corpseback

		if(istype(L)) src.corpseback = pick(L)

		M.equip_to_slot_or_del(new src.corpseback(M), slot_back)

	if(src.corpseid == 1)
		var/obj/item/weapon/card/id/W = new(M)
		W.name = "[M.real_name]'s ID Card"
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(J.title == corpseidaccess)
				jobdatum = J
				break
		if(src.corpseidicon)
			W.icon_state = corpseidicon
		if(src.corpseidaccess)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(jobdatum)
				W.access = jobdatum.get_access()
			else
				W.access = list()
<<<<<<< HEAD
		if(id_job)
			W.assignment = id_job
		W.registered_name = H.real_name
		W.update_label()
		H.equip_to_slot_or_del(W, slot_wear_id)

	for(var/I in implants)
		var/obj/item/weapon/implant/X = new I
		X.implant(H)

//Instant version - use when spawning corpses during runtime
/obj/effect/mob_spawn/human/corpse
	roundstart = FALSE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/damaged
	brute_damage = 1000

/obj/effect/mob_spawn/human/alive
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	death = FALSE
	roundstart = FALSE //you could use these for alive fake humans on roundstart but this is more common scenario


//Non-human spawners

/obj/effect/mob_spawn/AICorpse/create() //Creates a corrupted AI
	var/A = locate(/mob/living/silicon/ai) in loc
	if(A)
		return
	var/L = new /datum/ai_laws/default/asimov
	var/B = new /obj/item/device/mmi
	var/mob/living/silicon/ai/M = new(src.loc, L, B, 1) //spawn new AI at landmark as var M
	M.name = src.name
	M.real_name = src.name
	M.aiPDA.toff = 1 //turns the AI's PDA messenger off, stopping it showing up on player PDAs
	M.death() //call the AI's death proc
	qdel(src)

/obj/effect/mob_spawn/slime
	mob_type = 	/mob/living/simple_animal/slime
	var/mobcolour = "grey"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime" //sets the icon in the map editor

/obj/effect/mob_spawn/slime/equip(mob/living/simple_animal/slime/S)
	S.colour = mobcolour

/obj/effect/mob_spawn/human/facehugger/create() //Creates a squashed facehugger
	var/obj/item/clothing/mask/facehugger/O = new(src.loc) //variable O is a new facehugger at the location of the landmark
	O.name = src.name
	O.Die() //call the facehugger's death proc
	qdel(src)

/obj/effect/mob_spawn/mouse
	name = "sleeper"
	mob_type = 	/mob/living/simple_animal/mouse
	death = FALSE
	roundstart = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/cow
	name = "sleeper"
	mob_type = 	/mob/living/simple_animal/cow
	death = FALSE
	roundstart = FALSE
	mob_gender = FEMALE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.

/obj/effect/mob_spawn/human/syndicatesoldier
	name = "Syndicate Operative"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas
	helmet = /obj/item/clothing/head/helmet/swat
	back = /obj/item/weapon/storage/backpack
	has_id = 1
	id_job = "Operative"
	id_access = "Syndicate"

/obj/effect/mob_spawn/human/syndicatecommando
	name = "Syndicate Commando"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	helmet = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	back = /obj/item/weapon/tank/jetpack/oxygen
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	has_id = 1
	id_job = "Operative"
	id_access = "Syndicate"

///////////Civilians//////////////////////

/obj/effect/mob_spawn/human/cook
	name = "Cook"
	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/apron/chef
	shoes = /obj/item/clothing/shoes/sneakers/black
	helmet = /obj/item/clothing/head/chefhat
	back = /obj/item/weapon/storage/backpack
	radio = /obj/item/device/radio/headset
	has_id = 1
	id_job = "Cook"
	id_access = "Cook"


/obj/effect/mob_spawn/human/doctor
	name = "Doctor"
	radio = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/weapon/storage/backpack/medic
	pocket1 = /obj/item/device/flashlight/pen
	shoes = /obj/item/clothing/shoes/sneakers/black
	has_id = 1
	id_job = "Medical Doctor"
	id_access = "Medical Doctor"

/obj/effect/mob_spawn/human/doctor/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	radio = null
	back = null
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space doctor!"


/obj/effect/mob_spawn/human/engineer
	name = "Engineer"
	radio = /obj/item/device/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineer
	back = /obj/item/weapon/storage/backpack/industrial
	shoes = /obj/item/clothing/shoes/sneakers/orange
	belt = /obj/item/weapon/storage/belt/utility/full
	gloves = /obj/item/clothing/gloves/color/yellow
	helmet = /obj/item/clothing/head/hardhat
	has_id = 1
	id_job = "Station Engineer"
	id_access = "Station Engineer"

/obj/effect/mob_spawn/human/engineer/rig
	suit = /obj/item/clothing/suit/space/hardsuit/engine
	mask = /obj/item/clothing/mask/breath

/obj/effect/mob_spawn/human/clown
	name = "Clown"
	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas/clown_hat
	pocket1 = /obj/item/weapon/bikehorn
	back = /obj/item/weapon/storage/backpack/clown
	has_id = 1
	id_job = "Clown"
	id_access = "Clown"

/obj/effect/mob_spawn/human/scientist
	name = "Scientist"
	radio = /obj/item/device/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/scientist
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/white
	has_id = 1
	id_job = "Scientist"
	id_access = "Scientist"

/obj/effect/mob_spawn/human/miner
	radio = /obj/item/device/radio/headset/headset_cargo/mining
	uniform = /obj/item/clothing/under/rank/miner
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/weapon/storage/backpack/industrial
	shoes = /obj/item/clothing/shoes/sneakers/black
	has_id = 1
	id_job = "Shaft Miner"
	id_access = "Shaft Miner"

/obj/effect/mob_spawn/human/miner/rig
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	mask = /obj/item/clothing/mask/breath

/obj/effect/mob_spawn/human/miner/explorer
	uniform = /obj/item/clothing/under/rank/miner/lavaland
	back = /obj/item/weapon/storage/backpack/explorer
	shoes = /obj/item/clothing/shoes/workboots/mining
	suit = /obj/item/clothing/suit/hooded/explorer
	mask = /obj/item/clothing/mask/gas/explorer
	belt = /obj/item/weapon/gun/energy/kinetic_accelerator

/obj/effect/mob_spawn/human/plasmaman
	mob_species = /datum/species/plasmaman
	helmet = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman
	back = /obj/item/weapon/tank/internals/plasmaman/full
	mask = /obj/item/clothing/mask/breath


/obj/effect/mob_spawn/human/bartender
	name = "Space Bartender"
	uniform = /obj/item/clothing/under/rank/bartender
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	has_id = 1
	id_job = "Bartender"
	id_access = "Bartender"

/obj/effect/mob_spawn/human/bartender/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "bartender sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space bartender!"

/obj/effect/mob_spawn/human/beach
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform = /obj/item/clothing/under/shorts/red
	pocket1 = /obj/item/weapon/storage/wallet/random

/obj/effect/mob_spawn/human/beach/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	mob_name = "Beach Bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a beach bum!"

/////////////////Officers+Nanotrasen Security//////////////////////

/obj/effect/mob_spawn/human/bridgeofficer
	name = "Bridge Officer"
	radio = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom_officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/sunglasses
	has_id = 1
	id_job = "Bridge Officer"
	id_access = "Captain"

/obj/effect/mob_spawn/human/commander
	name = "Commander"
	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	radio = /obj/item/device/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	helmet = /obj/item/clothing/head/centhat
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat/swat
	pocket1 = /obj/item/weapon/lighter
	has_id = 1
	id_job = "Commander"
	id_access = "Captain"

/obj/effect/mob_spawn/human/nanotrasensoldier
	name = "Nanotrasen Private Security Officer"
	uniform = /obj/item/clothing/under/rank/security
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	helmet = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/weapon/storage/backpack/security
	has_id = 1
	id_job = "Private Security Force"
	id_access = "Security Officer"

/obj/effect/mob_spawn/human/commander/alive
	death = FALSE
	roundstart = FALSE
	mob_name = "Nanotrasen Commander"
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a Nanotrasen Commander!"

/////////////////Spooky Undead//////////////////////

/obj/effect/mob_spawn/human/skeleton
	name = "skeletal remains"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton
	mob_gender = NEUTER

/obj/effect/mob_spawn/human/skeleton/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	flavour_text = "By unknown powers, your skeletal remains have been reanimated! Walk this mortal plain and terrorize all living adventurers who dare cross your path."

/obj/effect/mob_spawn/human/zombie
	name = "rotting corpse"
	mob_name = "zombie"
	mob_species = /datum/species/zombie

/obj/effect/mob_spawn/human/zombie/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	flavour_text = "By unknown powers, your rotting remains have been resurrected! Walk this mortal plain and terrorize all living adventurers who dare cross your path."


/obj/effect/mob_spawn/human/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat

//For ghost bar.
/obj/effect/mob_spawn/human/alive/space_bar_patron
	name = "Bar cryogenics"
	mob_name = "Bar patron"
	random = TRUE
	permanent = TRUE
	uses = -1
	uniform = /obj/item/clothing/under/rank/bartender
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/reagent

/obj/effect/mob_spawn/human/alive/space_bar_patron/attack_hand(mob/user)
	var/despawn = alert("Return to cryosleep? (Warning, Your mob will be deleted!)",,"Yes","No")
	if(despawn == "No" || !loc || !Adjacent(user))
		return
	user.visible_message("<span class='notice'>[user.name] climbs back into cryosleep...</span>")
	qdel(user)
=======
		if(corpseidjob)
			W.assignment = corpseidjob
		W.registered_name = M.real_name
		M.equip_to_slot_or_del(W, slot_wear_id)

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.





/obj/effect/landmark/corpse/syndicatesoldier
	name = "Syndicate Operative"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/tactical/swat
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



/obj/effect/landmark/corpse/syndicatecommando
	name = "Syndicate Commando"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/space/rig/syndi
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/syndicate
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/syndi
	corpseback = /obj/item/weapon/tank/jetpack/oxygen
	corpsepocket1 = /obj/item/weapon/tank/emergency_oxygen
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



///////////Civilians//////////////////////

/obj/effect/landmark/corpse/chef
	name = "Chef"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/chef/classic
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/chefhat
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Chef"
	corpseidaccess = "Chef"


/obj/effect/landmark/corpse/doctor
	name = "Doctor"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/medical
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Medical Doctor"
	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpse/engineer
	name = "Engineer"
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseuniform = /obj/item/clothing/under/rank/engineer
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/orange
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Station Engineer"
	corpseidaccess = "Station Engineer"

/obj/effect/landmark/corpse/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig

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

/obj/effect/landmark/corpse/mime
	name = "Mime"
	corpseuniform = /obj/item/clothing/under/mime
	corpseshoes = /obj/item/clothing/shoes/black
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/mime
	corpsegloves = /obj/item/clothing/gloves/white/stunglove // Spawn with empty, crappy batteries.
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Mime"
	corpseidaccess = "Mime"

/obj/effect/landmark/corpse/scientist
	name = "Scientist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Scientist"
	corpseidaccess = "Scientist"

/obj/effect/landmark/corpse/scientist/voxresearch
	name = "Research Geneticist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 0

/obj/effect/landmark/corpse/miner
	corpseradio = /obj/item/device/radio/headset/headset_mining
	corpseuniform = /obj/item/clothing/under/rank/miner
	corpsegloves = /obj/item/clothing/gloves/black
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Shaft Miner"
	corpseidaccess = "Shaft Miner"

/obj/effect/landmark/corpse/miner/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/mining
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/mining


/////////////////Officers//////////////////////

/obj/effect/landmark/corpse/bridgeofficer
	name = "Bridge Officer"
	corpseradio = /obj/item/device/radio/headset/heads/hop
	corpseuniform = /obj/item/clothing/under/rank/centcom_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseshoes = /obj/item/clothing/shoes/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Bridge Officer"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/commander
	name = "Commander"
	corpseuniform = /obj/item/clothing/under/rank/centcom_commander
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsepocket1 = /obj/item/weapon/lighter/zippo
	corpseid = 1
	corpseidjob = "Commander"
	corpseidaccess = "Captain"

/////////////////Simple-Mob Corpses/////////////////////

/obj/effect/landmark/corpse/pirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/pirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsehelmet = /obj/item/clothing/head/bandana

/obj/effect/landmark/corpse/pirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/pirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsehelmet = /obj/item/clothing/head/bandana

/obj/effect/landmark/corpse/pirate/ranged
	name = "Pirate Gunner"
	corpsesuit = /obj/item/clothing/suit/pirate
	corpsehelmet = /obj/item/clothing/head/pirate

/obj/effect/landmark/corpse/russian
	name = "Russian"
	corpseuniform = /obj/item/clothing/under/soviet
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsehelmet = /obj/item/clothing/head/bearpelt/real

/obj/effect/landmark/corpse/russian/ranged
	corpsehelmet = /obj/item/clothing/head/ushanka

//////////////////Misc Corpses///////////////////////////

/obj/effect/landmark/corpse/civilian //Random corpse!
	name = "Civilian"
	generate_random_mob_name = 1
	generate_random_appearance = 1
	corpsegender = G_BOTH

	corpseuniform = list(/obj/item/clothing/under/aqua, /obj/item/clothing/under/casualhoodie, /obj/item/clothing/under/casualwear,\
	/obj/item/clothing/under/darkblue, /obj/item/clothing/under/darkred, /obj/item/clothing/under/libertyshirt,\
	/obj/item/clothing/under/keyholesweater, /obj/item/clothing/under/greaser, /obj/item/clothing/under/russobluecamooutfit,\
	/obj/item/clothing/under/sl_suit, /obj/item/clothing/under/waiter)

	corpsehelmet = list(/obj/item/clothing/head/bandana, /obj/item/clothing/head/beret, /obj/item/clothing/head/cowboy, /obj/item/clothing/head/fedora,\
	/obj/item/clothing/head/flatcap, /obj/item/clothing/head/russobluecamohat)

	corpsegloves = list(/obj/item/clothing/gloves/black, /obj/item/clothing/gloves/grey, /obj/item/clothing/gloves/green, /obj/item/clothing/gloves/orange, /obj/item/clothing/gloves/purple,\
	/obj/item/clothing/gloves/red, /obj/item/clothing/gloves/latex)

	corpseglasses = list(/obj/item/clothing/glasses/gglasses, /obj/item/clothing/glasses/hud/health, /obj/item/clothing/glasses/monocle, /obj/item/clothing/glasses/regular, /obj/item/clothing/glasses/regular/hipster,\
	/obj/item/clothing/glasses/science, /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/sunglasses/big)

	corpseshoes = list(/obj/item/clothing/shoes/black, /obj/item/clothing/shoes/blue, /obj/item/clothing/shoes/brown, /obj/item/clothing/shoes/combat, /obj/item/clothing/shoes/galoshes, /obj/item/clothing/shoes/green,\
	/obj/item/clothing/shoes/jackboots, /obj/item/clothing/shoes/laceup, /obj/item/clothing/shoes/leather, /obj/item/clothing/shoes/orange, /obj/item/clothing/shoes/purple, /obj/item/clothing/shoes/red, /obj/item/clothing/shoes/white)

	corpsesuit = list(/obj/item/clothing/suit/doshjacket, /obj/item/clothing/suit/ianshirt, /obj/item/clothing/suit/simonjacket, /obj/item/clothing/suit/storage/lawyer/bluejacket, /obj/item/clothing/suit/storage/lawyer/purpjacket)

	corpsemask = /obj/item/clothing/mask/breath

/obj/effect/landmark/corpse/vox
	name = "Dead vox"
	mutantrace = "Vox"
	generate_random_mob_name = 1
	generate_random_appearance = 1
	corpsegender = G_BOTH
	burn_dmg = 100

/obj/effect/landmark/corpse/civilian/New()
	corpseuniform += existing_typesof(/obj/item/clothing/under/color)
	corpsehelmet += existing_typesof(/obj/item/clothing/head/soft)

	return ..()

/obj/effect/landmark/corpse/civilian/createCorpse()
	. = ..()

	var/mob/M = .
	if(M.gender == FEMALE)
		corpseuniform += existing_typesof(/obj/item/clothing/under/dress)

	if(prob(50))
		corpsemask = null
	if(prob(60))
		corpsesuit = null
	if(prob(60))
		corpsehelmet = null
	if(prob(70))
		corpsegloves = null
	if(prob(80))
		corpseglasses = null

/obj/effect/landmark/corpse/mutilated
	husk = 1
	brute_dmg = 250
	burn_dmg = 100

#undef G_MALE
#undef G_FEMALE
#undef G_BOTH
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
