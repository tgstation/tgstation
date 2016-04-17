/datum/job/trader
	title = "Trader"
	flag = TRADER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 0
	spawn_positions = 3
	supervisors = "nobody"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	alt_titles = list("Merchant","Traveler","Vagabond")

	species_whitelist = list("Vox")
	must_be_map_enabled = 1

	no_random_roll = 1 //Don't become a vox trader randomly
	no_crew_manifest = 1

	//Don't spawn with any of the average crew member's luxuries
	no_starting_money = 1
	no_pda = 1
	no_id = 1
	no_headset = 1

/datum/job/trader/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/vox/vox_robes(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/magboots/vox(H), slot_shoes)

	switch(H.backbag) //BS12 EDIT
		if(2) H.equip_or_collect(new/obj/item/weapon/storage/backpack(H), slot_back)
		if(3) H.equip_or_collect(new/obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4) H.equip_or_collect(new/obj/item/weapon/storage/backpack/satchel(H), slot_back)

	H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)

	//Some food for the road
	H.equip_or_collect(new /obj/item/weapon/storage/box/donkpockets/random_amount(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/drinks/thermos/full(H.back), slot_in_backpack)
	H.equip_or_collect(new /obj/item/weapon/storage/wallet(H.back), slot_in_backpack)

	H.equip_or_collect(new /obj/item/device/radio(H), slot_belt)
	return 1

/datum/job/trader/introduce(mob/M, job_title)
	if(!job_title) job_title = src.title

	to_chat(M, "<B>You are a [job_title].</B>")

	if(map && map.nameShort == "meta") //Shitty way to do it, but whatever - traders start on a shuttle wreckage on metaclub, not on the vox outpost
		to_chat(M, "<b>A while ago you got your equipment together and boarded a small shuttle, heading for your destination (whatever it may be). Everything was great, until the shuttle somehow crashed into an asteroid. You're still alive, but you're not quite sure where you are. Maybe some of your friends know - unless they died in the crash...</b>")
	else
		to_chat(M, "<b>You've finally got your equipment together, such as it is. Now it's time for action and adventure! In the rush of excitement, you've forgotten where you were going to go. If only you had any friends that could remind you...</b>")

	to_chat(M, "<b>Despite not being a member of the crew, by default you are <u>not</u> an antagonist. Cooperating with antagonists is allowed - within reason. Ask admins via adminhelp if you're not sure.</b>")

	if(req_admin_notify)
		to_chat(M, "<b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
