GLOBAL_LIST(uplink_purchase_logs)

/**
 * Uplinks
 *
 * All /obj/item(s) may have a /datum/component/uplink. Give the item one with `src.AddComponent(/datum/component/uplink)`. Then add 'uses'.
 * Use whatever conditionals you want to check that the user has an uplink, and then call Open() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is `enabled` and then Open() it.
**/

/datum/uplink_purchase_log
	var/owner
	var/spent_telecrystals = 0
	var/list/purchase_log

/datum/uplink_purchase_log/New(_owner)
	owner = _owner
	LAZYINITLIST(uplink_purchase_logs)
	LAZYINITLIST(uplink_purchase_logs[_owner])
	GLOB.uplink_purchase_logs[_owner] += src
	purchase_log = list()

/datum/uplink_purchase_log/proc/MergeWith(datum/uplink_purchase_log/other)
	spent_telecrystals += other.spent_telecrystals
	//don't lose ordering info
	var/list/our_pl = purchase_log
	var/list/their_pl = other.purchase_log
	var/list/new_pl = purchase_log = list()
	while(our_pl.len && their_pl.len)
		var/t1 = our_pl[1]
		var/t2 = their_pl[1]
		var/time_to_add
		var/thing_to_add
		if(t1 == t2)
		else if(text2num(t1) < text2num(t2))
			time_to_add = t1
			thing_to_add = our_pl[t1]
		else
			time_to_add = t2
			thing_to_add = their_pl[t2]
		if(new_pl.len)
			var/last_time = text2num(new_pl[new_pl.len])
			if(last_time <= text2num(time_to_add))
				time_to_add = "[++last_time]"
		new_pl[time_to_add] = thing_to_add
	purchase_log += other.purchase_log

/datum/uplink_purchase_log/proc/LogItem(atom/A, cost)
	var/list/pl = purchase_log
	var/target_time = world.time
	while(TRUE)
		var/str_access = "[target_time]"
		if(!pl[str_access])
			pl[str_access] = "<big>[bicon(I)]</big>"
			break
		++target_time
	LogCost(cost)

/datum/uplink_purchase_log/proc/LogCost(cost)
	spent_telecrystals += cost

/datum/uplink_purchase_log/proc/GetFlatPurchaseLog()
	return purchase_log.Join("")

/datum/uplink_purchase_log/Destroy()
	var/_owner = owner
	var/list/our_list = GLOB.uplink_purchase_logs[_owner]
	our_list -= src
	if(!our_list.len)
		GLOB.uplink_purchase_logs -= _owner
	purchase_log.Cut()
	return ..()

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
		log = new(_owner)
	enabled = _enabled
	lockable = _lockable
	telecrystals = starting_tc
	set_gamemode(_gamemode)

/datum/component/uplink/InheritComponent(datum/component/uplink/U)
	lockable |= U.lockable
	enabled |= U.enabled
	if(!gamemode)
		gamemode = U.gamemode
	telecrystals += U.telecrystals
	var/datum/uplink_purchase_log/_log = log
	var/other_log = U.log
	if(_log && other_log)
		_log.MergeWith(other_log)
		QDEL_NULL(U.log)

/datum/component/uplink/set_gamemode(gamemode)
	src.gamemode = gamemode
	uplink_items = get_uplink_items(gamemode)

/datum/component/OnAttackBy(obj/item/I, mob/user)
	var/obj/item/stack/telecrystal/TC = I
	if(istype(TC))
		to_chat(user, "<span class='notice'>You slot [TC] into [parent] and charge its internal uplink.</span>")
		var/amount = TC.amount
		telecrystals += amount
		TC.use(amount)
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
	var/atom/A = new item.item(get_turf(parent), src)
	if(!A)
		return

	var/is_item
	if(owner && !item.purchase_log_vis)
		var/obj/item/weapon/storage/B = A
		is_item = istype(B)
		if(is_item)
			for(var/obj/item/I in B)
				log.LogItem(I, cost)
		else
			log.LogItem(A, cost)
	else
		log.LogCost(cost)
		
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
				MakePurchase(usr, buyable_items[item])
		if("lock")
			enabled = FALSE
			telecrystals += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
		if("select")
			selected_cat = params["category"]
	return TRUE

// A collection of pre-set uplinks, for admin spawns.
/obj/item/device/radio/uplink/Initialize(mapload, owner_key)
	. = ..()
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	AddComponent(/datum/component/uplink, owner_key, FALSE, TRUE)

/obj/item/device/radio/uplink/nuclear/Initialize()
	. = ..()
	GET_COMPONENT(uplink, /datum/component/uplink)
	uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/device/multitool/uplink/Initialize(mapload, owner_key)
	. = ..()
	AddComponent(/datum/component/uplink, owner_key, FALSE, TRUE)

/obj/item/weapon/pen/uplink/Initialize()
	. = ..()
	AddComponent(/datum/component/uplink)
	traitor_unlock_degrees = 360
