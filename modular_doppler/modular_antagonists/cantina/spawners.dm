//one regular spawner with a capacity of one each, one spawner for an on cantina role with a capacity of one

/obj/effect/mob_spawn/ghost_role/human/cantina
	name = "Regular at The Undisclosed Location sleeper"
	desc = "A lifeform stasis unit. These are nominally produced to support long haul travel or to conserve resources in \
	Deep Space installations, but they also serve a thriving secondary market for people who cannot sleep soundly."
	prompt_name = "cantina regular"
	icon_state = "sleeper_s"
	outfit = /datum/outfit/cantina_regular
	you_are_text = "You are a regular at The Undisclosed Location."
	flavour_text = "Known by The Curfew and Sundown to squares, The Undisclosed Location is a front for criminal activity in the sector. \
	The breadth of their corporate affiliations is on a need to know basis, but the sheer volume of gear in the back is at least a little \
	illuminating. You're a regular here, and you know that they can get you the goods."
	spawner_job_path = /datum/job/cantina_regular
	role_ban = ROLE_TRAITOR

/obj/effect/mob_spawn/ghost_role/human/cantina/special(mob/living/new_spawn)
	. = ..()
	new_spawn.mind.add_antag_datum(/datum/antagonist/traitor/cantina_regular)
	var/datum/bank_account/remote/bank_account = new(new_spawn.real_name, src)
	bank_account.replaceable = FALSE
	new_spawn.add_mob_memory(/datum/memory/key/account, remembered_id = bank_account.account_id)

/obj/effect/mob_spawn/ghost_role/human/cantina_bartender
	name = "Bartender at The Undisclosed Location sleeper"
	desc = "A lifeform stasis unit commonly used on installation prone to extensive downtime; really, there's no need to \
	burn time and burn oxygen when your clientele aren't in sector."
	prompt_name = "cantina bartender"
	icon_state = "sleeper_s"
	outfit = /datum/outfit/cantina_bartender
	you_are_text = "You are a bartender at the The Undisclosed Location."
	flavour_text = "Known by The Curfew and Sundown to squares, The Undisclosed Location is a front for criminal activity in the sector. \
	The breadth of their corporate affiliations is on a need to know basis, but the sheer volume of gear in the back is at least a little \
	illuminating. You're an employee here, and you have clientele to please."
	spawner_job_path = /datum/job/cantina_bartender
	role_ban = ROLE_TRAITOR

/obj/effect/mob_spawn/ghost_role/human/cantina_bartender/special(mob/living/new_spawn)
	. = ..()
	new_spawn.mind.add_antag_datum(/datum/antagonist/traitor/cantina_bartender)
