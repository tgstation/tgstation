#define JOB_MODIFICATION_MAP_NAME "ScienceStation"

// Research Director - all-access / Captain equivalent.
/datum/job/rd/New()
	..()
	MAP_JOB_CHECK
	supervisors = "Nanotrasen and Central Command"

/datum/job/rd/get_access()
	MAP_JOB_CHECK_BASE
	return get_all_accesses()

/datum/job/rd/announce(mob/living/carbon/human/H)
	..()
	MAP_JOB_CHECK
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Director [H.real_name] on deck!"))

/datum/outfit/job/rd/New()
	..()
	MAP_JOB_CHECK
	id = /obj/item/card/id/gold
	ears = /obj/item/device/radio/headset/heads/captain/alt
	backpack_contents[/obj/item/station_charter] = 1

// Lieutenant - a CentCom representative to replace the Head of Personnel.
/datum/job/hop/New()
	..()
	MAP_JOB_CHECK
	title = "Lieutenant"
	supervisors = "Nanotrasen and Central Command"
	GLOB.command_positions |= "Lieutenant"

/datum/job/hop/get_access()
	. = ..()
	MAP_JOB_CHECK
	. += ACCESS_BRIG
	. -= ACCESS_ENGINE

/datum/outfit/job/hop/New()
	..()
	MAP_JOB_CHECK

	uniform = /obj/item/clothing/under/rank/centcom_officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/device/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	belt = /obj/item/gun/ballistic/revolver/mateba
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/device/pda/heads/hop
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id

	backpack = /obj/item/storage/backpack/satchel/leather
	satchel = /obj/item/storage/backpack/satchel/leather
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	pda_slot = slot_l_store

	implants = list(/obj/item/implant/mindshield)
	backpack_contents -= /obj/item/device/modular_computer/tablet/preset/advanced
	backpack_contents[/obj/item/storage/wallet/random] = 1

/datum/outfit/job/hop/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	MAP_JOB_CHECK
	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"

// Lieutenant oversees the Janitor and Warden and handles supply
/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1
	supervisors = "the Lieutenant"

/datum/job/warden/New()
	..()
	MAP_JOB_CHECK
	supervisors = "the Lieutenant"

// Research Director oversees unlimited scientists and cyborgs
/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	title = "Physical Scientist"
	supervisors = "the Research Director"
	total_positions = -1
	spawn_positions = -1

/datum/job/scientist/get_access()
	. = ..()
	MAP_JOB_CHECK
	. -= list(ACCESS_XENOBIOLOGY)
	. |= list(ACCESS_ROBOTICS)

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	title = "Biological Scientist"
	supervisors = "the Research Director"
	total_positions = -1
	spawn_positions = -1

/datum/job/doctor/get_access()
	. = ..()
	MAP_JOB_CHECK
	. |= list(ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_XENOBIOLOGY, ACCESS_VIROLOGY)

/datum/job/cyborg/New()
	..()
	MAP_JOB_CHECK
	total_positions = -1
	spawn_positions = -1

// Borgs are restricted to Engineering and Mining duty only
/mob/living/silicon/robot/pick_module()
	MAP_JOB_CHECK_BASE
	if(module.type != /obj/item/robot_module)
		return
	if(wires.is_cut(WIRE_RESET_MODULE))
		to_chat(src,"<span class='userdanger'>ERROR: Module installer reply timeout. Please check internal connections.</span>")
		return

	var/list/modulelist = list("Engineering" = /obj/item/robot_module/engineering, "Miner" = /obj/item/robot_module/miner)
	var/input_module = input("Please, select a module!", "Robot", null, null) as null|anything in modulelist
	if(!input_module || module.type != /obj/item/robot_module)
		return
	module.transform_to(modulelist[input_module])

// Everyone else begone
MAP_REMOVE_JOB(captain)
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(clown)
MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(mining)
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(engineer)
MAP_REMOVE_JOB(atmos)
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(roboticist)
MAP_REMOVE_JOB(hos)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(officer)
MAP_REMOVE_JOB(ai)
MAP_REMOVE_JOB(assistant)
