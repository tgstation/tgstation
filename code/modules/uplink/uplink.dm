GLOBAL_LIST_EMPTY(uplinks)

/**
 * Uplinks
 *
 * All /obj/item(s) have a /datum/component/uplink. Give the item one with 'new(src') (it must be in it's contents). Then add 'uses.'
 * Use whatever conditionals you want to check that the user has an uplink, and then call interact() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is 'active' and then interact() with it.
**/
/datum/component/uplink
	var/lockable
	var/telecrystals
	var/selected_cat
	var/owner	//the owner's key
	var/datum/game_mode/gamemode
	var/spent_telecrystals = 0
	var/purchase_log = ""
	var/list/uplink_items
	var/hidden_crystals

/datum/component/uplink/New(datum/p, _owner, starting_tc = 20, _lockable = TRUE, _enabled = FALSE, datum/game_mode/_gamemode)
	GLOB.uplinks += src
	..()
	owner = _owner
	enabled = _enabled
	lockable = _lockable
	telecrystals = starting_tc
	set_gamemode(_gamemode)

/datum/component/uplink/set_gamemode(gamemode)
	src.gamemode = gamemode
	uplink_items = get_uplink_items(gamemode)

/datum/component/uplink/Destroy()
	GLOB.uplinks -= src
	return ..()

/datum/component/OnAttackBy(obj/item/I, mob/user)
	var/static/list/uplink_items_subtypes = subtypesof(/datum/uplink_item)
	for(var/item in uplink_items_subtypes)
		var/datum/uplink_item/UI = item
		var/path = null
		if(initial(UI.refund_path))
			path = initial(UI.refund_path)
		else
			path = initial(UI.item)
		var/cost = 0
		if(initial(UI.refund_amount))
			cost = initial(UI.refund_amount)
		else
			cost = initial(UI.cost)
		var/refundable = initial(UI.refundable)
		if(I.type == path && refundable && I.check_uplink_validity())
			telecrystals += cost
			spent_telecrystals -= cost
			to_chat(user, "<span class='notice'>[I] refunded.</span>")
			qdel(I)
			return

/datum/component/uplink/proc/Open(mob/user)
	enabled = TRUE
	if(user)
		ui_interact(user)

/datum/component/uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	enabled = TRUE
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "uplink", name, 450, 750, master_ui, state)
		ui.set_autoupdate(FALSE) // This UI is only ever opened by one person, and never is updated outside of user input.
		ui.set_style("syndicate")
		ui.open()

/datum/component/ui_data(mob/user)
	if(!user.mind)
		return
	var/list/data = list()
	data["telecrystals"] = telecrystals
	data["lockable"] = lockable

	data["categories"] = list()
	for(var/category in uplink_items)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		if(category == selected_cat)
			for(var/item in uplink_items[category])
				var/datum/uplink_item/I = uplink_items[category][item]
				if(I.limited_stock == 0)
					continue
				if(I.restricted_roles.len)
					var/is_inaccessible = 1
					for(var/R in I.restricted_roles)
						if(R == user.mind.assigned_role)
							is_inaccessible = 0
					if(is_inaccessible)
						continue
				cat["items"] += list(list(
					"name" = I.name,
					"cost" = I.cost,
					"desc" = I.desc,
				))
		data["categories"] += list(cat)
	return data


/datum/component/ui_act(action, params)
	if(!enabled)
		return

	switch(action)
		if("buy")
			var/item = params["item"]

			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]

			if(item in buyable_items)
				var/datum/uplink_item/I = buyable_items[item]
				I.buy(usr, src)
				. = TRUE
		if("lock")
			enabled = FALSE
			telecrystals += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
		if("select")
			selected_cat = params["category"]
	return 1

// A collection of pre-set uplinks, for admin spawns.
/obj/item/device/radio/uplink/Initialize()
	. = ..()
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	
	hidden_uplink.lockable = FALSE

/obj/item/device/radio/uplink/nuclear/Initialize()
	. = ..()
	GET_COMPONENT(uplink, /datum/component/uplink)
	uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/device/multitool/uplink/Initialize()
	. = ..()
	AddComponent(/datum/component/uplink, null, 20, FALSE, TRUE)

/obj/item/weapon/pen/uplink/Initialize()
	. = ..()
	AddComponent(/datum/component/uplink)
	traitor_unlock_degrees = 360
