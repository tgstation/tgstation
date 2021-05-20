//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).


//HEY! LISTEN! anything that is ALIVE and thus GHOSTS CAN TAKE is in ghost_role_spawners.dm!

/obj/effect/mob_spawn
	name = "Mob Spawner"
	density = TRUE
	anchored = TRUE
	icon = 'icons/effects/mapping_helpers.dmi' // These aren't *really* mapping helpers but it fits the most with it's common usage (to help place corpses in maps)
	icon_state = "mobspawner" // So it shows up in the map editor
	var/mob_type = null
	var/mob_name = ""
	var/mob_gender = null
	var/death = TRUE //Kill the mob
	var/roundstart = TRUE //fires on initialize
	var/instant = FALSE //fires on New
	var/short_desc = "The mapper forgot to set this!"
	var/flavour_text = ""
	var/important_info = ""
	var/faction = null
	var/permanent = FALSE //If true, the spawner will not disappear upon running out of uses.
	var/random = FALSE //Don't set a name or gender, just go random
	var/antagonist_type
	var/objectives = null
	var/uses = 1 //how many times can we spawn from it. set to -1 for infinite.
	var/brute_damage = 0
	var/oxy_damage = 0
	var/burn_damage = 0
	var/datum/disease/disease = null //Do they start with a pre-spawned disease?
	var/mob_color //Change the mob's color
	var/assignedrole
	var/show_flavour = TRUE
	var/banType = ROLE_LAVALAND
	var/ghost_usable = TRUE

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/attack_ghost(mob/user)
	if(!SSticker.HasRoundStarted() || !loc || !ghost_usable)
		return
	var/ghost_role = tgui_alert(usr,"Become [mob_name]? (Warning, You can no longer be revived!)",,list("Yes","No"))
	if(ghost_role == "No" || !loc || QDELETED(user))
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !(flags_1 & ADMIN_SPAWNED_1))
		to_chat(user, "<span class='warning'>An admin has temporarily disabled non-admin ghost roles!</span>")
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(is_banned_from(user.key, banType))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	if(!allow_spawn(user))
		return
	if(QDELETED(src) || QDELETED(user))
		return
	log_game("[key_name(user)] became [mob_name]")
	create(ckey = user.ckey)

/obj/effect/mob_spawn/Initialize(mapload)
	. = ..()
	if(instant || (roundstart && (mapload || (SSticker && SSticker.current_state > GAME_STATE_SETTING_UP))))
		INVOKE_ASYNC(src, .proc/create)
	else if(ghost_usable)
		AddElement(/datum/element/point_of_interest)
		LAZYADD(GLOB.mob_spawners[name], src)

/obj/effect/mob_spawn/Destroy()
	var/list/spawners = GLOB.mob_spawners[name]
	LAZYREMOVE(spawners, src)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= name
	return ..()

/obj/effect/mob_spawn/proc/allow_spawn(mob/user) //Override this to add spawn limits to a ghost role
	return TRUE

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/mob_spawn/proc/create(ckey, newname)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	if(!random || newname)
		if(newname)
			M.real_name = newname
		else if(!M.unique_name)
			M.real_name = mob_name ? mob_name : M.name
		if(!mob_gender)
			mob_gender = pick(MALE, FEMALE)
		M.gender = mob_gender
		if(ishuman(M))
			var/mob/living/carbon/human/hoomie = M
			hoomie.body_type = mob_gender
	if(faction)
		M.faction = list(faction)
	if(disease)
		M.ForceContractDisease(new disease)
	if(death)
		M.death(1) //Kills the new mob

	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	M.adjustFireLoss(burn_damage)
	M.color = mob_color
	equip(M)

	if(ckey)
		M.ckey = ckey
		if(show_flavour)
			var/output_message = "<span class='infoplain'><span class='big bold'>[short_desc]</span></span>"
			if(flavour_text != "")
				output_message += "\n<span class='infoplain'><b>[flavour_text]</b></span>"
			if(important_info != "")
				output_message += "\n<span class='userdanger'>[important_info]</span>"
			to_chat(M, output_message)
		var/datum/mind/MM = M.mind
		var/datum/antagonist/A
		if(antagonist_type)
			A = MM.add_antag_datum(antagonist_type)
		if(objectives)
			if(!A)
				A = MM.add_antag_datum(/datum/antagonist/custom)
			for(var/objective in objectives)
				var/datum/objective/O = new/datum/objective(objective)
				O.owner = MM
				A.objectives += O
		if(assignedrole)
			M.mind.assigned_role = assignedrole
		special(M)
		MM.name = M.real_name
	if(uses > 0)
		uses--
	if(!permanent && !uses)
		qdel(src)
	return M

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null //Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/datum/outfit/outfit = /datum/outfit //If this is a path, it will be instanced in Initialize()
	var/disable_pda = TRUE
	var/disable_sensors = TRUE
	assignedrole = "Ghost Role"

	var/husk = null
	//these vars are for lazy mappers to override parts of the outfit
	//these cannot be null by default, or mappers cannot set them to null if they want nothing in that slot
	var/uniform = -1
	var/r_hand = -1
	var/l_hand = -1
	var/suit = -1
	var/shoes = -1
	var/gloves = -1
	var/ears = -1
	var/glasses = -1
	var/mask = -1
	var/head = -1
	var/belt = -1
	var/r_pocket = -1
	var/l_pocket = -1
	var/back = -1
	var/id = -1
	var/neck = -1
	var/backpack_contents = -1
	var/suit_store = -1

	var/hairstyle
	var/facial_hairstyle
	var/haircolor
	var/facial_haircolor
	var/skin_tone

