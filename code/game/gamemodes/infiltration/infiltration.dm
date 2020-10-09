/datum/game_mode/traitor/infiltrator
	name = "infiltration"
	config_tag = "infiltration"
	report_type = "infiltration"
	antag_flag = ROLE_INFILTRATOR
	false_report_weight = 10
	enemy_minimum_age = 14 //It's a bit harder to start from space, you know? Don't want newbies dying in spess because of this.
	antag_datum = /datum/antagonist/traitor/infiltrator
	traitor_name = "Syndicate Infiltrator"

	announce_span = "danger"
	announce_text = "There are Syndicate agents about to infiltrate the station!\n\
	<span class='danger'>Operatives</span>: Accomplish your objectives while staying undiscovered.\n\
	<span class='notice'>Crew</span>: Do not let the operatives succeed!"

/datum/game_mode/traitor/infiltrator/pre_setup()
	var/num_traitors = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_traitors = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = antag_pick(antag_candidates)
		pre_traitors += traitor
		traitor.special_role = traitor_name
		traitor.assigned_role = traitor_name
		log_game("[key_name(traitor)] has been selected as a [traitor_name]")
		antag_candidates.Remove(traitor)

	var/enough_tators = !traitors_required || pre_traitors.len > 0

	if(!enough_tators)
		setup_error = "Not enough [traitor_name] candidates"
		return FALSE
	else
		for(var/antag in pre_traitors)
			GLOB.pre_setup_antags += antag
		return TRUE

/datum/game_mode/traitor/infiltrator/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/infiltrator/new_antag = new antag_datum()
		traitor.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= traitor
	..()

// Outfits

/datum/outfit/infiltrator
	name = "Infiltrator Starting Kit"
	uniform = /obj/item/clothing/under/chameleon
	shoes = /obj/item/clothing/shoes/chameleon
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset/syndicate
	mask = /obj/item/clothing/mask/gas/syndicate
	id = /obj/item/card/id/syndicate
	belt = /obj/item/pda/chameleon
	l_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_LPOCKET
	r_pocket = /obj/item/grenade/c4
	suit = /obj/item/clothing/suit/space/syndicate/black
	head = /obj/item/clothing/head/helmet/space/syndicate/black
	backpack_contents = list(/obj/item/storage/box/survival=1,\
	/obj/item/tank/jetpack/oxygen/harness=1)

/datum/outfit/infiltrator/cybersun
	name = "Cybersun Infiltrator Kit"
	suit = /obj/item/clothing/suit/space/syndicate/black/blue
	head = /obj/item/clothing/head/helmet/space/syndicate/black/blue

/datum/outfit/infiltrator/gorlex
	name = "Gorlex Infiltrator Kit"
	suit = /obj/item/clothing/suit/space/syndicate/black/red
	head = /obj/item/clothing/head/helmet/space/syndicate/black/red

/datum/outfit/infiltrator/tiger
	name = "Gorlex Infiltrator Kit"
	suit = /obj/item/clothing/suit/space/syndicate/black/orange
	head = /obj/item/clothing/head/helmet/space/syndicate/black/orange
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/grenade/c4/x4

/datum/outfit/infiltrator/cybersun/mi13
	name = "MI13 Infiltrator Kit"
	gloves = /obj/item/clothing/gloves/chameleon/combat
	ears = /obj/item/radio/headset/chameleon
	mask = /obj/item/clothing/mask/chameleon
	implants = list(/obj/item/implant/adrenalin, /obj/item/implant/freedom, /obj/item/implant/explosive)

//Latejoin

/datum/game_mode/traitor/infiltrator/add_latejoin_traitor(datum/mind/character) //Late joiners in Infiltration gamemode will become normal traitors.
	var/datum/antagonist/traitor/new_antag = new /datum/antagonist/traitor()
	character.add_antag_datum(new_antag)

//CentCom Report

/datum/game_mode/traitor/infiltrator/generate_report()
	return "Recent events have proved that Syndicate is staging covert operations in your sector. \
	While you still should expect any sort of traitorous operations from the inside, \
	beware the possibility of enemy operatives infiltrating your station from the dark void of space \
	to seize chaos and destruction."
