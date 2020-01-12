datum/job/f13/wasteland/wastelander
    title = "Wastelander"
    flag = WASTELANDER
    total_positions = -1
	spawn_positions = -1
    description = "A wasteland murderhobo"
    supervisor = "muh anarchy"

    outfit = /datum/outfit/job/wastelander

/datum/outfit/job/wastelander
    ..()
	name = "Wastelander"
	jobtype = /datum/job/f13/wasteland/wastelander

/datum/outfit/job/wastelander/pre_equip(mob/living/carbon/human/H)
	..()