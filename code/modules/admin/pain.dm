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

/datum/outfit_manager/New(_user)
	user = CLIENT_FROM_VAR(_user)
	drip = new drip

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigPain", "Outfit-O-Tron 9000")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/outfit_manager/proc/entry(data)
	if(ispath(data, /obj/item))
		var/obj/item/item = data
		return list(
			"path" = item,
			"name" = initial(item.name),
			"sprite" = icon2base64(icon(initial(item.icon), initial(item.icon_state))) //at this point initializing the item is probably faster tbh
			)

	return data

/datum/outfit_manager/proc/serialize_outfit()
	var/list/outfit_slots = drip.get_json_data()
	. = list()
	for(var/key in outfit_slots)
		var/val = outfit_slots[key]
		. += list("[key]" = entry(val))

/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	data["OutfitSlots"] = serialize_outfit()
	return data
