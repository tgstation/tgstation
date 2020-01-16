datum/job/f13/wasteland/wastelander
	title = "Wastelander"
	//flag = F13WASTELANDER
	total_positions = -1
	spawn_positions = -1
	supervisors = "muh anarchy"

	outfit = /datum/outfit/job/wastelander

	display_order = JOB_DISPLAY_ORDER_WASTELANDER

/datum/outfit/job/wastelander
	..()
	name = "Wastelander"
	jobtype = /datum/job/f13/wasteland/wastelander

/datum/outfit/job/wastelander/pre_equip(mob/living/carbon/human/H)
	..()
