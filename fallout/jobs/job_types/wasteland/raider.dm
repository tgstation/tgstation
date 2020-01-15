datum/job/f13/wasteland/raider
    title = "Raider"
    flag = RAIDER
    total_positions = -1
	spawn_positions = -1
    description = "A wasteland murderhobo"
    supervisor = "muh anarchy"

    outfit = /datum/outfit/job/raider

/datum/outfit/job/raider
    ..()
	name = "Raider"
	jobtype = /datum/job/f13/wasteland/raider

/datum/outfit/job/raider/pre_equip(mob/living/carbon/human/H)
	..()