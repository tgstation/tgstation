//Tendril chest artifacts

/datum/export/lavaland/minor
	cost = 10000
	unit_name = "minor lava planet artifact"
	export_types = list(/obj/item/immortality_talisman,
						/obj/item/book_of_babel,
						/obj/item/gun/magic/hook,
						/obj/item/wisp_lantern,
						/obj/item/reagent_containers/glass/bottle/potion/flight,
						/obj/item/katana/cursed,
						/obj/item/clothing/glasses/godeye,
						/obj/item/melee/ghost_sword,
						/obj/item/clothing/suit/space/hardsuit/cult,
						/obj/item/voodoo,
						/obj/item/grenade/clusterbuster/inferno,
						/obj/item/clothing/neck/necklace/memento_mori,
						/obj/item/organ/heart/cursed/wizard)

/datum/export/lavaland/major
	cost = 20000
	unit_name = "lava planet artifact"
	export_types = list(/obj/item/ship_in_a_bottle,
						/obj/item/guardiancreator,
						/obj/item/rod_of_asclepius,
						/obj/item/clothing/suit/space/hardsuit/ert/paranormal,
						/obj/item/prisoncube)

//Megafauna loot

/datum/export/lavaland/megafauna
	cost = 40000
	unit_name = "major lava planet artifact"
	export_types = list(/obj/item/hierophant_club,
						/obj/item/staff/storm,
						/obj/item/lava_staff,
						/obj/item/dragons_blood,
						/obj/item/melee/transforming/cleaving_saw,
						/obj/item/organ/vocal_cords/colossus,
						/obj/machinery/anomalous_crystal,
						/obj/item/mayhem,
						/obj/item/blood_contract,
						/obj/item/gun/magic/staff/spellblade)

/datum/export/lavaland/megafauna/total_printout()
	. = ..()
	if(.)
		. += " On behalf of the Nanotrasen RnD division: Thank you for your hard work."

/datum/export/lavaland/megafauna/hev/total_printout()
	. = ..()
	if(.)
		. += " On behalf of the... hey, what the HECK is this?"

/datum/export/lavaland/megafauna/hev/suit
	cost = 30000
	unit_name = "H.E.C.K. suit"
	export_types = list(/obj/item/clothing/suit/space/hostile_environment)

/datum/export/lavaland/megafauna/hev/helmet
	cost = 10000
	unit_name = "H.E.C.K. helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/hostile_environment)
