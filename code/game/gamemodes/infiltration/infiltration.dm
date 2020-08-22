/datum/game_mode/traitor/infiltrator
	name = "infiltration"
	config_tag = "infiltration"
	report_type = "infiltration"
	antag_flag = ROLE_TRAITOR
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
	implants = list(/obj/item/implant/stealth, /obj/item/implant/adrenalin, \
	/obj/item/implant/freedom, /obj/item/implant/radio/syndicate, /obj/item/implant/explosive)

//Plasmaman (Spawned on top of previous outfits, not alone)

/datum/outfit/infiltrator_plasmaman
	name = "Infiltrator Plasma Kit"
	uniform = /obj/item/clothing/under/plasmaman
	gloves = /obj/item/clothing/gloves/color/plasmaman/black
	l_pocket = /obj/item/tank/internals/plasmaman/belt/full
	backpack_contents = list(/obj/item/clothing/head/helmet/space/plasmaman=1)

//Objective

/datum/objective/escape/escape_with_identity/infiltrator
	name = "escape with identity (as infiltrator)"

/datum/objective/escape/escape_with_identity/infiltrator/New()
	give_special_equipment(/obj/item/adv_mulligan)
	..()

//Latejoin

/datum/game_mode/traitor/infiltrator/add_latejoin_traitor(datum/mind/character) //Late joiners in Infiltration gamemode will become normal traitors.
	var/datum/antagonist/traitor/new_antag = new /datum/antagonist/traitor()
	character.add_antag_datum(new_antag)

//CentCom Report

/datum/game_mode/traitor/infiltrator/generate_report()
	return "Recent events have proved that Syndicate is staging covert operations in your sector. \
	While you still should expect any sort of traitorous operations from the inside, \
	There is a high possibility of any sort of Syndicate attack coming from the dark void of space."

//Additional Items used/added by gamemode

/obj/item/adv_mulligan
	name = "advanced mulligan"
	desc = "Toxin that permanently changes your DNA into the one of last injected person."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "dnainjector0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE
	var/mob/living/carbon/human/stored

/obj/item/adv_mulligan/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	return //Stealth

/obj/item/adv_mulligan/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(used)
		to_chat(user, "<span class='warning'>[src] has been already used, you can't activate it again!</span>")
		return
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			stored = H
			to_chat(user, "<span class='notice'>You stealthly stab [H.name] with [src].</span>")
			desc = "Toxin that permanently changes your DNA into the one of last injected person. It has DNA of <span class='blue'>[stored.dna.real_name]</span> inside."
			icon_state = "dnainjector"
		else
			if(stored)
				mutate(user)
			else
				to_chat(user, "<span class='warning'>You can't stab yourself with [src]!</span>")

/obj/item/adv_mulligan/attack_self(mob/living/carbon/user)
	mutate(user)

/obj/item/adv_mulligan/proc/mutate(mob/living/carbon/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] has been already used, you can't activate it again!</span>")
		return
	if(!used)
		if(stored)
			user.visible_message("<span class='warning'>[user.name] shivers in pain and soon transform into [stored.dna.real_name]!</span>", \
			"<span class='notice'>You inject yourself with [src] and suddenly become a copy of [stored.dna.real_name].</span>")

			user.real_name = stored.real_name
			stored.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			used = TRUE

			icon_state = "dnainjector0"
			desc = "Toxin that permanently changes your DNA into the one of last injected person. This one is used up."

		else
			to_chat(user, "<span class='warning'>[src] doesn't have any DNA loaded in it!</span>")

/obj/item/clothing/suit/space/eva/plasmaman/infiltrator
	desc = "A special syndicate version of plasma containment suit. Capable of everything it's smaller version can do and offers a good protection against hostile environment."
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 0.2
	armor = list("melee" = 20, "bullet" = 30, "laser" = 20,"energy" = 20, "bomb" = 30, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 80)
	cell = /obj/item/stock_parts/cell/hyper

/obj/item/storage/box/syndie_kit/plasmeme/ComponentInitialize()
	. = ..()
	desc = "Box with unique design allowing it to store any sort of lightweight EVA equipment."
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(/obj/item/clothing/suit/space, /obj/item/clothing/head/helmet/space, /obj/item/clothing/under/plasmaman))

/obj/item/storage/box/syndie_kit/plasmeme/PopulateContents()
	new /obj/item/clothing/under/plasmaman(src)
	new /obj/item/clothing/suit/space/eva/plasmaman/infiltrator(src)
	new /obj/item/clothing/head/helmet/space/plasmaman(src)

/obj/item/clothing/gloves/chameleon/combat
	name = "black gloves"
	desc = "These tactical gloves provide you with protection against electric shock and heat while also containing the chameleon technology."
	icon_state = "black"
	inhand_icon_state = "blackgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
