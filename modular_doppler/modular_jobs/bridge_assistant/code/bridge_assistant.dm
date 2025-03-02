/datum/job/bridge_assistant
	title = JOB_BRIDGE_ASSISTANT
	description = "Watch over the Bridge, command its consoles, and spend your days brewing coffee for higher-ups."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Captain, and in non-Bridge related situations the other heads"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BRIDGE_ASSISTANT"

	outfit = /datum/outfit/job/bridge_assistant
	plasmaman_outfit = /datum/outfit/plasmaman/bridge_assistant

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV
	bounty_types = CIV_JOB_DRINK

	display_order = JOB_DISPLAY_ORDER_BRIDGE_ASSISTANT
	department_for_prefs = /datum/job_department/service
	departments_list = list(
		/datum/job_department/command,
		/datum/job_department/service,
	)
	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	family_heirlooms = list(/obj/item/soap/nanotrasen)

	mail_goodies = list(
		/obj/item/storage/bag/tray = 1,
		/obj/item/vending_refill/cigarette = 1,
		/obj/item/vending_refill/coffee = 1,
	)
	job_flags = STATION_JOB_FLAGS
	rpg_title = "Royal Page"

/datum/job/bridge_assistant/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/mob/living/carbon/bridgie = spawned
	if(istype(bridgie))
		bridgie.gain_trauma(/datum/brain_trauma/special/axedoration)

/datum/outfit/job/bridge_assistant
	name = "Bridge Assistant"
	jobtype = /datum/job/bridge_assistant

	id_trim = /datum/id_trim/job/bridge_assistant
	backpack_contents = list(
		/obj/item/choice_beacon/coffee = 1,
	)

	uniform = /obj/item/clothing/under/misc/doppler_uniform/command
	ears = /obj/item/radio/headset/heads/hop
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret/doppler_command/light
	belt = /obj/item/modular_computer/pda/bridge_assistant
	r_pocket = /obj/item/pen/edagger/bridge_assistant
	l_pocket = /obj/item/clipboard

/obj/item/pen/edagger/bridge_assistant
	icon = 'modular_doppler/modular_jobs/bridge_assistant/icons/edagger.dmi'
	dart_insert_icon = 'modular_doppler/modular_jobs/bridge_assistant/icons/edagger.dmi'
	lefthand_icon = 'modular_doppler/modular_jobs/bridge_assistant/icons/edagger_lefthand.dmi'
	righthand_icon = 'modular_doppler/modular_jobs/bridge_assistant/icons/edagger_righthand.dmi'
	light_color = "#82fa8c"

/datum/id_trim/job/bridge_assistant
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_COMMAND_BLUE
