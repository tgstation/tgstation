

/obj/effect/mob_spawn/human/fugitive
	assignedrole = "Fugitive Hunter"
	flavour_text = "" //the flavor text will be the backstory argument called on the antagonist's greet, see hunter.dm for details
	roundstart = FALSE
	death = FALSE
	show_flavour = FALSE

/obj/effect/mob_spawn/human/ash_walker/Initialize(mapload)
	. = ..()
	notify_ghosts("Hunters are waking up looking for refugees!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_FUGITIVE)

/obj/effect/mob_spawn/human/fugitive/special(mob/living/new_spawn)
	var/datum/antagonist/fugitive_hunter/fughunter = new_spawn.mind.add_antag_datum(/datum/antagonist/fugitive_hunter)
	fughunter.greet(flavour_text)
	message_admins("[ADMIN_LOOKUPFLW(new_spawn)] has been made into a Fugitive Hunter by an event.")
	log_game("[key_name(new_spawn)] was spawned as a Fugitive Hunter by an event.")

/obj/effect/mob_spawn/human/fugitive/spacepol
	name = "police pod"
	desc = "A small sleeper typically used to put people to sleep for briefing on the mission."
	mob_name = "spacepol officer"
	flavour_text = "space cop"
	outfit = /datum/outfit/spacepol
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = TRUE

/obj/effect/mob_spawn/human/fugitive/russian
	name = "russian pod"
	flavour_text = "russian"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	mob_name = "russian"
	outfit = /datum/outfit/russiancorpse
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = TRUE