/obj/effect/mob_spawn/human/Initialize()
	if(ispath(outfit))
		outfit = new outfit()
	if(!outfit)
		outfit = new /datum/outfit
	return ..()

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(husk)
		H.Drain()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		H.cure_husk()
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	if(hairstyle)
		H.hairstyle = hairstyle
	else
		H.hairstyle = random_hairstyle(H.gender)
	if(facial_hairstyle)
		H.facial_hairstyle = facial_hairstyle
	else
		H.facial_hairstyle = random_facial_hairstyle(H.gender)
	if(haircolor)
		H.hair_color = haircolor
	else
		H.hair_color = random_short_color()
	if(facial_haircolor)
		H.facial_hair_color = facial_haircolor
	else
		H.facial_hair_color = random_short_color()
	if(skin_tone)
		H.skin_tone = skin_tone
	else
		H.skin_tone = random_skin_tone()
	H.update_hair()
	H.update_body()
	if(outfit)
		var/static/list/slots = list("uniform", "r_hand", "l_hand", "suit", "shoes", "gloves", "ears", "glasses", "mask", "head", "belt", "r_pocket", "l_pocket", "back", "id", "neck", "backpack_contents", "suit_store")
		for(var/slot in slots)
			var/T = vars[slot]
			if(!isnum(T))
				outfit.vars[slot] = T
		H.equipOutfit(outfit)
		if(disable_pda)
			// We don't want corpse PDAs to show up in the messenger list.
			var/obj/item/pda/PDA = locate(/obj/item/pda) in H
			if(PDA)
				PDA.toff = TRUE
		if(disable_sensors)
			// Using crew monitors to find corpses while creative makes finding certain ruins too easy.
			var/obj/item/clothing/under/C = H.w_uniform
			if(istype(C))
				C.sensor_mode = NO_SENSORS
				H.update_suit_sensors()

	var/obj/item/card/id/W = H.wear_id
	if(W)
		if(H.age)
			W.registered_age = H.age
		W.registered_name = H.real_name
		W.update_label()
		W.update_icon()

//Instant version - use when spawning corpses during runtime
/obj/effect/mob_spawn/human/corpse
	icon_state = "corpsehuman"
	roundstart = FALSE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/damaged
	brute_damage = 1000

//i left this here despite being a mob spawner because this is a base type
/obj/effect/mob_spawn/human/alive
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	death = FALSE
	roundstart = FALSE //you could use these for alive fake humans on roundstart but this is more common scenario

/obj/effect/mob_spawn/human/corpse/delayed
	ghost_usable = FALSE //These are just not-yet-set corpses.
	instant = FALSE
	invisibility = 101 // a fix for the icon not wanting to cooperate

//Non-human spawners

/obj/effect/mob_spawn/AICorpse/create(ckey) //Creates a corrupted AI
	var/A = locate(/mob/living/silicon/ai) in loc
	if(A)
		return
	var/mob/living/silicon/ai/spawned/M = new(loc) //spawn new AI at landmark as var M
	M.name = src.name
	M.real_name = src.name
	M.aiPDA.toff = TRUE //turns the AI's PDA messenger off, stopping it showing up on player PDAs
	M.death() //call the AI's death proc
	qdel(src)

/obj/effect/mob_spawn/slime
	mob_type = /mob/living/simple_animal/slime
	var/mobcolour = "grey"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime" //sets the icon in the map editor

/obj/effect/mob_spawn/slime/equip(mob/living/simple_animal/slime/S)
	S.colour = mobcolour

