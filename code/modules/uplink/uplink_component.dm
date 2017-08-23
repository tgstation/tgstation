/**
 * Uplinks
 *
 * All /obj/item(s) may have a /datum/component/uplink. Give the item one with `src.AddComponent(/datum/component/uplink)`. Then add 'uses'.
 * Use whatever conditionals you want to check that the user has an uplink, and then call Open() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is `enabled` and then Open() it.
**/

/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/lockable
	var/telecrystals
	var/selected_cat
	var/owner
	var/datum/game_mode/gamemode
	var/list/uplink_items
	var/hidden_crystals	//these crystals are hidden from telecrystals until the uplink is next locked
	var/datum/uplink_purchase_log/log

/datum/component/uplink/New(datum/p, _owner, _lockable = TRUE, _enabled = FALSE, datum/game_mode/_gamemode, starting_tc = 20)
	..()
	if(_owner)
		log = new(_owner, src)
	enabled = _enabled
	lockable = _lockable
	telecrystals = starting_tc
	set_gamemode(_gamemode)
	RegisterSignal(COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)

/datum/component/uplink/Destroy()
	var/datum/uplink_purchase_log/_log = log
	if(_log)
		_log.owning_uplink = null
		log = null
	return ..()

/datum/component/uplink/InheritComponent(datum/component/uplink/U)
	lockable |= U.lockable
	enabled |= U.enabled
	if(!gamemode)
		gamemode = U.gamemode
	telecrystals += U.telecrystals
	var/datum/uplink_purchase_log/_log = log
	var/other_log = U.log
	if(_log && other_log && _log.MergeWith(other_log))
		QDEL_NULL(U.log)

/datum/component/uplink/proc/set_gamemode(gamemode)
	src.gamemode = gamemode
	uplink_items = get_uplink_items(gamemode)

/datum/component/uplink/proc/LoadTC(mob/user, obj/item/stack/telecrystal/TC, silent = FALSE)
	if(!silent)
		to_chat(user, "<span class='notice'>You slot [TC] into [parent] and charge its internal uplink.</span>")
	var/amount = TC.amount
	telecrystals += amount
	TC.use(amount)

/datum/component/uplink/proc/OnAttackBy(obj/item/I, mob/user)
	var/obj/item/stack/telecrystal/TC = I
	if(istype(TC))
		LoadTC(user, TC)
		return TRUE

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
			to_chat(user, "<span class='notice'>[I] refunded.</span>")
			qdel(I)
			return TRUE

/datum/component/uplink/proc/MakePurchase(mob/user, datum/uplink_item/item)
	var/tc = telecrystals
	var/cost = item.cost
	if(cost < tc)
		return
	telecrystals = tc - cost
	SSblackbox.add_details("traitor_uplink_items_bought", "[item.name]|[cost]")
	var/atom/A = item.spawn_item(get_turf(parent), src, user)
	if(!A)
		return

	var/is_item
	var/datum/uplink_purchase_log/_log = log
	if(_log)
		if(owner && !item.purchase_log_vis)
			var/obj/item/storage/B = A
			is_item = istype(B)
			if(is_item)
				for(var/obj/item/I in B)
					_log.LogItem(I, cost)
			else
				_log.LogItem(A, cost)
		else
			_log.LogCost(cost)
		
	is_item = is_item || istype(A, /obj/item)

	var/mob/living/carbon/human/H = user
	if(is_item && istype(H))
		to_chat(H, "[A] materializes [H.put_in_hands(A) ? "into your hands!" : "onto the floor."]")

/datum/component/uplink/proc/Open(mob/user)
	enabled = TRUE
	if(user)
		ui_interact(user)

/datum/component/uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	enabled = TRUE
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "uplink", "syndicate uplink", 450, 750, master_ui, state)
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
	if(!enabled)
		return

	switch(action)
		if("buy")
			var/item = params["item"]

			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]

			if(item in buyable_items)
				MakePurchase(usr, buyable_items[item])
		if("lock")
			enabled = FALSE
			telecrystals += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
		if("select")
			selected_cat = params["category"]
	return TRUE
