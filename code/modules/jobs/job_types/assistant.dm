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
	selection_color = "#dddddd"
	exp_granted_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/assistant
	plasmaman_outfit = /datum/outfit/plasmaman
	paycheck = PAYCHECK_LOWER // Get a job. Job reassignment changes your paycheck now. Get over it.

	liver_traits = list(TRAIT_GREYTIDE_METABOLISM)

	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT

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

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS
	rpg_title = "Lout"

/datum/outfit/job/assistant
	name = JOB_ASSISTANT
	jobtype = /datum/job/assistant
	id_trim = /datum/id_trim/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/target)
	..()
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
		H.update_inv_w_uniform()

/proc/get_configured_colored_assistant_type()
	return CONFIG_GET(flag/grey_assistants) ? /datum/colored_assistant/grey : /datum/colored_assistant/random

/// Defines a style of jumpsuit/jumpskirt for assistants.
/// Jumpsuit and jumpskirt lists should match in colors, as they are used interchangably.
/datum/colored_assistant
	var/list/jumpsuits
	var/list/jumpskirts

/datum/colored_assistant/grey
	jumpsuits = list(/obj/item/clothing/under/color/grey)
	jumpskirts = list(/obj/item/clothing/under/color/jumpskirt/grey)

/datum/colored_assistant/random
	jumpsuits = list(/obj/item/clothing/under/color/random)
	jumpskirts = list(/obj/item/clothing/under/color/jumpskirt/random)

/datum/colored_assistant/christmas
	jumpsuits = list(
		/obj/item/clothing/under/color/green,
		/obj/item/clothing/under/color/red,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/green,
		/obj/item/clothing/under/color/jumpskirt/red,
	)

/datum/colored_assistant/mcdonalds
	jumpsuits = list(
		/obj/item/clothing/under/color/yellow,
		/obj/item/clothing/under/color/red,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/yellow,
		/obj/item/clothing/under/color/jumpskirt/red,
	)

/datum/colored_assistant/halloween
	jumpsuits = list(
		/obj/item/clothing/under/color/orange,
		/obj/item/clothing/under/color/black,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/orange,
		/obj/item/clothing/under/color/jumpskirt/black,
	)

/datum/colored_assistant/ikea
	jumpsuits = list(
		/obj/item/clothing/under/color/yellow,
		/obj/item/clothing/under/color/blue,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/yellow,
		/obj/item/clothing/under/color/jumpskirt/blue,
	)

/datum/colored_assistant/mud
	jumpsuits = list(
		/obj/item/clothing/under/color/brown,
		/obj/item/clothing/under/color/lightbrown,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/brown,
		/obj/item/clothing/under/color/jumpskirt/lightbrown,
	)

/datum/colored_assistant/warm
	jumpsuits = list(
		/obj/item/clothing/under/color/red,
		/obj/item/clothing/under/color/pink,
		/obj/item/clothing/under/color/orange,
		/obj/item/clothing/under/color/yellow,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/red,
		/obj/item/clothing/under/color/jumpskirt/pink,
		/obj/item/clothing/under/color/jumpskirt/orange,
		/obj/item/clothing/under/color/jumpskirt/yellow,
	)

/datum/colored_assistant/cold
	jumpsuits = list(
		/obj/item/clothing/under/color/blue,
		/obj/item/clothing/under/color/darkblue,
		/obj/item/clothing/under/color/darkgreen,
		/obj/item/clothing/under/color/green,
		/obj/item/clothing/under/color/lightpurple,
		/obj/item/clothing/under/color/teal,
	)

	jumpskirts = list(
		/obj/item/clothing/under/color/jumpskirt/blue,
		/obj/item/clothing/under/color/jumpskirt/darkblue,
		/obj/item/clothing/under/color/jumpskirt/darkgreen,
		/obj/item/clothing/under/color/jumpskirt/green,
		/obj/item/clothing/under/color/jumpskirt/lightpurple,
		/obj/item/clothing/under/color/jumpskirt/teal,
	)

/// Will pick one color, and stick with it
/datum/colored_assistant/solid

/datum/colored_assistant/solid/New()
	var/obj/item/clothing/under/color/random_jumpsuit_type = get_random_jumpsuit()
	jumpsuits = list(random_jumpsuit_type)

	for (var/obj/item/clothing/under/color/jumpskirt/jumpskirt_type as anything in subtypesof(/obj/item/clothing/under/color/jumpskirt))
		if (initial(jumpskirt_type.greyscale_colors) == initial(random_jumpsuit_type.greyscale_colors))
			jumpskirts = list(jumpskirt_type)
			return

	// Couldn't find a matching jumpskirt, oh well
	jumpskirts = list(get_random_jumpskirt())
