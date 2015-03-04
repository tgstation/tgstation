/*
Quartermaster
*/
/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"

	default_pda = /obj/item/device/pda/quartermaster
	default_headset = /obj/item/device/radio/headset/headset_cargo

	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station, access_mineral_storeroom)

/datum/job/qm/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/weapon/clipboard(H), slot_l_hand)

/*
Cargo Technician
*/
/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	default_pda = /obj/item/device/pda/cargo
	default_headset = /obj/item/device/radio/headset/headset_cargo

	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)

/datum/job/cargo_tech/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)

/*
Shaft Miner
*/
/datum/job/mining
	title = "Shaft Miner"
	flag = MINER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	default_pda = /obj/item/device/pda/shaftminer
	default_headset = /obj/item/device/radio/headset/headset_cargo
	default_backpack = /obj/item/weapon/storage/backpack/industrial
	default_satchel = /obj/item/weapon/storage/backpack/satchel_eng
	default_storagebox = /obj/item/weapon/storage/box/engineer

	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station, access_mineral_storeroom)
	minimal_access = list(access_mining, access_mining_station, access_mailsorting, access_mineral_storeroom)

/datum/job/mining/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)

	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/bag/ore(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/mining_voucher(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/patch/styptic(H), slot_r_store)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/mining_voucher(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/patch/styptic(H), slot_l_store)

/*
Bartender
*/
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	default_pda = /obj/item/device/pda/bar
	default_headset = /obj/item/device/radio/headset/headset_srv

	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons)
	minimal_access = list(access_bar)

/datum/job/bartender/equip_backpack(var/mob/living/carbon/human/H)
	switch(H.backbag)
		if(1) //No backpack or satchel

			var/obj/item/weapon/storage/box/box = new default_storagebox(H)
			new /obj/item/ammo_casing/shotgun/beanbag(box)
			new /obj/item/ammo_casing/shotgun/beanbag(box)
			new /obj/item/ammo_casing/shotgun/beanbag(box)
			new /obj/item/ammo_casing/shotgun/beanbag(box)
			H.equip_to_slot_or_del(box, slot_r_hand)

		if(2) // Backpack
			var/obj/item/weapon/storage/backpack/BPK = new default_backpack(H)
			new default_storagebox(BPK)
			H.equip_to_slot_or_del(BPK, slot_back,1)
		if(3) //Satchel
			var/obj/item/weapon/storage/backpack/BPK = new default_satchel(H)
			new default_storagebox(BPK)
			H.equip_to_slot_or_del(BPK, slot_back,1)

/datum/job/bartender/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)

	if(H.backbag != 1)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

/*
Cook
*/
/datum/job/cook
	title = "Cook"
	flag = COOK
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	var/global/cooks = 0 //Counts cooks amount

	default_pda = /obj/item/device/pda/cook
	default_headset = /obj/item/device/radio/headset/headset_srv

	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_kitchen, access_morgue)

/datum/job/cook/equip_items(var/mob/living/carbon/human/H)
	cooks += 1

	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	switch(cooks)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/chef(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(H), slot_head)
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron/chef(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/mime(H), slot_head)

/*
Botanist
*/
/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	default_pda = /obj/item/device/pda/botanist
	default_headset = /obj/item/device/radio/headset/headset_srv

	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	minimal_access = list(access_hydroponics, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.

/datum/job/hydro/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)

/*
Janitor
*/
/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	var/global/janitors = 0

	default_pda = /obj/item/device/pda/janitor
	default_headset = /obj/item/device/radio/headset/headset_srv

	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)

/datum/job/janitor/equip_items(var/mob/living/carbon/human/H)
	janitors += 1

	if(H.backbag != 1)
		switch(janitors)
			if(1)
				H.equip_to_slot_or_del(new /obj/item/key/janitor(H), slot_in_backpack)
			else
				H.equip_to_slot_or_del(new /obj/item/weapon/soap/deluxe(H), slot_in_backpack)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