/obj/effect/mob_spawn/facehugger/create(ckey) //Creates a squashed facehugger
	var/obj/item/clothing/mask/facehugger/O = new(src.loc) //variable O is a new facehugger at the location of the landmark
	O.name = src.name
	O.Die() //call the facehugger's death proc
	qdel(src)

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.

///////////Civilians//////////////////////

/obj/effect/mob_spawn/human/corpse/assistant
	name = "Assistant"
	outfit = /datum/outfit/job/assistant
	icon_state = "corpsegreytider"

/obj/effect/mob_spawn/human/corpse/assistant/beesease_infection
	disease = /datum/disease/beesease

/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection
	disease = /datum/disease/brainrot

/obj/effect/mob_spawn/human/corpse/assistant/spanishflu_infection
	disease = /datum/disease/fluspanish

/obj/effect/mob_spawn/human/corpse/cargo_tech
	name = "Cargo Tech"
	outfit = /datum/outfit/job/cargo_tech
	icon_state = "corpsecargotech"

/obj/effect/mob_spawn/human/cook
	name = "Cook"
	outfit = /datum/outfit/job/cook
	icon_state = "corpsecook"

/obj/effect/mob_spawn/human/doctor
	name = "Doctor"
	outfit = /datum/outfit/job/doctor
	icon_state = "corpsedoctor"

/obj/effect/mob_spawn/human/geneticist
	name = "Geneticist"
	outfit = /datum/outfit/job/geneticist
	icon_state = "corpsescientist"

/obj/effect/mob_spawn/human/engineer
	name = "Engineer"
	outfit = /datum/outfit/job/engineer/gloved
	icon_state = "corpseengineer"

/obj/effect/mob_spawn/human/engineer/rig
	outfit = /datum/outfit/job/engineer/gloved/rig

/obj/effect/mob_spawn/human/engineer/rig/gunner
	outfit = /datum/outfit/job/engineer/gloved/rig/gunner

/obj/effect/mob_spawn/human/clown
	name = "Clown"
	outfit = /datum/outfit/job/clown
	icon_state = "corpseclown"

/obj/effect/mob_spawn/human/scientist
	name = "Scientist"
	outfit = /datum/outfit/job/scientist
	icon_state = "corpsescientist"

/obj/effect/mob_spawn/human/miner
	name = "Shaft Miner"
	outfit = /datum/outfit/job/miner
	icon_state = "corpseminer"

/obj/effect/mob_spawn/human/miner/rig
	outfit = /datum/outfit/job/miner/equipped/hardsuit

/obj/effect/mob_spawn/human/miner/explorer
	outfit = /datum/outfit/job/miner/equipped

/obj/effect/mob_spawn/human/plasmaman
	mob_species = /datum/species/plasmaman
	outfit = /datum/outfit/plasmaman

/obj/effect/mob_spawn/human/bartender
	name = "Space Bartender"
	outfit = /datum/outfit/spacebartender

/obj/effect/mob_spawn/human/beach
	outfit = /datum/outfit/beachbum

/////////////////Officers+Nanotrasen Security//////////////////////

/obj/effect/mob_spawn/human/bridgeofficer
	name = "Bridge Officer"
	outfit = /datum/outfit/nanotrasenbridgeofficercorpse

/datum/outfit/nanotrasenbridgeofficercorpse
	name = "Bridge Officer Corpse"
	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom/officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/bridge_officer

/obj/effect/mob_spawn/human/commander
	name = "Commander"
	outfit = /datum/outfit/nanotrasencommandercorpse

/datum/outfit/nanotrasencommandercorpse
	name = "\improper Nanotrasen Private Security Commander"
	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	ears = /obj/item/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/combat/swat
	r_pocket = /obj/item/lighter
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/commander

/obj/effect/mob_spawn/human/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	outfit = /datum/outfit/nanotrasensoldiercorpse

/datum/outfit/nanotrasensoldiercorpse
	name = "NT Private Security Officer Corpse"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/centcom/corpse/private_security

/obj/effect/mob_spawn/human/intern //this is specifically the comms intern from the event
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom/centcom_intern/unarmed
	mob_name = "Nameless Intern"
	mob_gender = MALE

/////////////////Spooky Undead//////////////////////
//there are living variants of many of these, they're now in ghost_role_spawners.dm

/obj/effect/mob_spawn/human/skeleton
	name = "skeletal remains"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton
	mob_gender = NEUTER

/obj/effect/mob_spawn/human/zombie
	name = "rotting corpse"
	mob_name = "zombie"
	mob_species = /datum/species/zombie
	assignedrole = "Zombie"

/obj/effect/mob_spawn/human/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/abductorcorpse

/datum/outfit/abductorcorpse
	name = "Abductor Corpse"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat
