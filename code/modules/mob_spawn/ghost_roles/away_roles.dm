
//roles found on away missions, if you can remember to put them here.

//undead that protect a zlevel

/obj/effect/mob_spawn/ghost_role/human/skeleton
	name = "skeletal remains"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	mob_name = "skeleton"
	prompt_name = "a skeletal guardian"
	mob_species = /datum/species/skeleton
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
/obj/effect/mob_spawn/ghost_role/human/heretic
	name = "Security Agent"
	prompt_name = "Become a mysterious agent?"
	you_are_text = "You are an agent for a mysterious clandestine group and the facility you worked for recently got evacuated and you were told to not go in and to prevent other people from going in, you know better than to mess with your boss."
	flavour_text = "You are tasked with maintaining the security of the facility and the people still left inside. You are to not let anybody in but to maintain the front of the resort but tell them the beach is closed, but do your best to still service people as if this was a resort."
	important_text = "You can, and should kill people if they try and get past the wooden barricades and security barrier, however if when you catch them theyre already past the security barrier you are to kill yourself instead, if you kill anybody you are to tend their body then make their death look like an accident and then throw them back through the gateway DO NOT RR PEOPLE OR HIDE THEIR BODIES IN ANY CIRCUMSTANCES, do not loot people either even if its their weapon in the heat of combat, go into this ghost role with the mindset that you are an npc."
	loadout_enabled = TRUE
	quirks_enabled = TRUE // ghost role quirks
	random_appearance = FALSE // ghost role prefs
	deletes_on_zero_uses_left = TRUE
