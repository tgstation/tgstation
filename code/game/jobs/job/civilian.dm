//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_norm(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/suit/armor/vest(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/under/rank/bartender(H), H.slot_w_uniform)

		if(H.backbag == 1)
			var/obj/item/weapon/storage/box/Barpack = new /obj/item/weapon/storage/box(H)
			H.equip_if_possible(Barpack, H.slot_r_hand)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/ammo_casing/shotgun/beanbag(H), H.slot_in_backpack)

		return 1



/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/rank/chef(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/chef(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/head/chefhat(H), H.slot_head)
		return 1



/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_hyd(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/clothing/gloves/botanic_leather(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/suit/storage/apron(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/device/analyzer/plant_analyzer(H), H.slot_s_store)
		H.equip_if_possible(new /obj/item/device/pda/botanist(H), H.slot_belt)
		return 1



//Cargo
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/heads/qm(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/cargo(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/quartermaster(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(H), H.slot_glasses)
		H.equip_if_possible(new /obj/item/weapon/clipboard(H), H.slot_r_store)
		return 1



/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/under/rank/cargo(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/quartermaster(H), H.slot_belt)
		return 1



/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/device/radio/headset/headset_mine (H), H.slot_ears)
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial (H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		if(H.backbag == 4) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel_eng(H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/pda/shaftminer(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/under/rank/miner(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box(H), H.slot_r_hand)
			H.equip_if_possible(new /obj/item/weapon/crowbar(H), H.slot_l_hand)
			H.equip_if_possible(new /obj/item/weapon/satchel(H), H.slot_l_store)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box(H.back), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/weapon/crowbar(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/weapon/satchel(H), H.slot_in_backpack)
		return 1



/*
//Griff
/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/weapon/storage/backpack/clown(H), H.slot_back)
		H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H.back), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/clothing/under/rank/clown(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/clown(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/bikehorn(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/stamp/clown(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/toy/crayon/rainbow(H), H.slot_in_backpack)
		H.equip_if_possible(new /obj/item/weapon/storage/crayonbox(H), H.slot_in_backpack)
		H.mutations |= CLOWN
		return 1



/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_if_possible(new /obj/item/weapon/storage/backpack(H), H.slot_back)
		if(H.backbag == 3) H.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(H), H.slot_back)
		H.equip_if_possible(new /obj/item/clothing/under/mime(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/mime(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/gloves/white(H), H.slot_gloves)
		H.equip_if_possible(new /obj/item/clothing/mask/gas/mime(H), H.slot_wear_mask)
		H.equip_if_possible(new /obj/item/clothing/head/beret(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/suit/suspenders(H), H.slot_wear_suit)
		if(H.backbag == 1)
			H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H), H.slot_r_hand)
			H.equip_if_possible(new /obj/item/toy/crayon/mime(H), H.slot_l_store)
			H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), H.slot_l_hand)
		else
			H.equip_if_possible(new /obj/item/weapon/storage/box/survival(H.back), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/toy/crayon/mime(H), H.slot_in_backpack)
			H.equip_if_possible(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), H.slot_in_backpack)
		H.verbs += /client/proc/mimespeak
		H.verbs += /client/proc/mimewall
		H.mind.special_verbs += /client/proc/mimespeak
		H.mind.special_verbs += /client/proc/mimewall
		H.miming = 1
		return 1
*/



/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/rank/janitor(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/janitor(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/device/portalathe(H), H.slot_in_backpack)
		return 1



//More or less assistants
/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_if_possible(new /obj/item/clothing/under/suit_jacket/red(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/device/pda/librarian(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/clothing/shoes/black(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/weapon/barcodescanner(H), H.slot_l_store)
		return 1



var/global/lawyer = 0//Checks for another lawyer
/datum/job/lawyer
	title = "Lawyer"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(!lawyer)
			lawyer = 1
			H.equip_if_possible(new /obj/item/clothing/under/lawyer/bluesuit(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/suit/lawyer/bluejacket(H), H.slot_wear_suit)
		else
			H.equip_if_possible(new /obj/item/clothing/under/lawyer/purpsuit(H), H.slot_w_uniform)
			H.equip_if_possible(new /obj/item/clothing/suit/lawyer/purpjacket(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/shoes/brown(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/device/pda/lawyer(H), H.slot_belt)
		H.equip_if_possible(new /obj/item/weapon/storage/briefcase(H), H.slot_l_hand)
		return 1


