/// Possible assignments corpses can have, both for flavor and to push them towards contributing to the round
/datum/corpse_assignment
	/// Message we send to the player upon revival concerning their job
	var/job_lore
	/// Gear to give to the crewie in a special locked box
	var/list/job_stuffs
	/// Trim on the ID we give to the revived person (no trim = no id)
	var/datum/id_trim/trim

/datum/corpse_assignment/proc/apply_assignment(mob/living/carbon/human/working_dead, list/job_gear)
	for(var/item in job_stuffs)
		job_gear += new item ()
	job_gear += job_stuffs

	if(trim)
		var/obj/item/card/id/advanced/card = new()
		card.registered_name = working_dead.name
		card.registered_age = working_dead.age
		SSid_access.apply_trim_to_card(card, trim)
		job_gear += card

/datum/corpse_assignment/engineer
	job_lore = "I was employed as an engineer"
	job_stuffs = list(/obj/item/clothing/under/rank/engineering/engineer)
	trim = /datum/id_trim/job/visiting_engineer

/datum/id_trim/job/visiting_engineer
	assignment = JOB_LOSTCREW_ENGINEER
	trim_state = "trim_stationengineer"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_STATION_ENGINEER
	minimal_access = list(
		ACCESS_CONSTRUCTION,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		)

/datum/corpse_assignment/medical
	job_lore = "I was employed as a doctor"
	job_stuffs = list(/obj/item/clothing/under/rank/medical/doctor)
	trim = /datum/id_trim/job/visiting_doctor

/datum/id_trim/job/visiting_doctor
	assignment = JOB_LOSTCREW_MEDICAL
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_MEDICAL_DOCTOR

	minimal_access = list(
		ACCESS_MEDICAL,
		)

/datum/corpse_assignment/security
	job_lore = "I was employed as security"
	job_stuffs = list(/obj/item/clothing/under/rank/security/officer)
	trim = /datum/id_trim/job/visiting_security

/datum/corpse_assignment/security/apply_assignment(mob/living/carbon/human/working_dead, list/job_gear)
	. = ..()

	var/obj/item/implant/mindshield/shield = new()
	shield.implant(working_dead)

/datum/id_trim/job/visiting_security
	assignment = JOB_LOSTCREW_SECURITY
	trim_state = "trim_securityofficer"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITY_OFFICER

	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		)

/datum/corpse_assignment/science
	job_lore = "I was employed as a scientist"
	job_stuffs = list(/obj/item/clothing/under/rank/rnd/scientist)
	trim = /datum/id_trim/job/visiting_scientist

/datum/id_trim/job/visiting_scientist
	assignment = JOB_LOSTCREW_SCIENCE
	trim_state = "trim_scientist"
	department_color = COLOR_SCIENCE_PINK
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_SCIENTIST
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_SCIENCE,
		)

/datum/corpse_assignment/cargo
	job_lore = "I was employed as a technician"
	job_stuffs = list(/obj/item/clothing/under/rank/cargo/tech)
	trim = /datum/id_trim/job/visiting_technician

/datum/id_trim/job/visiting_technician
	assignment = JOB_LOSTCREW_CARGO
	trim_state = "trim_cargotechnician"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_CARGO_BROWN
	sechud_icon_state = SECHUD_CARGO_TECHNICIAN
	minimal_access = list(
		ACCESS_CARGO,
		ACCESS_MAINT_TUNNELS,
		)

/datum/corpse_assignment/civillian
	job_lore = "I was employed as a civllian"
	job_stuffs = list(/obj/item/clothing/under/color/grey)
	trim = /datum/id_trim/job/visiting_civillian

/datum/id_trim/job/visiting_civillian
	assignment = JOB_LOSTCREW_CIVILLIAN
	trim_state = "trim_assistant"
	sechud_icon_state = SECHUD_ASSISTANT
	minimal_access = list()
	extra_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_SERVICE,
		)
