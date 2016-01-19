var/list/world_uplinks = list()

/**
 * Uplinks
 *
 * All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with 'new(src') (it must be in it's contents). Then add 'uses.'
 * Use whatever conditionals you want to check that the user has an uplink, and then call interact() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is 'active' and then interact() with it.
**/
/obj/item/device/uplink
	name = "syndicate uplink"
	desc = "There is something wrong if you're examining this."
	var/active = FALSE
	var/lockable = TRUE
	var/uses = 20
	var/used_TC = 0
	var/uplink_owner = null
	var/purchase_log = ""

	var/mode_override = null

/obj/item/device/uplink/New()
	..()
	world_uplinks += src

/obj/item/device/uplink/Destroy()
	world_uplinks -= src
	return ..()

/obj/item/device/uplink/interact(mob/user)
	if(!active)
		active = TRUE
	ui_interact(user)

/obj/item/device/uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "uplink", name, 350, 750, master_ui, state)
		ui.set_style("syndicate")
		ui.open()

/obj/item/device/uplink/get_ui_data(mob/user)
	var/list/data = list()
	data["uses"] = uses
	data["lockable"] = lockable

	var/list/uplink_items = get_uplink_items(mode_override)
	data["buyable"] = list()
	for(var/category in uplink_items)
		var/list/cat = list(
			"name" = category,
			"items" = list(),
		)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			cat["items"] += list(list(
				"name" = I.name,
				"category" = I.category,
				"cost" = I.cost,
				"desc" = I.desc,
			))
		data["buyable"] += list(cat)
	return data

/obj/item/device/uplink/ui_act(action, params)
	if(!active)
		return

	switch(action)
		if("buy")
			var/list/uplink_items = get_uplink_items(mode_override)
			var/category = params["category"]
			var/item = params["item"]
			var/datum/uplink_item/I = uplink_items[category][item]
			if(I)
				I.buy(src, usr)
		if("lock")
			active = FALSE
			SStgui.close_uis(src)
	return 1


/obj/item/device/uplink/ui_host()
	return loc

// Refund certain items by hitting the uplink with it.
/obj/item/device/radio/uplink/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W))
		for(var/path in subtypesof(/datum/uplink_item))
			var/datum/uplink_item/D = path
			if(initial(D.item) == W.type && initial(D.refundable))
				hidden_uplink.uses += (D.cost)
				hidden_uplink.used_TC -= initial(D.cost)
				user << "<span class='notice'>[W] refunded.</span>"
				qdel(W)
				return

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	..()
	icon_state = "radio"
	hidden_uplink = new(src)
	hidden_uplink.lockable = FALSE

/obj/item/device/radio/uplink/interact(mob/user)
	hidden_uplink.interact(user)

/obj/item/device/multitool/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.lockable = FALSE

/obj/item/device/multitool/uplink/interact(mob/user)
	hidden_uplink.interact(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
