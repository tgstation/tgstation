//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/mob_spawn
	name = "Unknown"
	var/mob_type = null
	var/mob_name = ""
	var/mob_gender = MALE
	var/death = TRUE //Kill the mob
	var/roundstart = TRUE //fires on initialize
	var/instant = FALSE	//fires on New
	var/flavour_text = "The mapper forgot to set this!"
	var/faction = null
	var/objectives = null
	var/brute_damage = 0
	var/oxy_damage = 0
	density = 1
	anchored = 1

/obj/effect/mob_spawn/attack_ghost(mob/user)
	if(ticker.current_state != GAME_STATE_PLAYING || !loc)
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
	..()

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/mob_spawn/proc/create(ckey)
	var/mob/living/M = new mob_type(loc) //living mobs only
	M.real_name = mob_name ? mob_name : M.name
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
		if(objectives)
			var/datum/mind/MM = M.mind
			for(var/objective in objectives)
				MM.objectives += new/datum/objective(objective)
		special(M)
	qdel(src)

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null //Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/uniform = null //Set this to an object path to have the slot filled with said object on the corpse.
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
	radio = /obj/item/device/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/miner
	gloves = /obj/item/clothing/gloves/fingerless
	back = /obj/item/weapon/storage/backpack/industrial
	shoes = /obj/item/clothing/shoes/sneakers/black
	has_id = 1
	id_job = "Shaft Miner"
	id_access = "Shaft Miner"

/obj/effect/mob_spawn/human/miner/rig
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	mask = /obj/item/clothing/mask/breath


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
	mob_name = "Space Bartender"
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space bartender!"

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
	suit = /obj/item/clothing/suit/armor
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

///Prisoner

/obj/effect/mob_spawn/human/prisoner_transport
	name = "prisoner sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	roundstart = FALSE
	death = FALSE
	flavour_text = {"You were a prisoner, sentenced to hard labour in one of Nanotrasen's harsh gulags, but judging by the explosive crash you just survived, fate may have other plans for. First thing is first though: Find a way to survive this mess."}

/obj/effect/mob_spawn/human/prisoner_transport/special(mob/living/new_spawn)
	var/crime = pick("distribution of contraband" , "unauthorized erotic action on duty", "embezzlement", "piloting under the influence", "dereliction of duty", "syndicate collaboration", "mutiny", "multiple homicides", "corporate espionage", "recieving bribes", "malpractice", "worship of prohbited life forms", "possession of profane texts", "murder", "arson", "insulting your manager", "grand theft", "conspiracy", "attempting to unionize", "vandalism", "gross incompetence")
	new_spawn << "You were convincted of: [crime]."

