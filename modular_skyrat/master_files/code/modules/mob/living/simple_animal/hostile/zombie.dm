/mob/living/simple_animal/hostile/zombie
	var/no_corpse = FALSE
	var/list/possible_jobs = list(
		"Assistant",
		"Station Engineer",
		"Cook",
		"Bartender",
		"Chemist",
		"Medical Doctor",
		"Virologist",
		"Clown",
		"Mime",
		"Scientist",
		"Cargo Technician",
		"Security Officer",
		"Security Medic",
		"Geneticist",
		"Botanist",
	)

/mob/living/simple_animal/hostile/zombie/nocorpse
	no_corpse = TRUE

/mob/living/simple_animal/hostile/zombie/proc/setup_visuals()
	var/picked_job = pick(possible_jobs)
	var/datum/job/J = SSjob.GetJob(picked_job)
	var/datum/outfit/O
	if(J.outfit)
		O = new J.outfit
		//They have claws now.
		O.r_hand = null
		O.l_hand = null
/*
	var/icon/P = get_flat_human_icon_skyrat("zombie_[picked_job]", J, /datum/species/zombie/infectious, SPECIES_ZOMBIE_HALLOWEEN, outfit_override = O)
	icon = P
	if(!no_corpse)
		corpse = new(src)
		corpse.outfit = O
		corpse.mob_species = /datum/species/zombie
		corpse.mob_name = name
*/

/mob/living/simple_animal/hostile/zombie/cheesezombie
	name = "Cheese Zombie"
	desc = "Oh God it stinks!!"
	icon = 'modular_skyrat/master_files/icons/mob/newmobs.dmi'
	icon_state = "cheesezomb"
	icon_living = "cheesezomb"
	maxHealth = 100
	health = 100
	del_on_death = 1
	loot = list(/obj/effect/gibspawner/human)

