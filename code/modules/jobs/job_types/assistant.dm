/*
Assistant
*/
/datum/job/assistant
	title = "Assistant"
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT

/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant

	belt = /obj/item/storage/belt/utility/chief/full
	glasses = /obj/item/clothing/glasses/meson/engine
	gloves = /obj/item/clothing/gloves/combat
	uniform =  /obj/item/clothing/under/rank/engineering/chief_engineer
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	shoes = /obj/item/clothing/shoes/magboots/advance
	l_pocket = /obj/item/pda/heads/ce
	mask = /obj/item/clothing/mask/gas/atmos
	suit_store = /obj/item/tank/internals/oxygen/yellow
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced/command=1, /obj/item/construction/rcd/combat/admin=1, /obj/item/rcd_upgrade/frames=1, /obj/item/rcd_upgrade/simple_circuits=1, /obj/item/pipe_dispenser=1, /obj/item/lightreplacer=1)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/industrial
	duffelbag = /obj/item/storage/backpack/industrial
	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET