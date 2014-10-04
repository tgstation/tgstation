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
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue, access_weapons)
	minimal_access = list(access_bar,access_weapons)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/bar

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/under/rank/bartender(H), slot_w_uniform)
		//H.equip_or_collect(new /obj/item/device/pda/bar(H), slot_belt)

		if(H.backbag == 1)
			var/obj/item/weapon/storage/box/survival/Barpack = new H.species.survival_gear(H)
			H.equip_or_collect(Barpack, slot_r_hand)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
			new /obj/item/ammo_casing/shotgun/beanbag(Barpack)
		else
			H.equip_or_collect(new H.species.survival_gear(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/ammo_casing/shotgun/beanbag(H), slot_in_backpack)

		H.dna.SetSEState(SOBERBLOCK,1)
		H.mutations += M_SOBER
		H.check_mutations = 1

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
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue)
	minimal_access = list(access_kitchen, access_morgue, access_bar)
	alt_titles = list("Cook")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/chef

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/chef(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/chef(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/head/chefhat(H), slot_head)
		//H.equip_or_collect(new /obj/item/device/pda/chef(H), slot_belt)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
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
	access = list(access_hydroponics, access_bar, access_kitchen, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	minimal_access = list(access_hydroponics, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	alt_titles = list("Hydroponicist")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/botanist

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_service(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/hydroponics(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/gloves/botanic_leather(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/suit/apron(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/device/analyzer/plant_analyzer(H), slot_s_store)
		//H.equip_or_collect(new /obj/item/device/pda/botanist(H), slot_belt)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_taxi)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_taxi)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/quartermaster

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/quartermaster(H), slot_belt)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_or_collect(new /obj/item/weapon/clipboard(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_taxi)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting, access_taxi)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/cargo

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo(H), slot_ears)
		H.equip_or_collect(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/cargo(H), slot_belt)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
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
	idtype = /obj/item/weapon/card/id/supply
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mint, access_mining_station, access_mailsorting)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/shaftminer

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/device/radio/headset/headset_cargo (H), slot_ears)
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/rank/miner(H), slot_w_uniform)
		//H.equip_or_collect(new /obj/item/device/pda/shaftminer(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
//		H.equip_or_collect(new /obj/item/clothing/gloves/black(H), slot_gloves)
		if(H.backbag == 1)
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/weapon/crowbar(H), slot_l_hand)
			H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_l_store)
		else
			H.equip_or_collect(new /obj/item/weapon/storage/box/engineer(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/crowbar(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/storage/bag/ore(H), slot_in_backpack)
		if(prob(30)) //It was inevitable
			H.mutations.Add(M_DWARF)
			H.update_mutations()
			if(H.species.name == "Human" && !(H.f_style == "Dwarf Beard"))
				H.h_style = "Dwarf Beard"
				H.update_hair()
		return 1

/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/clown
	access = list(access_clown, access_theatre, access_maint_tunnels)
	minimal_access = list(access_clown, access_theatre)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/clown

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		H.equip_or_collect(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/clown(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/toy/crayon/rainbow(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
		H.equip_or_collect(new /obj/item/toy/waterflower(H), slot_in_backpack)
		H.mutations.Add(M_CLUMSY)
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
	idtype = /obj/item/weapon/card/id/mime
	access = list(access_mime, access_theatre, access_maint_tunnels)
	minimal_access = list(access_mime, access_theatre)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/mime

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		if(H.backbag == 2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(H.backbag == 3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		H.equip_or_collect(new /obj/item/clothing/under/mime(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/mime(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/gloves/white(H), slot_gloves)
		H.equip_or_collect(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
		H.equip_or_collect(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_or_collect(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
			H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_l_store)
			H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_l_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
			H.equip_or_collect(new /obj/item/toy/crayon/mime(H), slot_in_backpack)
			H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
		H.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(H)
		H.miming = 1
		return 1



/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_janitor, access_maint_tunnels)
	minimal_access = list(access_janitor, access_maint_tunnels)

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/janitor

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/rank/janitor(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		//H.equip_or_collect(new /obj/item/device/pda/janitor(H), slot_belt)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		// Now spawns on the janikart.  H.equip_or_collect(new /obj/item/key(H), slot_l_store)
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
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library)
	alt_titles = list("Journalist")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/librarian

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_or_collect(new /obj/item/clothing/under/suit_jacket/red(H), slot_w_uniform)
		//H.equip_or_collect(new /obj/item/device/pda/librarian(H), slot_belt)
		H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_or_collect(new /obj/item/weapon/barcodescanner(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		return 1



//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	idtype = /obj/item/weapon/card/id/centcom
	total_positions = 2
	spawn_positions = 2
	supervisors = "NanoTransen Law, CentComm Officals, and the stations captain."
	selection_color = "#dddddd"
	access = list(access_lawyer, access_court, access_sec_doors, access_maint_tunnels, access_cargo, access_medical,  access_bar, access_kitchen, access_hydroponics)
	minimal_access = list(access_lawyer, access_court, access_sec_doors, access_cargo,  access_bar, access_kitchen)
	alt_titles = list("Lawyer")

	pdaslot=slot_belt
	pdatype=/obj/item/device/pda/lawyer

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if (H.mind.role_alt_title)
			switch(H.mind.role_alt_title)
				if("Lawyer")
					H.equip_or_collect(new /obj/item/clothing/under/lawyer/bluesuit(H), slot_w_uniform)
					H.equip_or_collect(new /obj/item/clothing/suit/storage/lawyer/bluejacket(H), slot_wear_suit)
					H.equip_or_collect(new /obj/item/clothing/shoes/leather(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
		H.equip_or_collect(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
		H.equip_or_collect(new /obj/item/clothing/shoes/centcom(H), slot_shoes)
		H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		//H.equip_or_collect(new /obj/item/device/pda/lawyer(H), slot_belt)
		H.equip_or_collect(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_or_collect(new H.species.survival_gear(H), slot_r_hand)
		else
			H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		return 1
