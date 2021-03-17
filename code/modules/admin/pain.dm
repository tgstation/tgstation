/client/proc/triggtest()
	set category = "Debug.TRIGG IS AT IT AGAIN"
	set name = "AAAAAA"

	if(!check_rights(R_DEBUG))
		return
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)

/datum/outfit_manager
	var/client/user
	var/category = "headwear"
	var/page = 2
	var/static/list/objects

/datum/outfit_manager/New(_user)
	user = CLIENT_FROM_VAR(_user)
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

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigPain", "Outfit Manager")
		ui.open()
		ui.set_autoupdate(FALSE)


/datum/outfit_manager/proc/entry(obj/item/I)
	return list("name" = initial(I.name), "path" = initial(I), "icon" = icon2base64(initial(I.icon)))

/datum/outfit_manager/proc/get_entries(list/L, amount=9)
	. = list()
	var/start = page*amount + 1 //lists in byond start at 1 .-.
	if(start>L.len)
		return
	var/end = min(start + amount-1, L.len)
	for(var/i in start to end)
		. += list(entry(L[i]))



/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	data["categories"] = assoc_list_strip_value(objects)
	data["category"] = category
	data["page"] = page


	data["objects"] = get_entries(objects[category])

	return data
