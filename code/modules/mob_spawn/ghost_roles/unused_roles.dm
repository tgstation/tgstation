
//i couldn't find any map that uses these, so they're delegated to admin events for now.

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport
	name = "prisoner containment sleeper"
	desc = "A sleeper designed to put its occupant into a deep coma, unbreakable until the sleeper turns off. This one's glass is cracked and you can see a pale, sleeping face staring out."
	prompt_name = "an escaped prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/lavalandprisoner
	you_are_text = "You're a prisoner, sentenced to hard work in one of Nanotrasen's labor camps, but it seems as \
	though fate has other plans for you."
	flavour_text = "Good. It seems as though your ship crashed. You remember that you were convicted of "
	spawner_job_path = /datum/job/escaped_prisoner

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport/Initialize(mapload)
	. = ..()
	var/list/crimes = list("murder", "larceny", "embezzlement", "unionization", "dereliction of duty", "kidnapping", "gross incompetence", "grand theft", "collaboration with the Syndicate", \
	"worship of a forbidden deity", "interspecies relations", "mutiny")
	flavour_text += "[pick(crimes)]. but regardless of that, it seems like your crime doesn't matter now. You don't know where you are, but you know that it's out to kill you, and you're not going \
	to lose this opportunity. Find a way to get out of this mess and back to where you rightfully belong - your [pick("house", "apartment", "spaceship", "station")]."

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport/Destroy()
	new /obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

/obj/effect/mob_spawn/ghost_role/human/prisoner_transport/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.fully_replace_character_name(null, "NTP #LL-0[rand(111,999)]") //Nanotrasen Prisoner #Lavaland-(numbers)

/datum/outfit/lavalandprisoner
	name = "Lavaland Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/tank/internals/emergency_oxygen


//spawners for the space hotel, which isn't currently in the code but heyoo secret away missions or something

//Space Hotel Staff
/obj/effect/mob_spawn/ghost_role/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	prompt_name = "a hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/hotelstaff
	you_are_text = "You are a staff member of a top-of-the-line space hotel!"
	flavour_text = "Cater to visiting guests with your fellow staff, advertise the hotel, and make sure the manager doesn't fire you. Remember, the customer is always right!"
	important_text = "Do NOT leave the hotel, as that is grounds for contract termination."
	spawner_job_path = /datum/job/hotel_staff

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/exile/noteleport)

/obj/effect/mob_spawn/ghost_role/human/hotel_staff/security
	name = "hotel security sleeper"
	prompt_name = "a hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	you_are_text = "You are a peacekeeper."
	flavour_text = "You have been assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff."
	important_text = "Do NOT leave the hotel, as that is grounds for contract termination."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/ghost_role/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

//battlecruiser stuff, i suppose

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	you_are_text = "You are a crewmember aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to follow your captain's orders, maintain the ship, and keep the engine running. If you are not familiar with how the supermatter engine functions: do not attempt to start it."
	important_text = "The armory is not a candy store, and your role is not to assault the station directly, leave that work to the assault operatives."
	prompt_name = "a battlecruiser crewmember"
	outfit = /datum/outfit/syndicate_empty/battlecruiser

/datum/outfit/syndicate_empty/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	you_are_text = "You are an assault operative aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to follow your captain's orders, keep intruders out of the ship, and assault Space Station 13. There is an armory, multiple assault ships, and beam cannons to attack the station with."
	important_text = "Work as a team with your fellow operatives and work out a plan of attack. If you are overwhelmed, escape back to your ship!"
	prompt_name = "a battlecruiser operative"
	outfit = /datum/outfit/syndicate_empty/battlecruiser/assault

/datum/outfit/syndicate_empty/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	uniform = /obj/item/clothing/under/syndicate/combat
	l_pocket = /obj/item/ammo_box/magazine/m9mm
	r_pocket = /obj/item/knife/combat/survival
	belt = /obj/item/storage/belt/military
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/pistol
	back = /obj/item/storage/backpack/security
	mask = /obj/item/clothing/mask/gas/syndicate

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/captain
	name = "Syndicate Battlecruiser Captain"
	you_are_text = "You are the captain aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to oversee your crew, defend the ship, and destroy Space Station 13. The ship has an armory, multiple ships, beam cannons, and multiple crewmembers to accomplish this goal."
	important_text = "As the captain, this whole operation falls on your shoulders. You do not need to nuke the station, causing sufficient damage and preventing your ship from being destroyed will be enough."
	prompt_name = "a battlecruiser captain"
	outfit = /datum/outfit/syndicate_empty/battlecruiser/assault/captain

