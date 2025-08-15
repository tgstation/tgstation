/// Possible assignments corpses can have, both for flavor and to push them towards contributing to the round
/datum/corpse_assignment
	/// Message we send to the player upon revival concerning their job
	var/job_lore
	/// Gear to give to the crewie in a special locked box
	var/list/protected_job_stuffs
	/// Gear that arrives with the crewie in the crate
	var/list/recovered_job_stuffs
	/// Trim on the ID we give to the revived person (no trim = no id)
	var/datum/id_trim/trim
	/// Job datum to apply to the human
	var/datum/job/job_datum

/datum/corpse_assignment/proc/apply_assignment(mob/living/carbon/human/working_dead, list/protected_job_gear, list/recovered_job_gear, list/datum/callback/on_revive_and_player_occupancy)
	if(!protected_job_gear && !recovered_job_gear && !trim)
		return

	for(var/item in protected_job_stuffs)
		protected_job_gear += new item ()

	for(var/item in recovered_job_stuffs)
		recovered_job_gear += new item ()

	if(job_datum)
		on_revive_and_player_occupancy += CALLBACK(src, PROC_REF(assign_job), working_dead) //this needs to happen once the body has been successfully occupied and revived

	if(trim)
		var/obj/item/card/id/advanced/card = new()
		card.registered_name = working_dead.name
		card.registered_age = working_dead.age
		SSid_access.apply_trim_to_card(card, trim)
		protected_job_gear += card

/datum/corpse_assignment/proc/assign_job(mob/living/carbon/human/working_undead)
	working_undead.mind.set_assigned_role_with_greeting(new job_datum (), working_undead.client)

/datum/corpse_assignment/engineer
	job_lore = "I was employed as an engineer"
	protected_job_stuffs = list(/obj/item/radio/headset/headset_eng)
	recovered_job_stuffs = list(/obj/item/clothing/under/rank/engineering/engineer)
	trim = /datum/id_trim/job/visiting_engineer
	job_datum = /datum/job/recovered_crew/engineer

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
	protected_job_stuffs = list(/obj/item/radio/headset/headset_med)
	recovered_job_stuffs = list(/obj/item/clothing/under/rank/medical/doctor)
	trim = /datum/id_trim/job/visiting_doctor
	job_datum = /datum/job/recovered_crew/doctor

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
	protected_job_stuffs = list(/obj/item/radio/headset/headset_sec)
	recovered_job_stuffs = list(/obj/item/clothing/under/rank/security/officer)
	trim = /datum/id_trim/job/visiting_security
	job_datum = /datum/job/recovered_crew/security

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
	protected_job_stuffs = list(/obj/item/radio/headset/headset_sci)
	recovered_job_stuffs = list(/obj/item/clothing/under/rank/rnd/scientist)
	trim = /datum/id_trim/job/visiting_scientist
	job_datum = /datum/job/recovered_crew/scientist

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
	protected_job_stuffs = list(/obj/item/radio/headset/headset_cargo)
	recovered_job_stuffs = list(/obj/item/clothing/under/rank/cargo/tech)
	trim = /datum/id_trim/job/visiting_technician
	job_datum = /datum/job/recovered_crew/cargo

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
	protected_job_stuffs = list(/obj/item/radio/headset)
	recovered_job_stuffs = list(/obj/item/clothing/under/color/grey)
	trim = /datum/id_trim/job/visiting_civillian
	job_datum = /datum/job/recovered_crew/civillian

/datum/id_trim/job/visiting_civillian
	assignment = JOB_LOSTCREW_CIVILLIAN
	trim_state = "trim_assistant"
	sechud_icon_state = SECHUD_ASSISTANT
	minimal_access = list()
	extra_access = list(
		ACCESS_MAINT_TUNNELS,
		ACCESS_SERVICE,
		)
