GLOBAL_DATUM(colored_assistant, /datum/colored_assistant)

/*
Assistant
*/
/datum/job/assistant
	title = JOB_ASSISTANT
	description = "Get your space legs, assist people, ask the HoP to give you a job."
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	exp_granted_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/assistant
	plasmaman_outfit = /datum/outfit/plasmaman
	paycheck = PAYCHECK_LOWER // Get a job. Job reassignment changes your paycheck now. Get over it.

	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	liver_traits = list(TRAIT_MAINTENANCE_METABOLISM)

	department_for_prefs = /datum/job_department/assistant

	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)

	mail_goodies = list(
		/obj/effect/spawner/random/food_or_drink/donkpockets = 10,
		/obj/item/clothing/mask/gas = 10,
		/obj/item/clothing/gloves/color/fyellow = 7,
		/obj/item/choice_beacon/music = 5,
		/obj/item/toy/sprayoncan = 3,
		/obj/item/crowbar/large = 1
	)

	job_flags = STATION_JOB_FLAGS
	rpg_title = "Lout"
	config_tag = "ASSISTANT"

/datum/job/assistant/get_outfit(consistent)
	if(consistent)
		return /datum/outfit/job/assistant/consistent
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_ASSISTANT_GIMMICKS))
		return ..()

	var/static/list/gimmicks = list()
	if(!length(gimmicks))
		for(var/datum/outfit/job/assistant/gimmick/gimmick_outfit as anything in subtypesof(/datum/outfit/job/assistant/gimmick))
			gimmicks[gimmick_outfit] = gimmick_outfit::outfit_weight

	return pick_weight(gimmicks)

/datum/outfit/job/assistant
	name = JOB_ASSISTANT
	jobtype = /datum/job/assistant
	id_trim = /datum/id_trim/job/assistant
	belt = /obj/item/modular_computer/pda/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/target)
	..()
	for(var/holidayname in GLOB.holidays)
		var/datum/holiday/holiday_today = GLOB.holidays[holidayname]
		var/obj/item/special_hat = holiday_today.holiday_hat
		if(prob(HOLIDAY_HAT_CHANCE) && !isnull(special_hat) && isnull(head))
			head = special_hat

	give_jumpsuit(target)

/datum/outfit/job/assistant/proc/give_jumpsuit(mob/living/carbon/human/target)
	var/static/jumpsuit_number = 0
	jumpsuit_number += 1

	if (isnull(GLOB.colored_assistant))
		var/configured_type = get_configured_colored_assistant_type()
		GLOB.colored_assistant = new configured_type

	var/index = (jumpsuit_number % GLOB.colored_assistant.jumpsuits.len) + 1

	//We don't cache these, because they can delete on init
	//Too fragile, better to just eat the cost
	if (target.jumpsuit_style == PREF_SUIT)
		uniform = GLOB.colored_assistant.jumpsuits[index]
	else
		uniform = GLOB.colored_assistant.jumpskirts[index]

/datum/outfit/job/assistant/consistent
	name = "Assistant - Consistent"

/datum/outfit/job/assistant/consistent/give_jumpsuit(mob/living/carbon/human/target)
	uniform = /obj/item/clothing/under/color/grey

/datum/outfit/job/assistant/consistent/post_equip(mob/living/carbon/human/H, visualsOnly)
	..()

	// This outfit is used by the assets SS, which is ran before the atoms SS
	if (SSatoms.initialized == INITIALIZATION_INSSATOMS)
		H.w_uniform?.update_greyscale()
		H.update_worn_undersuit()