/datum/outfit/syndicate_empty/battlecruiser/assault/captain
	name = "Syndicate Battlecruiser Captain"
	l_pocket = /obj/item/melee/energy/sword/saber/red
	r_pocket = /obj/item/melee/baton/telescopic
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	suit_store = /obj/item/gun/ballistic/revolver/mateba
	back = /obj/item/storage/backpack/satchel/leather
	head = /obj/item/clothing/head/hos/syndicate
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	id_trim = /datum/id_trim/battlecruiser/captain

/obj/effect/mob_spawn/ghost_role/human/syndicate
	name = "Syndicate Operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a syndicate operative"
	you_are_text = "You are a syndicate operative."
	flavour_text = "You have awoken, without instruction. Death to Nanotrasen! If there are some clues around as to what you're supposed to be doing, you best follow those."
	outfit = /datum/outfit/syndicate_empty
	spawner_job_path = /datum/job/space_syndicate

/datum/outfit/syndicate_empty
	name = "Syndicate Operative Empty"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth)
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative

/datum/outfit/syndicate_empty/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

//For ghost bar.
/obj/effect/mob_spawn/ghost_role/human/space_bar_patron
	name = "bar cryogenics"
	uses = INFINITY
	prompt_name = "a space bar patron"
	you_are_text = "You're a patron!"
	flavour_text = "Hang out at the bar and chat with your buddies. Feel free to hop back in the cryogenics when you're done chatting."
	outfit = /datum/outfit/cryobartender
	spawner_job_path = /datum/job/space_bar_patron

/obj/effect/mob_spawn/ghost_role/human/space_bar_patron/attack_hand(mob/user, list/modifiers)
	var/despawn = tgui_alert(usr, "Return to cryosleep? (Warning, Your mob will be deleted!)", null, list("Yes", "No"))
	if(despawn == "No" || !loc || !Adjacent(user))
		return
	user.visible_message(span_notice("[user.name] climbs back into cryosleep..."))
	qdel(user)

/datum/outfit/cryobartender
	name = "Cryogenic Bartender"
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/reagent

//Timeless prisons: Spawns in Wish Granter prisons in lavaland. Ghosts become age-old users of the Wish Granter and are advised to seek repentance for their past.
/obj/effect/mob_spawn/ghost_role/human/exile
	name = "timeless prison"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time."
	prompt_name = "a penitent exile"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_species = /datum/species/shadow
	you_are_text = "You are cursed."
	flavour_text = "Years ago, you sacrificed the lives of your trusted friends and the humanity of yourself to reach the Wish Granter. Though you \
	did so, it has come at a cost: your very body rejects the light, dooming you to wander endlessly in this horrible wasteland."
	spawner_job_path = /datum/job/exile

/obj/effect/mob_spawn/ghost_role/human/exile/Destroy()
	new/obj/structure/fluff/empty_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/ghost_role/human/exile/special(mob/living/new_spawn)
	. = ..()
	new_spawn.fully_replace_character_name(null,"Wish Granter's Victim ([rand(1,999)])")
	var/wish = rand(1,4)
	var/message = ""
	switch(wish)
		if(1)
			message = "<b>You wished to kill, and kill you did. You've lost track of how many, but the spark of excitement that murder once held has winked out. You feel only regret.</b>"
		if(2)
			message = "<b>You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?</b>"
		if(3)
			message = "<b>You wished for power. Little good it did you, cast out of the light. You are the [gender == MALE ? "king" : "queen"] of a hell that holds no subjects. You feel only remorse.</b>"
		if(4)
			message = "<b>You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. There is no escape.</b>"
	to_chat(new_spawn, "<span class='infoplain'>[message]</span>")

/obj/effect/mob_spawn/ghost_role/human/nanotrasensoldier
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	faction = list("nanotrasenprivate")
	prompt_name = "a private security officer"
	you_are_text = "You are a Nanotrasen Private Security Officer!"
	flavour_text = "If higher command has an assignment for you, it's best you follow that. Otherwise, death to The Syndicate."
	outfit = /datum/outfit/nanotrasensoldier

/obj/effect/mob_spawn/ghost_role/human/commander
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a nanotrasen commander"
	you_are_text = "You are a Nanotrasen Commander!"
	flavour_text = "Upper-crusty of Nanotrasen. You should be given the respect you're owed."
	outfit = /datum/outfit/nanotrasencommander

//space doctor, a rat with cancer, and bessie from an old removed lavaland ruin.

