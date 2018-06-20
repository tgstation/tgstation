GLOBAL_LIST_EMPTY(uplinks)

/**
 * Uplinks
 *
 * All /obj/item(s) have a hidden_uplink var. By default it's null. Give the item one with 'new(src') (it must be in it's contents). Then add 'uses.'
 * Use whatever conditionals you want to check that the user has an uplink, and then call interact() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is 'active' and then interact() with it.
**/
/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/name = "syndicate uplink"
	var/active = FALSE
	var/lockable = TRUE
	var/locked = TRUE
	var/allow_restricted = TRUE
	var/telecrystals
	var/selected_cat
	var/owner = null
	var/datum/game_mode/gamemode
	var/datum/uplink_purchase_log/purchase_log
	var/list/uplink_items
	var/hidden_crystals = 0

/datum/component/uplink/Initialize(_owner, _lockable = TRUE, _enabled = FALSE, datum/game_mode/_gamemode, starting_tc = 20)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	GLOB.uplinks += src
	uplink_items = get_uplink_items(gamemode, TRUE, allow_restricted)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)
	RegisterSignal(COMSIG_ITEM_ATTACK_SELF, .proc/interact)
	owner = _owner
	if(owner)
		LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
		else
			purchase_log = new(owner, src)
	lockable = _lockable
	active = _enabled
	gamemode = _gamemode
	telecrystals = starting_tc
	if(!lockable)
		active = TRUE
		locked = FALSE

/datum/component/uplink/InheritComponent(datum/component/uplink/U)
	lockable |= U.lockable
	active |= U.active
	if(!gamemode)
		gamemode = U.gamemode
	telecrystals += U.telecrystals
	if(purchase_log && U.purchase_log)
		purchase_log.MergeWithAndDel(U.purchase_log)

/datum/component/uplink/Destroy()
	GLOB.uplinks -= src
	gamemode = null
	return ..()

/datum/component/uplink/proc/LoadTC(mob/user, obj/item/stack/telecrystal/TC, silent = FALSE)
	if(!silent)
		to_chat(user, "<span class='notice'>You slot [TC] into [parent] and charge its internal uplink.</span>")
	var/amt = TC.amount
	telecrystals += amt
	TC.use(amt)

/datum/component/uplink/proc/set_gamemode(_gamemode)
	gamemode = _gamemode
	uplink_items = get_uplink_items(gamemode, TRUE, allow_restricted)

/datum/component/uplink/proc/OnAttackBy(obj/item/I, mob/user)
	if(!active)
		return	//no hitting everyone/everything just to try to slot tcs in!
	if(istype(I, /obj/item/stack/telecrystal))
		LoadTC(user, I)
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/UI = uplink_items[category][item]
			var/path = UI.refund_path || UI.item
			var/cost = UI.refund_amount || UI.cost
			if(I.type == path && UI.refundable && I.check_uplink_validity())
				telecrystals += cost
				purchase_log.total_spent -= cost
				to_chat(user, "<span class='notice'>[I] refunded.</span>")
				qdel(I)
				return

/datum/component/uplink/proc/interact(mob/user)
	if(locked)
		return
	active = TRUE
	if(user)
		ui_interact(user)
	// an unlocked uplink blocks also opening the PDA or headset menu
	return COMPONENT_NO_INTERACT

/datum/component/uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	active = TRUE
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "uplink", name, 450, 750, master_ui, state)
		ui.set_autoupdate(FALSE) // This UI is only ever opened by one person, and never is updated outside of user input.
		ui.set_style("syndicate")
		ui.open()

/datum/component/uplink/ui_data(mob/user)
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

/datum/component/uplink/ui_act(action, params)
	if(!active)
		return

	switch(action)
		if("buy")
			var/item = params["item"]

			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]

			if(item in buyable_items)
				var/datum/uplink_item/I = buyable_items[item]
				MakePurchase(usr, I)
				. = TRUE
		if("lock")
			active = FALSE
			locked = TRUE
			telecrystals += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
		if("select")
			selected_cat = params["category"]
	return TRUE

/datum/component/uplink/proc/MakePurchase(mob/user, datum/uplink_item/U)
	if(!istype(U))
		return
	if (!user || user.incapacitated())
		return

	if(telecrystals < U.cost || U.limited_stock == 0)
		return
	telecrystals -= U.cost

	U.purchase(user, src)

	if(U.limited_stock > 0)
		U.limited_stock -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(U.name)]", "[U.cost]"))
	return TRUE

