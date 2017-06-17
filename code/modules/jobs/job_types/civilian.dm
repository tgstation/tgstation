/*
Clown
*/
/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/clown

	access = list(GLOB.access_theatre)
	minimal_access = list(GLOB.access_theatre)

/datum/job/clown/after_spawn(mob/living/carbon/human/H, mob/M)
	H.rename_self("clown", M.client)

/datum/outfit/job/clown
	name = "Clown"
	jobtype = /datum/job/clown

	belt = /obj/item/device/pda/clown
	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/weapon/bikehorn
	backpack_contents = list(
		/obj/item/weapon/stamp/clown = 1,
		/obj/item/weapon/reagent_containers/spray/waterflower = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1,
		)

	implants = list(/obj/item/weapon/implant/sad_trombone)

	backpack = /obj/item/weapon/storage/backpack/clown
	satchel = /obj/item/weapon/storage/backpack/clown
	duffelbag = /obj/item/weapon/storage/backpack/duffelbag/clown //strangely has a duffel

	box = /obj/item/weapon/storage/box/hug/survival


/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names))

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.dna.add_mutation(CLOWNMUT)

/*
Mime
*/
/datum/job/mime
	title = "Mime"
	flag = MIME
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/mime

	access = list(GLOB.access_theatre)
	minimal_access = list(GLOB.access_theatre)

/datum/job/mime/after_spawn(mob/living/carbon/human/H, mob/M)
	H.rename_self("mime", M.client)

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	belt = /obj/item/device/pda/mime
	uniform = /obj/item/clothing/under/rank/mime
	mask = /obj/item/clothing/mask/gas/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/beret
	suit = /obj/item/clothing/suit/suspenders
	backpack_contents = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing=1)

	backpack = /obj/item/weapon/storage/backpack/mime
	satchel = /obj/item/weapon/storage/backpack/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = 1

/*
Curator
*/
/datum/job/curator
	title = "Curator"
	flag = CURATOR
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/curator

	access = list(GLOB.access_library)
	minimal_access = list(GLOB.access_library, GLOB.access_construction,GLOB.access_mining_station)

/datum/outfit/job/curator
	name = "Curator"
	jobtype = /datum/job/curator

	belt = /obj/item/device/pda/curator
	uniform = /obj/item/clothing/under/rank/curator
	l_hand = /obj/item/weapon/storage/bag/books
	r_pocket = /obj/item/key/displaycase
	l_pocket = /obj/item/device/laser_pointer
	backpack_contents = list(
		/obj/item/weapon/melee/curator_whip = 1,
		/obj/item/soapstone = 1,
		/obj/item/weapon/barcodescanner = 1
	)


/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(omnitongue=TRUE)

/*
Lawyer
*/
/datum/job/lawyer
	title = "Lawyer"
	flag = LAWYER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	var/lawyers = 0 //Counts lawyer amount

	outfit = /datum/outfit/job/lawyer

	access = list(GLOB.access_lawyer, GLOB.access_court, GLOB.access_sec_doors)
	minimal_access = list(GLOB.access_lawyer, GLOB.access_court, GLOB.access_sec_doors)

/datum/outfit/job/lawyer
	name = "Lawyer"
	jobtype = /datum/job/lawyer

	belt = /obj/item/device/pda/lawyer
	ears = /obj/item/device/radio/headset/headset_sec
	uniform = /obj/item/clothing/under/lawyer/bluesuit
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/weapon/storage/briefcase/lawyer
	l_pocket = /obj/item/device/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge


/datum/outfit/job/lawyer/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	var/datum/job/lawyer/J = SSjob.GetJobType(jobtype)
	J.lawyers++
	if(J.lawyers>1)
		uniform = /obj/item/clothing/under/lawyer/purpsuit
		suit = /obj/item/clothing/suit/toggle/lawyer/purple
