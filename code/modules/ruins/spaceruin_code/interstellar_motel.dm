/obj/effect/interstellar_sign
	name = "MOTEL INTER STELLAR"
	desc = "This is a barely functioning sign... You notice a pause between 'INTER' and 'STELLAR'. You're not sure if they are trying to evade the space copyright police or was it just a mistake."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "interstellar"
	//centers the image on the 'base' of the sign
	pixel_x = -32
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_ricochet = RICOCHET_SHINY & RICOCHET_HARD
	layer = ABOVE_ALL_MOB_LAYER

/turf/open/floor/plating/ashplanet/rocky/safe
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/turf/open/floor/plating/ashplanet/safe
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/obj/structure/holobubble/motel
	blocked_factions = list("interstellar_motel")
	alpha = 120

/area/ruin/space/has_grav/powered/interstellar_motel
	name = "Interstellar Motel"
	area_flags = NOTELEPORT | UNIQUE_AREA

/obj/effect/mob_spawn/human/interstellar_barman
	name = "Interstellar Bartender"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	short_desc = "You are a bartender at a forgotten galactic motel, your job is to entertain guests and maintain this outpost. You cannot leave."
	flavour_text = "Unfortunately this galactic motel has been forgotten and overshadowed by far bigger and more luxorious establishments."
	important_info = "You cannot leave! You must maintain this defunct motel and entertain guests"
	outfit = /datum/outfit/galactic_bartender
	assignedrole = "Interstellar Barman"

/obj/effect/mob_spawn/human/interstellar_barman/special(mob/M)
	. = .()
	M.faction += "interstellar_motel"

/datum/outfit/galactic_bartender
	name = "Galactic Bartender"
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	backpack_contents = list(/obj/item/storage/box/beanbag=1)
	shoes = /obj/item/clothing/shoes/laceup
	id_trim = /datum/id_trim/interstellar_bartender
	id = /obj/item/card/id/advanced
	box = /obj/item/storage/box/survival
	back = /obj/item/storage/backpack

/datum/venue/bar/space
	req_access = ACCESS_SPACE_MOTEL

/obj/machinery/restaurant_portal/spacebar
	linked_venue = /datum/venue/bar/space

/obj/item/holosign_creator/robot_seat/spacebar
	name = "bar seating indicator placer"
	holosign_type = /obj/structure/holosign/robot_seat/spacebar

/obj/structure/holosign/robot_seat/spacebar
	name = "bar seating"
	linked_venue = /datum/venue/bar/space
