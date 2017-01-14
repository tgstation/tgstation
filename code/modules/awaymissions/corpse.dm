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
		if(ticker && ticker.current_state > GAME_STATE_SETTING_UP)
			// The game has already initialised, just spawn it.
			create()
		else
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
	var/mob_species = null		//Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/outfit_type = null		//Will start with this if exists then apply specific slots. Job outfits are generated with IDs and disabled PDAs.
	var/uniform = null			//Set this to an object path to have the slot filled with said object on the corpse.
	var/r_hand = null
	var/l_hand = null
	var/suit = null
	var/shoes = null
	var/gloves = null
	var/radio = null
	var/glasses = null
	var/mask = null
	var/neck = null
	var/helmet = null
	var/belt = null
	var/pocket1 = null
	var/pocket2 = null
	var/back = null
	var/has_id = FALSE			//Set to TRUE if you want them to have an ID
	var/id_job = null			//Such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/id_access = null		//This is for access. See access.dm for which jobs give what access. Use "Captain" if you want it to be all access.
	var/id_access_list = null	//Allows you to manually add access to an ID card.
	var/id_icon = null			//For setting it to be a gold, silver, centcom etc ID
	var/husk = null
	var/list/implants = list()

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(husk)
		H.Drain()

	if(outfit_type)
		H.equipOutfit(outfit_type)

		// We don't want corpse PDAs to show up in the messenger list.
		var/obj/item/device/pda/PDA = locate(/obj/item/device/pda) in H
		if(PDA)
			PDA.toff = TRUE

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
	if(neck)
		H.equip_to_slot_or_del(new neck(H), slot_neck)
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
		H.put_in_hands_or_del(new l_hand(H))
	if(r_hand)
		H.put_in_hands_or_del(new r_hand(H))
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
			if(jobdatum)
				W.access = jobdatum.get_access()
			else
				W.access = list()
			if(id_access_list)
				if(!W.access)
					W.access = list()
				W.access |= id_access_list
		if(id_job)
			W.assignment = id_job
		W.registered_name = H.real_name
		W.update_label()
		H.equip_to_slot_or_del(W, slot_wear_id)

	for(var/I in implants)
		var/obj/item/weapon/implant/X = new I
		X.implant(H)

	if(!H.head && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()

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
	var/mob/living/silicon/ai/spawned/M = new(loc) //spawn new AI at landmark as var M
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
	id_access_list = list(access_syndicate)

/obj/effect/mob_spawn/human/syndicatecommando
	name = "Syndicate Commando"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/weapon/tank/jetpack/oxygen
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	has_id = 1
	id_job = "Operative"
	id_access_list = list(access_syndicate)

///////////Civilians//////////////////////

/obj/effect/mob_spawn/human/cook
	name = "Cook"
	outfit_type = /datum/outfit/job/cook


/obj/effect/mob_spawn/human/doctor
	name = "Doctor"
	outfit_type = /datum/outfit/job/doctor


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

/obj/effect/mob_spawn/human/doctor/alive/equip(mob/living/carbon/human/H)
	..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/device/pda, /obj/item/device/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/I = locate(del_type) in H
		qdel(I)

/obj/effect/mob_spawn/human/engineer
	name = "Engineer"
	outfit_type = /datum/outfit/job/engineer
	gloves = /obj/item/clothing/gloves/color/yellow

/obj/effect/mob_spawn/human/engineer/rig
	outfit_type = /datum/outfit/job/engineer/rig

/obj/effect/mob_spawn/human/clown
	name = "Clown"
	outfit_type = /datum/outfit/job/clown

/obj/effect/mob_spawn/human/scientist
	name = "Scientist"
	outfit_type = /datum/outfit/job/scientist

/obj/effect/mob_spawn/human/miner
	name = "Shaft Miner"
	outfit_type = /datum/outfit/job/miner/asteroid

/obj/effect/mob_spawn/human/miner/rig
	outfit_type = /datum/outfit/job/miner/equipped/asteroid

/obj/effect/mob_spawn/human/miner/explorer
	outfit_type = /datum/outfit/job/miner/equipped


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
