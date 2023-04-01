/obj/effect/landmark/start/barber
	name = "Barber"
	icon_state = "Barber"

/datum/job/barber
	title = JOB_BARBER
	description = "Cut hair, dye hair, listen to complaints from customers about their day."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/barber
	plasmaman_outfit = /datum/outfit/plasmaman

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BARBER
	bounty_types = CIV_JOB_RANDOM
	departments_list = list(
		/datum/job_department/service,
	)
	rpg_title = "Barber Surgeon"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS
	family_heirlooms = list(/obj/item/scissors)

/datum/outfit/job/barber
	name = "Barber"
	jobtype = /datum/job/barber

	id_trim = /datum/id_trim/job/barber
	uniform = /obj/item/clothing/under/costume/dutch
	belt = /obj/item/modular_computer/pda
	ears = /obj/item/radio/headset/headset_srv
	l_hand = /obj/item/scissors
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival

/datum/id_trim/job/barber
	assignment = "Barber"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	trim_state = "trim_barber"
	extra_access = list(ACCESS_HYDROPONICS)
	minimal_access = list(ACCESS_MINERAL_STOREROOM, ACCESS_SERVICE)
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)
	job = /datum/job/barber

/obj/item/scissors
	name = "scissors"
	desc = "A pair of sharp scissors."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "scissors"
	var/mob/living/carbon/human/haircut_target
	var/mob/living/carbon/human/dummy
	var/atom/movable/screen/dummy_screen

/obj/item/scissors/ui_close(mob/user)
	user.client.clear_map(dummy_screen.assigned_map)
	qdel(dummy)
	qdel(dummy_screen)

/obj/item/scissors/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		user.client.register_map_obj(dummy_screen)
		ui = new(user, src, "BarberPanel")
		ui.open()

/obj/item/scissors/ui_data(mob/user)
	var/list/data = list()
	data["hairstyles"] = GLOB.hairstyles_list
	data["selected_hairstyle"] = haircut_target.hairstyle
	data["facial_hairstyles"] = GLOB.facial_hairstyles_list
	data["selected_facial_hairstyle"] = haircut_target.facial_hairstyle
	data["assigned_map"] = dummy_screen.assigned_map
	return data

/obj/item/scissors/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select_hair")
			var/hairstyle = params["name"]
			haircut_target.hairstyle = hairstyle
			dummy.hairstyle = hairstyle
			haircut_target.update_hair()
			dummy.update_hair()
			haircut_target.dna.update_dna_identity()
			haircut_target.regenerate_icons()
			playsound(haircut_target, 'sound/items/scissors.ogg', 100)
			. = TRUE
		if("select_beard")
			var/hairstyle = params["name"]
			haircut_target.facial_hairstyle = hairstyle
			dummy.facial_hairstyle = hairstyle
			haircut_target.update_hair()
			dummy.update_hair()
			haircut_target.dna.update_dna_identity()
			haircut_target.regenerate_icons()
			playsound(haircut_target, 'sound/items/scissors.ogg', 100)
			. = TRUE

/obj/item/scissors/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(target == user)
		to_chat(user, "You can't use scissors on yourself. You'll make your hair look terrible!")
		return
	if(ishuman(target))
		haircut_target = target
		dummy = generate_dummy_lookalike(REF(haircut_target), haircut_target)
		haircut_target?.client?.prefs?.safe_transfer_prefs_to(dummy)
		dummy.dna.update_dna_identity()
		dummy_screen = new
		dummy_screen.vis_contents += dummy
		dummy_screen.name = "screen"
		dummy_screen.assigned_map = "haircut_[REF(src)]_map"
		dummy_screen.del_on_map_removal = FALSE
		dummy_screen.screen_loc = "[dummy_screen.assigned_map]:1,1"
		ui_interact(user)
		return

/datum/supply_pack/service/scissors
	name = "Scissors Crate"
	desc = "Contains 3 extra scissors for Barbers."
	cost = CARGO_CRATE_VALUE
	access_view = ACCESS_SERVICE
	access = ACCESS_SERVICE
	contains = list(/obj/item/scissors = 3)
