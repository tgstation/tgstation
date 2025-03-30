//one regular spawner with a capacity of one each, one spawner for an on cantina role with a capacity of one

/obj/effect/mob_spawn/ghost_role/human/cantina
	name = "The Undisclosed Location regular sleeper"
	desc = "A lifeform stasis unit. These are nominally produced to support long haul travel or to conserve resources in \
	Deep Space installations, but they also serve a thriving secondary market for people who cannot sleep soundly."
	prompt_name = "cantina regular"
	icon_state = "sleeper_s"
	outfit = /datum/outfit/syndicate/cantina_regular
	you_are_text = "You are a regular at The Undisclosed Location."
	flavour_text = "Known by The Curfew and Sundown to squares, The Undisclosed Location is a front for criminal activity in the sector. \
	The breadth of their corporate affiliations is on a need to know basis, but the sheer volume of gear in the back is at least a little \
	illuminating. You're a regular here, and you know that they can get you the goods."
	spawner_job_path = /datum/job/cantina_regular

/obj/effect/mob_spawn/ghost_role/human/cantina/special(mob/living/new_spawn)
	. = ..()
	new_spawn.grant_language(/datum/language/codespeak, source = LANGUAGE_MIND)

/obj/effect/mob_spawn/ghost_role/human/cantina/bartender
	name = "The Undisclosed Location bartender sleeper"
	desc = "A lifeform stasis unit commonly used on installation prone to extensive downtime; really, there's no need to \
	burn time and burn oxygen when your clientele aren't in sector."
	prompt_name = "cantina bartender"
	outfit = /datum/outfit/syndicate/cantina_bartender
	you_are_text = "You are a bartender at the The Undisclosed Location."
	flavour_text = "Known by The Curfew and Sundown to squares, The Undisclosed Location is a front for criminal activity in the sector. \
	The breadth of their corporate affiliations is on a need to know basis, but the sheer volume of gear in the back is at least a little \
	illuminating. You're an employee here, and you have clientele to please."
	spawner_job_path = /datum/job/cantina_bartender