/obj/effect/mob_spawn/ghost_role/human/doctor
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space doctor"
	you_are_text = "You are a space doctor!"
	flavour_text = "It's your job- no, your duty as a doctor, to care and heal those in need."
	outfit = /datum/outfit/job/doctor
	spawner_job_path = /datum/job/space_doctor

/obj/effect/mob_spawn/ghost_role/human/doctor/alive/equip(mob/living/carbon/human/doctor)
	. = ..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/pda, /obj/item/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/unwanted_item = locate(del_type) in doctor
		qdel(unwanted_item)

/obj/effect/mob_spawn/ghost_role/mouse
	name = "sleeper"
	mob_type = /mob/living/simple_animal/mouse
	prompt_name = "a mouse"
	you_are_text = "You're a mouse!"
	flavour_text = "Uh... yep! Squeak squeak, motherfucker."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/ghost_role/cow
	name = "sleeper"
	mob_name = "Bessie"
	mob_type = /mob/living/basic/cow
	prompt_name = "a cow"
	you_are_text = "You're a cow!"
	flavour_text = "Go graze some grass, stinky."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/cow/special(mob/living/spawned_mob)
	. = ..()
	gender = FEMALE

// snow operatives on snowdin - unfortunately seemingly removed in a map remake womp womp

/obj/effect/mob_spawn/ghost_role/human/snow_operative
	name = "sleeper"
	prompt_name = "a snow operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	faction = list(ROLE_SYNDICATE)
	outfit = /datum/outfit/snowsyndie
	you_are_text = "You are a syndicate operative recently awoken from cryostasis in an underground outpost."
	flavour_text = "Monitor Nanotrasen communications and record information. All intruders should be disposed of \
	swiftly to assure no gathered information is stolen or lost. Try not to wander too far from the outpost as the \
	caves can be a deadly place even for a trained operative such as yourself."

/datum/outfit/snowsyndie
	name = "Syndicate Snow Operative"
	uniform = /obj/item/clothing/under/syndicate/coldres
	shoes = /obj/item/clothing/shoes/combat/coldres
	ears = /obj/item/radio/headset/syndicate/alt
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	id = /obj/item/card/id/advanced/chameleon
	implants = list(/obj/item/implant/exile)
	id_trim = /datum/id_trim/chameleon/operative

//Forgotten syndicate ship

/obj/effect/mob_spawn/ghost_role/human/syndicatespace
	name = "Syndicate Ship Crew Member"
	show_flavor = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "cybersun crew"
	you_are_text = "You are a syndicate operative on old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Fix the ship, find a way to power it and follow your captain's orders."
	important_text = "Obey orders given by your captain. DO NOT let the ship fall into enemy hands."
	outfit = /datum/outfit/syndicatespace/syndicrew
	spawner_job_path = /datum/job/syndicate_cybersun

/datum/outfit/syndicatespace/syndicrew/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/special(mob/living/new_spawn)
	. = ..()
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)
	var/datum/job/spawn_job = SSjob.GetJobType(spawner_job_path)
	var/policy = get_policy(spawn_job.policy_index)
	if(policy)
		to_chat(new_spawn, span_bold("[policy]"))

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/captain
	name = "Syndicate Ship Captain"
	prompt_name = "a cybersun captain"
	you_are_text = "You are the captain of an old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Command your crew and turn your ship into the most protected fortress."
	important_text = "Protect the ship and secret documents in your backpack with your own life."
	outfit = /datum/outfit/syndicatespace/syndicaptain
	spawner_job_path = /datum/job/syndicate_cybersun_captain

/datum/outfit/syndicatespace/syndicaptain/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/captain/Destroy()
	new /obj/structure/fluff/empty_sleeper/syndicate/captain(get_turf(src))
	return ..()

/datum/outfit/syndicatespace/syndicrew
	name = "Syndicate Ship Crew Member"
	uniform = /obj/item/clothing/under/syndicate/combat
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault
	id = /obj/item/card/id/advanced/black/syndicate_command/crew_id
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/syndicatespace/syndicaptain
	name = "Syndicate Ship Captain"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	head = /obj/item/clothing/head/hos/beret/syndicate
	ears = /obj/item/radio/headset/syndicate/alt/leader
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault
	id = /obj/item/card/id/advanced/black/syndicate_command/captain_id
	implants = list(/obj/item/implant/weapons_auth)
	backpack_contents = list(/obj/item/documents/syndicate/red, /obj/item/paper/fluff/ruins/forgottenship/password, /obj/item/gun/ballistic/automatic/pistol/aps)
