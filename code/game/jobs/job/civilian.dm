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

	default_pda = /obj/item/device/pda/clown
	default_backpack = /obj/item/weapon/storage/backpack/clown

	access = list(access_theatre)
	minimal_access = list(access_theatre)

/datum/job/clown/equip_backpack(var/mob/living/carbon/human/H)
	var/obj/item/weapon/storage/backpack/BPK = new default_backpack(H)

	new default_storagebox(BPK)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(BPK, 50)
	new /obj/item/weapon/stamp/clown(BPK)
	new /obj/item/weapon/reagent_containers/spray/waterflower(BPK)

	H.equip_to_slot_or_del(BPK, slot_back)

/datum/job/clown/equip_items(var/mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, pick(clown_names)) // Give him a temporary random name to prevent identity revealing

	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(H), slot_r_store)

	H.dna.add_mutation(CLOWNMUT)
	H.rename_self("clown")

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

	default_pda = /obj/item/device/pda/mime
	default_backpack = /obj/item/weapon/storage/backpack/mime

	access = list(access_theatre)
	minimal_access = list(access_theatre)

/datum/job/mime/equip_backpack(var/mob/living/carbon/human/H)
	var/obj/item/weapon/storage/backpack/BPK = new default_backpack(H)

	new default_storagebox(BPK)
	new /obj/item/toy/crayon/mime(BPK)
	new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(BPK)

	H.equip_to_slot_or_del(BPK, slot_back)

/datum/job/mime/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/mime(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = 1

	H.rename_self("mime")

/*
Librarian
*/
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	default_pda = /obj/item/device/pda/librarian

	access = list(access_library)
	minimal_access = list(access_library)

/datum/job/librarian/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/librarian(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/bag/books(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/weapon/barcodescanner(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/device/laser_pointer(H), slot_l_store)

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
	var/global/lawyers = 0 //Counts lawyer amount

	default_pda = /obj/item/device/pda/lawyer
	default_headset = /obj/item/device/radio/headset/headset_sec

	access = list(access_lawyer, access_court, access_sec_doors)
	minimal_access = list(access_lawyer, access_court, access_sec_doors)

/datum/job/lawyer/equip_items(var/mob/living/carbon/human/H)
	lawyers += 1

	switch(lawyers)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/bluesuit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/lawyer(H), slot_wear_suit)
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/purpsuit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/lawyer/purple(H), slot_wear_suit)

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/device/laser_pointer(H), slot_l_store)
