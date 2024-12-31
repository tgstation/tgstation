
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
	flavour_text = "The station refused to pay for your protection. Protect the ship, siphon the credits from the station, and raid it for even more loot."
	spawner_job_path = /datum/job/space_pirate
	///Rank of the pirate on the ship, it's used in generating pirate names!
	var/rank = "Deserter"
	///Path of the structure we spawn after creating a pirate.
	var/fluff_spawn = /obj/structure/showcase/machinery/oldpod/used

	//obviously, these pirate name vars are only used if you don't override `generate_pirate_name()`
	///json key to pirate names, the first part ("Comet" in "Cometfish")
	var/name_beginnings = "generic_beginnings"
	///json key to pirate names, the last part ("fish" in "Cometfish")
	var/name_endings = "generic_endings"

/obj/effect/mob_spawn/ghost_role/human/pirate/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, generate_pirate_name(spawned_mob.gender))
	spawned_mob.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/ghost_role/human/pirate/proc/generate_pirate_name(spawn_gender)
	var/beggings = strings(PIRATE_NAMES_FILE, name_beginnings)
	var/endings = strings(PIRATE_NAMES_FILE, name_endings)
	return "[rank ? rank + " " : ""][pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/ghost_role/human/pirate/create(mob/mob_possessor, newname)
	if(fluff_spawn)
		new fluff_spawn(drop_location())
	return ..()

/obj/effect/mob_spawn/ghost_role/human/pirate/captain
	rank = "Renegade Leader"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/gunner
	rank = "Rogue"

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton
	name = "pirate remains"
	desc = "Some inanimate bones. They feel like they could spring to life at any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	prompt_name = "a skeleton pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate
	rank = "Mate"
	fluff_spawn = null

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/captain/skeleton

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

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne
	name = "\improper Interdyne sleeper"
	desc = "A surprisingly clean cryogenic sleeper. You can see your reflection on the sides!"
	density = FALSE
	you_are_text = "You are an Ex-Interdyne pharmacyst now turned space pirate."
	flavour_text = "The station has refused to fund your research, so you will 'convince' them to donate to your charitable cause."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "An Ex-Interdyne employee"
	outfit = /datum/outfit/pirate/interdyne
	rank = "Pharmacist"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
		else
			first_name = pick(GLOB.first_names)

	return "[rank] [first_name]"

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/senior
	rank = "Pharmacist Director"
	outfit = /datum/outfit/pirate/interdyne/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/interdyne/junior
	rank = "Pharmacist"

/obj/effect/mob_spawn/ghost_role/human/pirate/grey
	name = "\improper Assistant sleeper"
	desc = "A very dirty cryogenic sleeper. You're not sure if it even works."
	density = FALSE
	you_are_text = "You used to be a Nanotrasen assistant, until a riot gone awry. Now you wander space, ransacking any ships you come across!"
	flavour_text = "There's nothing a toolbox can't whack in the head enough times to spill blood, or in this case money. Loot everything!"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "An assistant gone loose"
	outfit = /datum/outfit/pirate/grey
	rank = "Tider"

/obj/effect/mob_spawn/ghost_role/human/pirate/grey/shitter
	rank = "Tidemaster"

/obj/effect/mob_spawn/ghost_role/human/pirate/irs
	name = "\improper Space IRS sleeper"
	desc = "A surprisingly clean cryogenic sleeper. You can see your reflection on the sides!"
	density = FALSE
	you_are_text = "You are an agent working for the space IRS"
	flavour_text = "Not even in the expanse of the expanding universe can someone evade the tax man! Whether you are just a well disciplined and professional pirate gang or an actual agent from a local polity. You will squeeze the station dry of its income regardless! Through peaceful means or otherwise..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "An agent of the space IRS"
	outfit = /datum/outfit/pirate/irs
	fluff_spawn = null // dirs are fucked and I don't have the energy to deal with it
	rank = "Agent"

/obj/effect/mob_spawn/ghost_role/human/pirate/irs/generate_pirate_name(spawn_gender)
	var/first_name
	switch(spawn_gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
		else
			first_name = pick(GLOB.first_names)

	return "[rank] [first_name]"


/obj/effect/mob_spawn/ghost_role/human/pirate/irs/auditor
	rank = "Head Auditor"
	outfit = /datum/outfit/pirate/irs/auditor

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous
	name = "lustrous crystal"
	desc = "A crystal housing a mutated Ethereal, it emanates a foreboding glow."
	density = FALSE
	you_are_text = "Once you were a proud Ethereal, now all that remains is your hunger for the precious bluespace crystal."
	flavour_text = "The station has denied you your bluespace crystals, the sweet ambrosia of the fifth-dimension. Strike the earth!"
	icon = 'icons/mob/effects/ethereal_crystal.dmi'
	icon_state = "ethereal_crystal"
	fluff_spawn = null
	prompt_name = "a geode dweller"
	mob_species = /datum/species/ethereal/lustrous
	outfit = /datum/outfit/pirate/lustrous
	rank = "Scintillant"

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous/captain
	rank = "Radiant"
	outfit = /datum/outfit/pirate/lustrous/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/lustrous/gunner
	rank = "Coruscant"

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval
	name = "\improper Improvised sleeper"
	desc = "A body bag poked with holes, currently being used as a sleeping bag. Someone seems to be sleeping inside of it."
	density = FALSE
	you_are_text = "You were a nobody before, until you were given a sword and the opportunity to rise up in ranks. If you put some effort, you can make it big!"
	flavour_text = "Raiding some cretins while engaging in bloodsport and violence? what a deal. Stay together and pillage everything!"
	icon = 'icons/obj/medical/bodybag.dmi'
	icon_state = "bodybag"
	fluff_spawn = null
	prompt_name = "a medieval warmonger"
	outfit = /datum/outfit/pirate/medieval
	rank = "Footsoldier"

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/special(mob/living/carbon/spawned_mob)
	. = ..()
	if(rank == "Footsoldier")
		spawned_mob.add_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), INNATE_TRAIT)
		spawned_mob.AddComponent(/datum/component/unbreakable)
		var/datum/action/cooldown/mob_cooldown/dash/dodge = new(spawned_mob)
		dodge.Grant(spawned_mob)

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/warlord
	rank = "Warlord"
	outfit = /datum/outfit/pirate/medieval/warlord

/obj/effect/mob_spawn/ghost_role/human/pirate/medieval/warlord/special(mob/living/carbon/spawned_mob)
	. = ..()
	spawned_mob.dna.add_mutation(/datum/mutation/human/hulk/superhuman)
	spawned_mob.dna.add_mutation(/datum/mutation/human/gigantism)
