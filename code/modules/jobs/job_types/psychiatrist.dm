/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_head = list("Head of Security")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeeee"

	outfit = /datum/outfit/job/psychiatrist

	access = list(ACCESS_MEDICAL, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM,ACCESS_PSYCHIATRIST)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM,ACCESS_PSYCHIATRIST)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	mind_traits = list(TRAIT_PSYCHIATRIST)

	display_order = JOB_DISPLAY_ORDER_PSYCHIATRIST

/datum/outfit/job/psychiatrist
	name = "Psychiatrist"
	jobtype = /datum/job/psychiatrist
	belt = /obj/item/pda/clear
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/civilian/curator
	shoes = /obj/item/clothing/shoes/laceup
	suit =  /obj/item/clothing/suit/toggle/labcoat/psychiatrist
	suit_store = /obj/item/flashlight/pen
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	glasses = /obj/item/clothing/glasses/regular/hipster

	backpack_contents = list(/obj/item/storage/box/psych_box)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe

/obj/item/storage/box/psych_box
	name = "psychoactive drugs box"
	desc = "A box containing the essentials to treating mental illnesses"

/obj/item/storage/box/psych_box/PopulateContents()
	new /obj/item/storage/pill_bottle/happiness(src)
	new	/obj/item/storage/pill_bottle/psicodine(src)
	new /obj/item/storage/pill_bottle/neurine(src)
	new /obj/item/storage/pill_bottle/haloperidol(src)
	new /obj/item/storage/pill_bottle/lithium_carbonate(src)

