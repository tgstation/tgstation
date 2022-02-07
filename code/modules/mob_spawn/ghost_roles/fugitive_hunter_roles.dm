
/obj/effect/mob_spawn/ghost_role/human/fugitive
	spawner_job_path = /datum/job/fugitive_hunter
	prompt_name = "Write me some god damn prompt names!"
	you_are_text = "Write me some god damn you are text!"
	flavour_text = "Write me some god damn flavor text!" //the flavor text will be the backstory argument called on the antagonist's greet, see hunter.dm for details
	show_flavor = FALSE
	var/back_story = "error"

/obj/effect/mob_spawn/ghost_role/human/fugitive/Initialize(mapload)
	. = ..()
	notify_ghosts("Hunters are waking up looking for refugees!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_FUGITIVE)

/obj/effect/mob_spawn/ghost_role/human/fugitive/special(mob/living/carbon/human/spawned_human)
	. = ..()
	var/datum/antagonist/fugitive_hunter/fughunter = new
	fughunter.backstory = back_story
	spawned_human.mind.add_antag_datum(fughunter)
	fughunter.greet()
	message_admins("[ADMIN_LOOKUPFLW(spawned_human)] has been made into a Fugitive Hunter by an event.")
	log_game("[key_name(spawned_human)] was spawned as a Fugitive Hunter by an event.")

/obj/effect/mob_spawn/ghost_role/human/fugitive/spacepol
	name = "police pod"
	desc = "A small sleeper typically used to put people to sleep for briefing on the mission."
	prompt_name = "a spacepol officer"
	you_are_text = "I am a member of the Spacepol!"
	flavour_text = "Justice has arrived. We must capture those fugitives lurking on that station!"
	back_story = "space cop"
	outfit = /datum/outfit/spacepol
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/ghost_role/human/fugitive/russian
	name = "russian pod"
	prompt_name = "a russian"
	you_are_text = "Ay blyat. I am a space-russian smuggler!"
	flavour_text = "We were mid-flight when our cargo was beamed off our ship!"
	back_story = "russian"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	outfit = /datum/outfit/russiancorpse/hunter
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/ghost_role/human/fugitive/bounty
	name = "bounty hunter pod"
	prompt_name = "a bounty hunter"
	you_are_text = "I'm a bounty hunter."
	flavour_text = "We got a new bounty on some fugitives, dead or alive."
	back_story = "bounty hunters"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/ghost_role/human/fugitive/bounty/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/ghost_role/human/fugitive/bounty/armor
	outfit = /datum/outfit/bountyarmor

/obj/effect/mob_spawn/ghost_role/human/fugitive/bounty/hook
	outfit = /datum/outfit/bountyhook

/obj/effect/mob_spawn/ghost_role/human/fugitive/bounty/synth
	outfit = /datum/outfit/bountysynth
