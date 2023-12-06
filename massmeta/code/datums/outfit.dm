/datum/outfit
	var/toggle_helmet = TRUE

/datum/outfit/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()

/datum/outfit/get_json_data()
	. = ..()
	.["toggle_helmet"] = toggle_helmet

/datum/outfit/copy_from(datum/outfit/target)
	. = ..()
	toggle_helmet = target.toggle_helmet

/datum/outfit/load_from(list/outfit_data)
	. = ..()
	toggle_helmet = outfit_data["toggle_helmet"]
