/datum/map_template/shuttle/voidcrew/resistance
	name = "Resistance-Class IRA Safehouse"
	suffix = "irish"
	short_name = "Resistance-class"

	job_slots = list(
		list(
			name = "IRA Leader",
			officer = TRUE,
			outfit = /datum/outfit/job/assistant/provo,
			slots = 1,
		),
		list(
			name = "IRA Member",
			outfit = /datum/outfit/job/assistant/provo,
			slots = 5,
		),
	)

/datum/outfit/job/assistant/provo
	name = "Provisional IRA Member"

	head = /obj/item/clothing/head/beret/sec
	mask = /obj/item/clothing/mask/balaclava
	gloves = /obj/item/clothing/gloves/color/black
	neck = /obj/item/clothing/neck/tie/red
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
