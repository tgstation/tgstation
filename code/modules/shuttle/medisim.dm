///These are for the medisim shuttle

/obj/machinery/capture_the_flag/medisim
	game_area = /area/shuttle/escape

/obj/machinery/capture_the_flag/medisim/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/M = ..()
	M.remove_all_languages(LANGUAGE_CTF)
	M.grant_language(/datum/language/monkey, TRUE, TRUE, LANGUAGE_CTF)

//maybe add something here about ending the other CTF game/not preventing that from happening

//late initialize for hooking up the computers on the shuttle

/obj/machinery/capture_the_flag/medisim/reset_the_arena()
	return //so we don't delete every object on the shuttle. downsides = that simulation room is gonna get gross pretty quick

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
	movement_type = FLYING //there are chasms!

/obj/item/ctf/blue/medisim
	name = "Bluesworth Hold Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_slime"
	game_area = /area/shuttle/escape
	movement_type = FLYING //there are chasms!

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

/turf/closed/indestructible/binary
	name = "tear in the fabric of reality"
	icon = 'icons/turf/floors.dmi'
	icon_state = "binary"
	opacity = FALSE
