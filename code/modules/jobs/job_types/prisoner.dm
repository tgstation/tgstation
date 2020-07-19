/datum/job/prisoner
	title = "Prisoner"
	flag = PRISONER
	department_head = list("The Security Team")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 4
	spawn_positions = 3
	supervisors = "the security team"
	selection_color = "#ffe1c3"
	paycheck = PAYCHECK_PRISONER
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
		var/obj/structure/closet/supplypod/securitypod/arrival_pod = new()
		prisoner.forceMove(arrival_pod)
		new /obj/effect/pod_landingzone(droplocation, arrival_pod)

/datum/job/prisoner/override_latejoin_spawn()
	return TRUE
