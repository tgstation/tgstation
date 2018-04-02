var/list/vip_items = list()

/world/proc/load_vip_items()
	vip_items = list()
	if (!fexists("config/vip_items.txt"))
		message_admins("No vip items file found.")
		return
	var/list/list_raw = file2list("config/vip_items.txt", "\n")
	for (var/raw_item in list_raw)
		var/list/parsed = splittext(raw_item, "=")
		if (length(parsed) != 2)
			return
		if (!istext(parsed[1]) || !istext(parsed[2]) || !ispath(text2path(parsed[2])))
			return
		vip_items[ckey(parsed[1])] = text2path(parsed[2])


/client/proc/check_vip_items()
	set name = "Check VIP Items"
	set desc = "Check VIP Item list"
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/dat = "<b>VIP Items List</b> Ckey - Path<hr>"
	for (var/ckey in vip_items)
		dat += "[ckey] = [vip_items[ckey]]<br>"

	usr << browse(dat, "window=vipitems")

/mob/living/carbon/human/proc/give_vip_item()
	spawn(0)
		if (!(ckey in vip_items) || (!ispath(vip_items[ckey])))
			return

		var/ask_time = world.time
		if (alert(src, "Do you wish to receive your VIP item?","", "Yes", "No") == "No")
			return
		if (world.time > ask_time + 150)
			to_chat(src, "<b>You waited too long to answer.</b>")
			return
		if (!back || !istype(back,/obj/item/storage/backpack))
			to_chat(src, "<b>Your VIP Item could not be delivered to you because you had no backpack.</b>")
			return

		var/path = vip_items[ckey]
		if (!path || !ispath(path) || !ishuman(src))
			return

		var/item = new path
		var/list/slots = list ("backpack" = slot_in_backpack)
		equip_in_one_of_slots(item, slots)
		to_chat(src, "<b>You have received your VIP Item: [item]!</b>")
