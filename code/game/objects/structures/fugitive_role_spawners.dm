

/obj/effect/mob_spawn/human/fugitive
	assignedrole = "Fugitive Hunter"
	flavour_text = "" //the flavor text will be the backstory argument called on the antagonist's greet, see hunter.dm for details

/obj/effect/mob_spawn/human/fugitive/special(mob/living/new_spawn)
	var/datum/antagonist/fugitive_hunter/fughunter = new_spawn.mind.add_antag_datum(/datum/antagonist/fugitive_hunter)
	fughunter.greet(flavour_text)

/obj/effect/mob_spawn/human/fugitive/spacepol
	name = "police pod"
	desc = "A small sleeper typically used to put people to sleep for briefing on the mission."
	mob_name = "spacepol officer"
	flavour_text = "space cop"
	outfit = /datum/outfit/spacepol
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/fugitive/spacepol/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()
