//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders

///Pirates

//Forgotten syndicate ship

/obj/effect/mob_spawn/ghost_role/human/syndicatespace
	name = "Syndicate Ship Crew Member"
	roundstart = FALSE
	death = FALSE
	show_flavor = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	you_are_text = "You are a syndicate operative on old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Fix the ship, find a way to power it and follow your captain's orders."
	important_text = "Obey orders given by your captain. DO NOT let the ship fall into enemy hands."
	outfit = /datum/outfit/syndicatespace/syndicrew
	spawner_job_path = /datum/job/syndicate_cybersun

/datum/outfit/syndicatespace/syndicrew/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/special(mob/living/new_spawn)
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)
	var/datum/job/spawn_job = SSjob.GetJobType(spawner_job_path)
	var/policy = get_policy(spawn_job.policy_index)
	if(policy)
		to_chat(new_spawn, span_bold("[policy]"))

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/captain
	name = "Syndicate Ship Captain"
	you_are_text = "You are the captain of an old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Command your crew and turn your ship into the most protected fortress."
	important_text = "Protect the ship and secret documents in your backpack with your own life."
	outfit = /datum/outfit/syndicatespace/syndicaptain
	spawner_job_path = /datum/job/syndicate_cybersun_captain

/datum/outfit/syndicatespace/syndicaptain/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/ghost_role/human/syndicatespace/captain/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate/captain(get_turf(src))
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

