var/list/world_uplinks = list()


/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".
 2. Code in the triggers. Use check_trigger for this; the var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.
 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
	Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/
/obj/item/device/uplink
	name = "syndicate uplink"
	desc = "There is something wrong if you're examining this."
	var/active = 0
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

/obj/item/device/uplink/attack_self(mob/user)
	trigger(user)

/obj/item/device/uplink/interact(mob/user)
	ui_interact(user)

/obj/item/device/uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "uplink", name, 400, 200, master_ui, state)
		ui.set_style("syndicate")
		ui.open()

/obj/item/device/uplink/get_ui_data(mob/user)
	var/list/data = list()
	data["uses"] = uses

	var/list/buyable = list()
	var/list/buyable_items = get_uplink_items(mode_override)
	var/list/category
	for(var/category_name in buyable_items)
		category = list()
		category["name"] = category_name
		var/i
		for(var/datum/uplink_item/item in buyable_items[category_name])
			category["items"] += list(list(
				"name" = item.name,
				"cost" = item.cost,
				"desc" = item.desc,
				"index" = ++i
			))
		buyable[++buyable.len] = category
	data["buyable"] = buyable
	return data

/obj/item/device/uplink/ui_act(action, params)
	if(!active)
		return

	switch(action)
		if("buy")
			var/category = params["category"]
			var/index = text2num(params["index"])

			var/list/buyable_items = get_uplink_items(mode_override)
			var/datum/uplink_item/I = buyable_items[category][index]
			I.buy(src, usr)
		if("lock")
			active = FALSE
			SStgui.close_uis(src)
	return 1


/obj/item/device/uplink/ui_host()
	return loc

// Directly trigger an uplink.
/obj/item/device/uplink/proc/trigger(mob/user)
	if(!active)
		active = TRUE
	interact(user)

// Helper to try and unlock/use an uplink.
/obj/item/device/uplink/proc/check_trigger(mob/user, value, target)
	if(value == target)
		trigger(user)
		return 1
	return 0

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

// Helper to open an uplink if present and active.
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	hidden_uplink = new(src)
	icon_state = "radio"

/obj/item/device/radio/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/multitool/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
