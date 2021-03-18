/client/proc/triggtest()
	set category = "Debug.TRIGG IS AT IT AGAIN"
	set name = "AAAAAA"

	if(!check_rights(R_DEBUG))
		return
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)

/datum/outfit_manager
	var/client/user

	var/datum/outfit/drip = /datum/outfit/job/miner/equipped/hardsuit
	var/static/list/objects

/datum/outfit_manager/New(_user)
	user = CLIENT_FROM_VAR(_user)
	/*
	if(!objects)
		objects = list()
		objects["uniforms"] = typesof(/obj/item/clothing/under)
		objects["suits"] = typesof(/obj/item/clothing/suit)
		objects["gloves"] = typesof(/obj/item/clothing/gloves)
		objects["shoes"] = typesof(/obj/item/clothing/shoes)
		objects["headwear"] = typesof(/obj/item/clothing/head)
		objects["glasses"] = typesof(/obj/item/clothing/glasses)
		objects["masks"] = typesof(/obj/item/clothing/mask)
		objects["ids"] = typesof(/obj/item/card/id)
	*/

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigPain", "Outfit-O-Tron 9000")
		ui.open()
		ui.set_autoupdate(FALSE)


/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	var/list/outfit_slots = list()
	outfit_slots["head"] = drip.head
	outfit_slots["glasses"] = drip.glasses
	outfit_slots["ears"] = drip.ears

	outfit_slots["neck"] = drip.neck
	outfit_slots["mask"] = drip.mask

	outfit_slots["uniform"] = drip.uniform
	outfit_slots["suit"] = drip.suit
	outfit_slots["gloves"] = drip.gloves

	outfit_slots["suit_store"] = drip.suit_store
	outfit_slots["belt"] = drip.belt
	outfit_slots["id"] = drip.id

	outfit_slots["l_hand"] = drip.l_hand
	outfit_slots["back"] = drip.back
	outfit_slots["r_hand"] = drip.r_hand

	outfit_slots["l_pocket"] = drip.l_pocket
	outfit_slots["shoes"] = drip.shoes
	outfit_slots["r_pocket"] = drip.r_pocket

	data["OutfitSlots"] = outfit_slots
	return data
