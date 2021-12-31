
//roles found on away missions, if you can remember to put them here.

//undead that protect a zlevel

/obj/effect/mob_spawn/ghost_role/human/skeleton
	name = "skeletal remains"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	mob_name = "skeleton"
	prompt_name = "a skeletal guardian"
	you_are_text = "By unknown powers, your skeletal remains have been reanimated!"
	flavour_text = "Walk this mortal plane and terrorize all living adventurers who dare cross your path."
	spawner_job_path = /datum/job/skeleton

/obj/effect/mob_spawn/ghost_role/human/skeleton/special(mob/living/new_spawn)
	. = ..()
	to_chat(new_spawn, "<b>You have this horrible lurching feeling deep down that your binding to this world will fail if you abandon this zone... Were you reanimated to protect something?</b>")
	new_spawn.AddComponent(/datum/component/stationstuck, PUNISHMENT_MURDER, "You experience a feeling like a stressed twine being pulled until it snaps. Then, merciful nothing.")

/obj/effect/mob_spawn/ghost_role/human/zombie
	name = "rotting corpse"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	mob_name = "zombie"
	prompt_name = "an undead guardian"
	mob_species = /datum/species/zombie
	spawner_job_path = /datum/job/zombie
	you_are_text = "By unknown powers, your rotting remains have been resurrected!"
	flavour_text = "Walk this mortal plane and terrorize all living adventurers who dare cross your path."

/obj/effect/mob_spawn/ghost_role/human/zombie/special(mob/living/new_spawn)
	. = ..()
	to_chat(new_spawn, "<b>You have this horrible lurching feeling deep down that your binding to this world will fail if you abandon this zone... Were you reanimated to protect something?</b>")
	new_spawn.AddComponent(/datum/component/stationstuck, PUNISHMENT_MURDER, "You experience a feeling like a stressed twine being pulled until it snaps. Then, merciful nothing.")
