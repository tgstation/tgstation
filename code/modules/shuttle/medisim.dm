///These are for the medisim shuttle

/obj/machinery/capture_the_flag/medisim
	game_area = /area/shuttle/escape/simulation

/obj/machinery/capture_the_flag/medisim/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/human_knight = ..()
	human_knight.remove_all_languages(LANGUAGE_CTF)
	human_knight.grant_language(language = /datum/language/oldworld, understood = TRUE, spoken = TRUE, source = LANGUAGE_CTF)
	randomize_human(human_knight)
	human_knight.dna.add_mutation(MEDIEVAL, MUT_OTHER)
	var/oldname = name
	var/title
	switch (human_knight.gender)
		if (MALE)
			title = pick(list("Sir", "Lord"))
		if (FEMALE)
			title = pick(list("Dame", "Lady"))
		else
			title = "Noble"
	human_knight.name = "[title] [oldname]"

/obj/machinery/capture_the_flag/medisim/red
	ctf_gear = /datum/outfit/medisimred

/obj/machinery/capture_the_flag/medisim/blue
	ctf_gear = /datum/outfit/medisimblue

/obj/item/ctf/red/medisim
	name = "Redfield Castle Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_nuke"
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/obj/item/ctf/blue/medisim
	name = "Bluesworth Hold Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_slime"
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/datum/outfit/medisimred
	name = "Redfield Castle Knight"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/plate/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	gloves = /obj/item/clothing/gloves/plate/red
	head = /obj/item/clothing/head/helmet/knight/red
	r_hand = /obj/item/claymore

/datum/outfit/medisimblue
	name = "Bluesworth Hold Knight"

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/plate/blue
	suit = /obj/item/clothing/suit/armor/riot/knight/blue
	gloves = /obj/item/clothing/gloves/plate/blue
	head = /obj/item/clothing/head/helmet/knight/blue
	r_hand = /obj/item/claymore

