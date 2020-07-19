/datum/job/prisoner
	title = "Prisoner"
	flag = PRISONER
	department_head = list("The Security Team")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the security team"
	selection_color = "#ffe1c3"

	outfit = /datum/outfit/job/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	id = /obj/item/card/id/prisoner
	ears = null
	belt = null

/datum/job/prisoner/after_spawn(mob/living/H, mob/M, latejoin)
	. = ..()
	if(latejoin)
		var/mob/living/carbon/human/prisoner = H
		var/droplocation = pick(GLOB.prisoner_start)
		var/obj/structure/closet/supplypod/arrival_pod = new()
		arrival_pod.explosionSize = list(0,0,0,1)
		arrival_pod.bluespace = TRUE
		prisoner.forceMove(arrival_pod)
		new /obj/effect/pod_landingzone(droplocation, arrival_pod)

/datum/job/prisoner/override_latejoin_spawn()
	return TRUE
