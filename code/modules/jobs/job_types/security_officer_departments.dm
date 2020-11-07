// Engineering
/datum/job/officer/engineering
	title = "Engine Security"
	total_positions = 2
	spawn_positions = 1
	department_head = list("Head of Security", "Chief Engineer")
	supervisors = "the head of security and the chief engineer"
	selection_color = "#fff5cc"
	outfit = /datum/outfit/job/security/engineering
	department = SEC_DEPT_ENGINEERING
	display_order = JOB_DISPLAY_ORDER_ENGINEER_SECURITY

/datum/outfit/job/security/engineering
	name = "Security Officer (Engineering)"
	jobtype = /datum/job/officer/engineering

	uniform = /obj/item/clothing/under/rank/security/officer/grey
	gloves = /obj/item/clothing/gloves/color/yellow

// Medical
/datum/job/officer/medical
	title = "Police Medic"
	total_positions = 2
	spawn_positions = 1
	department_head = list("Head of Security", "Chief Medical Officer")
	supervisors = "the head of security and the chief medical officer"
	selection_color = "#ffeef0"
	outfit = /datum/outfit/job/security/medical
	department = SEC_DEPT_MEDICAL
	display_order = JOB_DISPLAY_ORDER_MEDICAL_SECURITY

/datum/outfit/job/security/medical
	name = "Security Officer (Medical)"
	jobtype = /datum/job/officer/medical

	uniform = /obj/item/clothing/under/rank/security/officer/formal
	head = /obj/item/clothing/head/beret/sec/navyofficer

// Sciences
/datum/job/officer/science
	title = "Laboratory Security"
	total_positions = 1
	spawn_positions = 1
	department_head = list("Head of Security", "Research Director")
	supervisors = "the head of security and the research director"
	selection_color = "#ffeeff"
	outfit = /datum/outfit/job/security/science
	department = SEC_DEPT_SCIENCE
	display_order = JOB_DISPLAY_ORDER_SCIENCE_SECURITY

/datum/outfit/job/security/science
	name = "Security Officer (Science)"
	jobtype = /datum/job/officer/science

	head = /obj/item/clothing/head/beret/science

// Service
/datum/job/officer/service
	title = "Bouncer"
	total_positions = 1
	spawn_positions = 1
	department_head = list("Head of Security", "Head of Personnel")
	supervisors = "the head of security and the head of personnel"
	selection_color = "#bbe291"
	outfit = /datum/outfit/job/security/service
	department = SEC_DEPT_SERVICE
	display_order = JOB_DISPLAY_ORDER_SERVICE_SECURITY

/datum/outfit/job/security/service
	name = "Security Officer (Service)"
	jobtype = /datum/job/officer/service

	uniform = /obj/item/clothing/under/suit/black
	gloves = null
	head = null
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

// Supply
/datum/job/officer/supply
	title = "Customs Officer"
	total_positions = 1
	spawn_positions = 1
	department_head = list("Head of Security", "Head of Personnel")
	supervisors = "the head of security and the head of personnel"
	selection_color = "#dcba97"
	outfit = /datum/outfit/job/security/supply
	department = SEC_DEPT_SUPPLY
	display_order = JOB_DISPLAY_ORDER_CARGO_SECURITY

/datum/outfit/job/security/supply
	name = "Security Officer (Supply)"
	jobtype = /datum/job/officer/supply

	uniform = /obj/item/clothing/under/rank/security/officer/grey
