///This proc is used to save photos, papers and cash stored inside a bottle when tossed into the ocean.
/datum/controller/subsystem/persistence/proc/save_message_bottle(obj/item/message, bottle_type = /obj/item/reagent_containers/cup/glass/bottle)
	if(isnull(message_bottles_database))
		message_bottles_database = new("data/message_bottles.json")

	var/list/data = list()
	data["bottle_type"] = text2path(bottle_type)
	if(istype(message, /obj/item/paper))
		var/obj/item/paper/paper = message
		if(!length(paper.raw_text_inputs) && !length(paper.raw_stamp_data) && !length(paper.raw_field_input_data))
			return
		data["paper"] = paper.convert_to_data()
	else if(istype(message, /obj/item/photo))
		var/obj/item/photo/photo = message
		if(!photo.picture?.id)
			return
		data["photo_id"] = photo.picture.id
	else if(istype(message, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/cash = message
		data["cash"] = text2path(cash.type)
		data["amount"] = cash.amount
	message_bottles_index++
	message_bottles_database.set_key("message-[GLOB.round_id]-[message_bottles_index]", data)

/datum/controller/subsystem/persistence/proc/load_message_bottle(atom/loc)
	if(isnull(message_bottles_database))
		message_bottles_database = new("data/message_bottles.json")

	var/list/data = message_bottles_database.pick_and_take_key()
	if(!data)
		var/obj/item/reagent_containers/cup/glass/bottle/bottle = new(loc)
		return bottle

	var/bottle_type = text2path(data["bottle_type"]) || /obj/item/reagent_containers/cup/glass/bottle
	var/obj/item/reagent_containers/cup/glass/bottle/bottle = new bottle_type(loc)
	bottle.reagents.remove_all(bottle.reagents.maximum_volume)
	if(data["photo_id"])
		var/obj/item/photo/old/photo = load_photo_from_disk(data["photo_id"], bottle)
		bottle.message_in_a_bottle = photo
	else if(data["cash"])
		var/cash_type = text2path(data["cash"]) || /obj/item/stack/spacecash/c10
		var/obj/item/stack/spacecash/cash = new cash_type(bottle, data["amount"])
		bottle.message_in_a_bottle = cash
	else if(data["paper"])
		var/obj/item/paper/paper = new(bottle)
		paper.write_from_data(data["paper"])
		bottle.message_in_a_bottle = paper

	bottle.update_icon(UPDATE_OVERLAYS)

/datum/controller/subsystem/persistence/proc/save_queued_message_bottles()
	for(var/item in queued_message_bottles)
		save_message_bottle(item)
	queued_message_bottles = null
