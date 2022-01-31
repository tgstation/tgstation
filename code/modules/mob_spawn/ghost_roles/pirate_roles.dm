
//space pirates from the pirate event.

/obj/effect/mob_spawn/ghost_role/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space pirate"
	outfit = /datum/outfit/pirate/space
	anchored = TRUE
	density = FALSE
	show_flavor = FALSE //Flavour only exists for spawners menu
	you_are_text = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	spawner_job_path = /datum/job/space_pirate
	///Rank of the pirate on the ship, it's used in generating pirate names!
	var/rank = "Deserter"
	///Whether or not it will spawn a fluff structure upon opening.
	var/spawn_oldpod = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, generate_pirate_name(spawned_mob.gender))
	spawned_mob.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/ghost_role/human/pirate/proc/generate_pirate_name(spawn_gender)
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank ? rank + " " : ""][pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/ghost_role/human/pirate/Destroy()
	if(spawn_oldpod)
		new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/ghost_role/human/pirate/captain
	rank = "Renegade Leader"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/gunner
	rank = "Rogue"

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton
	name = "pirate remains"
	desc = "Some unanimated bones. They feel like they could spring to life any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	spawn_oldpod = FALSE
	prompt_name = "a skeleton pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate
	rank = "Mate"

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/gunner
	rank = "Gunner"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale
	name = "elegant sleeper"
	desc = "Cozy. You get the feeling you aren't supposed to be here, though..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a silverscale"
	mob_species = /datum/species/lizard/silverscale
	outfit = /datum/outfit/pirate/silverscale
	rank = "High-born"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.lizard_names_male)
		if(FEMALE)
			first_name = pick(GLOB.lizard_names_female)
		else
			first_name = pick(GLOB.lizard_names_male + GLOB.lizard_names_female)

	return "[rank] [first_name]-Silverscale"

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/captain
	rank = "Old-guard"
	outfit = /datum/outfit/pirate/silverscale/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/silverscale/gunner
	rank = "Top-drawer"

/obj/effect/mob_spawn/ghost_role/human/pirate/monster_hunters
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon = 'icons/obj/crates.dmi'
	icon_state = "coffin"
	prompt_name = "a monster hunter"
	outfit = /datum/outfit/pirate
	rank = null
	var/list/static/outfits_picked = list()

/obj/effect/mob_spawn/ghost_role/human/pirate/monster_hunters/equip(mob/living/spawned_mob)
	switch(spawned_mob.gender)
		if(MALE)
			var/list/possible = list(
				/datum/outfit/pirate/antonio,
				/datum/outfit/pirate/gennaro,
				/datum/outfit/pirate/arca,
				/datum/outfit/pirate/mortaccio,
			) - outfits_picked
			outfit = pick(possible)
		if(FEMALE)
			var/list/possible = list(
				/datum/outfit/pirate/imelda,
				/datum/outfit/pirate/pasqualina,
				/datum/outfit/pirate/porta,
				/datum/outfit/pirate/mortaccio,
			) - outfits_picked
			outfit = pick(possible)
		else
			var/list/possible = list(
				/datum/outfit/pirate/antonio,
				/datum/outfit/pirate/gennaro,
				/datum/outfit/pirate/arca,
				/datum/outfit/pirate/imelda,
				/datum/outfit/pirate/pasqualina,
				/datum/outfit/pirate/porta,
				/datum/outfit/pirate/mortaccio,
			) - outfits_picked
			outfit = pick(possible)
	. = ..()
