

/obj/effect/mob_spawn/human/fugitive
	assignedrole = "Fugitive Hunter"
	flavour_text = ""

/obj/effect/mob_spawn/human/fugitive/spacepol
	name = "police pod"
	desc = "A small sleeper typically used to put people to sleep for briefing on the mission."
	mob_name = "spacepol officer"
	outfit = /datum/outfit/spacepol

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/human/spacepol/chief
