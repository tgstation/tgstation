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
		if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/pda/bar(H), slot_belt)

		if(H.backbag == 1)
			var/obj/item/weapon/storage/box/survival/Barpack = new /obj/item/weapon/storage/box/survival(H)
			H.equip_to_slot_or_del(Barpack, slot_r_hand)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/pda/chef(H), slot_belt)
		return 1



/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#dddddd"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
		H.equip_to_slot_or_del(new /obj/item/device/pda/botanist(H), slot_belt)
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
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/qm(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/quartermaster(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_to_slot_or_del(new /obj/item/weapon/clipboard(H), slot_l_hand)
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
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/cargo(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
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
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_mine (H), slot_ears)
		if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial (H), slot_back)
		if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/pda/shaftminer(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_l_hand)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/satchel(H), slot_l_store)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/satchel(H), slot_in_backpack)
		return 1



//Griff //BS12 EDIT
/*
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
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/clown(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/crayonbox(H), slot_in_backpack)
		H.mutations.Add(CLUMSY)
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
		if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/mime(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/mime(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			H.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(H), slot_l_store)
			H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_l_hand)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
			H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/janitor(H), slot_belt)
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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/pda/librarian(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/barcodescanner(H), slot_l_hand)
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
		if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(!lawyer)
			lawyer = 1
			H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/bluesuit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/lawyer/bluejacket(H), slot_wear_suit)
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/under/lawyer/purpsuit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/lawyer/purpjacket(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)

		return 1


