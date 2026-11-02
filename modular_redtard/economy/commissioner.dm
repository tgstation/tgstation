/**
 * COMMISSIONER (Ratwood code/modules/roguetown/roguemachine/escrow.dm): the guild's commission board with an escrow box. A
 * customer feeds it coins, picks works from its catalog into a manifest (at most a few items) and posts it as an order; the
 * coin is held in escrow. A guildsman claims the order, delivers the finished works into the machine (worn-out ones are
 * refused) and collects the pay once all is delivered, or settles for part of it at a loss; the customer then collects the
 * works. Orders nobody claims expire back into the customer's deposit; a claim left too long reopens. Unlocked with a guild key,
 * the guild sets its margins, the price of each material and which materials it works.
 *
 * The smithy's board lists every anvil work and the engineers' crafts, the tailors' board the sewing and leatherwork. A work's
 * price is its materials at their trade price (Ratwood material_baseline_prices: the material's trade good, else the price the
 * pricing engine derived for it, else its own worth) plus the guild's margins.
 */

#define COMMISSION_OPEN "open"
#define COMMISSION_CLAIMED "claimed"
#define COMMISSION_COMPLETE "complete"

/// An order posted at a COMMISSIONER (Ratwood /datum/escrow_order).
/datum/rogue_commission
	var/commissioner_name
	var/datum/weakref/commissioner_ref
	var/smith_name
	/// Recipe -> how many.
	var/list/recipe_quantities = list()
	/// Mammons held in escrow for it.
	var/deposited = 0
	var/list/obj/item/delivered_items = list()
	/// Result path -> pieces delivered.
	var/list/delivered_counts = list()
	var/status = COMMISSION_OPEN
	var/day_posted = 0
	var/day_claimed = 0
	var/note = ""
	/// Result path -> pieces wanted, worked out once.
	var/list/required

/datum/rogue_commission/Destroy()
	delivered_items.Cut()
	return ..()

/// What the order wants delivered: result path -> pieces (Ratwood required_result_counts()).
/datum/rogue_commission/proc/required_results(obj/structure/roguemachine/escrow/board)
	if(required)
		return required
	required = list()
	for(var/datum/recipe as anything in recipe_quantities)
		var/list/made = board.recipe_result(recipe)
		if(made)
			required[made[1]] += recipe_quantities[recipe] * made[2]
	return required

/datum/rogue_commission/proc/label(obj/structure/roguemachine/escrow/board)
	var/list/parts = list()
	for(var/datum/recipe as anything in recipe_quantities)
		parts += "[board.recipe_name(recipe)] x[recipe_quantities[recipe]]"
	return jointext(parts, ", ")

/// Pieces delivered and pieces wanted, counted to the order.
/datum/rogue_commission/proc/progress(obj/structure/roguemachine/escrow/board)
	var/list/needed = required_results(board)
	var/done = 0
	var/wanted = 0
	for(var/path in needed)
		done += min(delivered_counts[path], needed[path])
		wanted += needed[path]
	return list(done, wanted)

/obj/structure/roguemachine/escrow
	/// Locked it takes orders; unlocked the guild adjusts it.
	var/locked = TRUE
	/// Lockids of the guild's keys (Ratwood keycontrol).
	var/list/keycontrol = list("crafterguild", "craftermaster")
	var/percent_margin
	var/flat_margin
	var/item_cap
	/// Material path -> price of a piece, for the materials the catalog uses.
	var/list/material_prices
	/// Materials the guild does not work (Ratwood disabled_materials).
	var/list/disabled_materials = list()
	var/list/default_disabled_materials = list(
		/obj/item/ingot/blacksteel,
		/obj/item/ingot/silver,
		/obj/item/ingot/silverblessed,
		/obj/item/ingot/silverblessed/bullion,
		/obj/item/ingot/steelholy,
		/obj/item/ingot/gilbranze,
	)
	/// Materials and kinds of materials never worked here.
	var/list/excluded_materials = list(/obj/item/ingot/aaslag)
	var/list/excluded_material_parents = list()
	/// Materials listed first among the guild's prices.
	var/list/priority_material_types = list(
		/obj/item/ingot,
		/obj/item/natural/hide,
		/obj/item/grown/log,
		/obj/item/natural/wood,
		/obj/item/roguegear,
	)
	/// Anvil works are on the catalog.
	var/takes_anvil_work = TRUE
	/// Categories of crafting recipes on the catalog.
	var/list/craft_categories = list("Engineering", "Blacksmithing")
	/// Every recipe on the catalog.
	var/list/datum/catalog = list()
	var/catalog_built = FALSE
	var/list/datum/rogue_commission/orders = list()
	/// Real name -> recipe -> how many: what each customer is putting together.
	var/list/manifests = list()
	/// Real name -> mammons the customer fed in and has not spent.
	var/list/deposits = list()
	/// Mammons held for posted orders.
	var/escrow = 0

/obj/structure/roguemachine/escrow/Initialize(mapload)
	. = ..()
	percent_margin = rogue_value("machines_commission_margin_percent")
	flat_margin = rogue_value("machines_commission_margin_flat")
	item_cap = rogue_value("machines_commission_item_cap")
	disabled_materials = default_disabled_materials.Copy()
	material_prices = list()
	update_appearance()

/obj/structure/roguemachine/escrow/Destroy()
	var/turf/spot = drop_location()
	for(var/obj/item/held in src)
		held.forceMove(spot)
	var/spill = escrow
	for(var/customer in deposits)
		spill += deposits[customer]
	if(spill > 0)
		rogue_coins_out(spill, null, null, src)
	QDEL_LIST(orders)
	manifests.Cut()
	deposits.Cut()
	catalog.Cut()
	return ..()

/obj/structure/roguemachine/escrow/examine(mob/user)
	. = ..()
	. += span_info("Any commissioner may build a manifest of works and deposit coin into the machine. Submitting the manifest posts an order with the coin held in escrow.")
	. += span_info("A guildsman can claim an open order, deliver the finished items back into the machine, and collect the escrowed pay once every item has been delivered. An order that has been claimed cannot be cancelled by the commissioner.")
	. += span_info("Unlocked with the guild's key, material prices and margins can be adjusted.")

/obj/structure/roguemachine/escrow/update_icon_state()
	icon_state = locked ? "streetvendor1" : "streetvendor0"
	return ..()

/obj/structure/roguemachine/escrow/update_overlays()
	. = ..()
	set_light(length(orders) ? 1 : 0, 1, "#f1c94b")

// Materials and the catalog.

/// A material's price: its trade good's, else its own worth, with the commission markup (Ratwood material_baseline_prices).
/obj/structure/roguemachine/escrow/proc/base_material_price(path)
	if(!ispath(path, /obj/item))
		return 0
	for(var/id in SSrogue_trade.goods)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		if(good.item_type == path)
			return max(1, round(good.base_price * good.global_price_mod * rogue_value("machines_commission_markup")))
	var/list/derived = GLOB.rogue_derived_prices
	var/obj/item/material = path
	var/worth = derived[path] || initial(material.sellprice)
	return worth > 0 ? max(1, round(worth * rogue_value("machines_commission_markup"))) : 0

/obj/structure/roguemachine/escrow/proc/excluded(path)
	if(!path)
		return FALSE
	if(path in excluded_materials)
		return TRUE
	for(var/parent in excluded_material_parents)
		if(ispath(path, parent))
			return TRUE
	return FALSE

/// The price of a piece of a material, learning it the first time; 0 for materials nobody prices.
/obj/structure/roguemachine/escrow/proc/material_price(path)
	if(!(path in material_prices))
		material_prices[path] = base_material_price(path)
	return material_prices[path]

/// Material path -> pieces, for one work of a recipe (Ratwood recipe_material_tally()).
/obj/structure/roguemachine/escrow/proc/recipe_tally(datum/recipe)
	var/list/tally = list()
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/anvil_work = recipe
		if(anvil_work.req_bar)
			tally[anvil_work.req_bar] += 1
		for(var/path in anvil_work.additional_items)
			tally[path] += 1
	else if(istype(recipe, /datum/crafting_recipe))
		var/datum/crafting_recipe/craft = recipe
		for(var/path in craft.reqs)
			tally[path] += craft.reqs[path]
	return tally

/// list(result path, pieces made) of a recipe, or null.
/obj/structure/roguemachine/escrow/proc/recipe_result(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/anvil_work = recipe
		return anvil_work.created_item ? list(anvil_work.created_item, max(1, anvil_work.createditem_num)) : null
	var/datum/crafting_recipe/craft = recipe
	var/made = craft.result
	if(islist(made))
		var/list/results = made
		made = length(results) ? results[1] : null
	return made ? list(made, 1) : null

/obj/structure/roguemachine/escrow/proc/recipe_name(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/anvil_work = recipe
		return anvil_work.name
	var/datum/crafting_recipe/craft = recipe
	return craft.name

/obj/structure/roguemachine/escrow/proc/recipe_category(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/anvil_work = recipe
		return anvil_work.display_category || "Smithing (Misc)"
	var/datum/crafting_recipe/craft = recipe
	return craft.category || "Other"

/// The material most of the work is made of (Ratwood recipe_primary_ingot()).
/obj/structure/roguemachine/escrow/proc/recipe_primary(datum/recipe)
	if(istype(recipe, /datum/anvil_recipe))
		var/datum/anvil_recipe/anvil_work = recipe
		return anvil_work.req_bar
	var/list/tally = recipe_tally(recipe)
	var/best
	for(var/path in tally)
		if(!best || tally[path] > tally[best])
			best = path
	return best

/// Materials at the guild's prices and its margins (Ratwood recipe_price()).
/obj/structure/roguemachine/escrow/proc/recipe_price(datum/recipe)
	var/list/tally = recipe_tally(recipe)
	var/materials = 0
	for(var/path in tally)
		materials += material_price(path) * tally[path]
	return round(materials * (1 + percent_margin / 100)) + flat_margin

/// The recipe can go on this board: its result is an item, its materials priced, worked and allowed here.
/obj/structure/roguemachine/escrow/proc/catalog_worthy(datum/recipe)
	var/list/made = recipe_result(recipe)
	if(!made || !ispath(made[1], /obj/item))
		return FALSE
	var/list/tally = recipe_tally(recipe)
	if(!length(tally))
		return FALSE
	for(var/path in tally)
		if(excluded(path) || (path in disabled_materials) || material_price(path) <= 0)
			return FALSE
	return TRUE

/// The catalog is listed the first time someone reads it, once the trade goods that price it are known.
/obj/structure/roguemachine/escrow/proc/ensure_catalog()
	if(!catalog_built)
		rebuild_catalog()

/// Lists the works the guild takes now (Ratwood rebuild_catalog()).
/obj/structure/roguemachine/escrow/proc/rebuild_catalog()
	catalog_built = TRUE
	catalog = list()
	if(takes_anvil_work)
		for(var/datum/anvil_recipe/anvil_work as anything in GLOB.rogue_anvil_recipes)
			if(anvil_work.req_bar && catalog_worthy(anvil_work))
				catalog += anvil_work
	for(var/datum/crafting_recipe/roguetown/craft in GLOB.crafting_recipes)
		if((craft.category in craft_categories) && catalog_worthy(craft))
			catalog += craft
	update_static_data_for_all_viewers()

/obj/structure/roguemachine/escrow/proc/materials_in_use()
	. = list()
	for(var/datum/recipe as anything in catalog)
		for(var/path in recipe_tally(recipe))
			.[path] = TRUE
	for(var/path in disabled_materials)
		if(!excluded(path))
			.[path] = TRUE

// Hands, keys and coins.

/obj/structure/roguemachine/escrow/proc/is_guild_member(mob/user)
	if(!ishuman(user))
		return FALSE
	for(var/lockid in keycontrol)
		if(rockhill_find_key(user, lockid))
			return TRUE
	return FALSE

/obj/structure/roguemachine/escrow/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		for(var/lockid in keycontrol)
			if(rockhill_key_fits(tool, lockid))
				toggle_lock()
				return ITEM_INTERACT_SUCCESS
		to_chat(user, span_warning("Wrong key."))
		return ITEM_INTERACT_BLOCKING
	if(!locked || !ishuman(user))
		return NONE
	if(istype(tool, /obj/item/roguecoin))
		if(!rogue_coin_accepted(tool))
			return ITEM_INTERACT_BLOCKING
		deposits[user.real_name] += tool.get_real_price()
		qdel(tool)
		playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS
	deliver(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/roguemachine/escrow/proc/toggle_lock()
	locked = !locked
	playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
	update_appearance()
	SStgui.update_uis(src)

/// A guildsman hands in a finished work for the order they claimed (Ratwood try_smith_deliver()).
/obj/structure/roguemachine/escrow/proc/deliver(obj/item/work, mob/living/user)
	for(var/datum/rogue_commission/order as anything in orders)
		if(order.status != COMMISSION_CLAIMED || order.smith_name != user.real_name)
			continue
		var/list/needed = order.required_results(src)
		if(!needed[work.type] || order.delivered_counts[work.type] >= needed[work.type])
			continue
		if(work.max_integrity > 0 && work.get_integrity() < work.max_integrity * rogue_value("machines_commission_durability_floor"))
			to_chat(user, span_warning("[src] refuses [work] - the work is too damaged to deliver. Mend it first."))
			return
		if(!user.transferItemToLoc(work, src))
			return
		order.delivered_counts[work.type] += 1
		order.delivered_items += work
		playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
		to_chat(user, span_notice("[src] accepts [work]."))
		SStgui.update_uis(src)
		return
	to_chat(user, span_warning("[src] has no order waiting for [work]."))

// Orders.

/obj/structure/roguemachine/escrow/proc/notify(datum/rogue_commission/order, message)
	var/mob/customer = order.commissioner_ref?.resolve()
	if(customer)
		to_chat(customer, span_notice("<b>[message]</b>"))

/// Orders unclaimed too long go back to the deposit, claims left too long reopen (Ratwood prune_expired_orders()).
/obj/structure/roguemachine/escrow/proc/prune_expired()
	for(var/datum/rogue_commission/order as anything in orders.Copy())
		if(order.status == COMMISSION_OPEN && ROGUE_TREASURY_DAY - order.day_posted >= rogue_value("machines_commission_open_days"))
			notify(order, "Your unclaimed commission at [src] has expired. [order.deposited]m has been returned to your deposit.")
			refund_to_deposit(order)
			drop_order(order)
		else if(order.status == COMMISSION_CLAIMED && ROGUE_TREASURY_DAY - order.day_claimed >= rogue_value("machines_commission_claim_days"))
			reopen(order)
			notify(order, "The claim on your commission at [src] has expired; the order is open again for new smiths.")

/obj/structure/roguemachine/escrow/proc/refund_to_deposit(datum/rogue_commission/order)
	escrow -= order.deposited
	if(order.deposited > 0)
		deposits[order.commissioner_name] += order.deposited
	order.deposited = 0

/obj/structure/roguemachine/escrow/proc/return_works(datum/rogue_commission/order)
	var/turf/spot = drop_location()
	for(var/obj/item/work as anything in order.delivered_items)
		if(work.loc == src)
			work.forceMove(spot)
	order.delivered_items.Cut()
	order.delivered_counts.Cut()

/obj/structure/roguemachine/escrow/proc/reopen(datum/rogue_commission/order)
	return_works(order)
	order.status = COMMISSION_OPEN
	order.smith_name = null
	order.day_claimed = 0

/obj/structure/roguemachine/escrow/proc/drop_order(datum/rogue_commission/order)
	orders -= order
	qdel(order)
	update_appearance()

/obj/structure/roguemachine/escrow/proc/manifest_count(customer)
	. = 0
	var/list/cart = manifests[customer]
	for(var/datum/recipe as anything in cart)
		. += cart[recipe]

/obj/structure/roguemachine/escrow/proc/manifest_total(customer)
	. = 0
	var/list/cart = manifests[customer]
	for(var/datum/recipe as anything in cart)
		. += recipe_price(recipe) * cart[recipe]

/obj/structure/roguemachine/escrow/proc/has_active_order(customer)
	for(var/datum/rogue_commission/order as anything in orders)
		if(order.commissioner_name == customer && order.status != COMMISSION_COMPLETE)
			return TRUE
	return FALSE

/// Posts the customer's manifest as an order paid from their deposit (Ratwood submit_manifest()).
/obj/structure/roguemachine/escrow/proc/submit_manifest(mob/living/user, note)
	var/customer = user.real_name
	var/list/cart = manifests[customer]
	if(!length(cart))
		return
	if(has_active_order(customer))
		to_chat(user, span_warning("You already have an active commission here - finish or cancel it before posting another."))
		return
	if(manifest_count(customer) > item_cap)
		to_chat(user, span_warning("This commission asks for more than [item_cap] item\s - trim the manifest or raise the cap."))
		return
	var/total = manifest_total(customer)
	if(deposits[customer] < total)
		to_chat(user, span_warning("Not enough deposited. Need [total]m, have [deposits[customer] || 0]m."))
		return
	var/datum/rogue_commission/order = new
	order.commissioner_name = customer
	order.commissioner_ref = WEAKREF(user)
	order.day_posted = ROGUE_TREASURY_DAY
	order.note = copytext_char(sanitize(note), 1, 200)
	order.recipe_quantities = cart.Copy()
	order.deposited = total
	orders += order
	escrow += total
	deposits[customer] -= total
	manifests -= customer
	playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
	to_chat(user, span_notice("Your commission has been posted."))
	update_appearance()

/// A guildsman's pay for the delivered part of a claimed order, less the haircut; the rest goes back to the customer (Ratwood settle_partial_order()).
/obj/structure/roguemachine/escrow/proc/settle_partial(datum/rogue_commission/order, mob/living/user)
	var/list/counts = order.progress(src)
	if(counts[1] <= 0)
		to_chat(user, span_warning("Nothing has been delivered yet. Release the claim instead."))
		return
	if(counts[1] >= counts[2])
		complete(order, user)
		return
	var/pay = round(order.deposited * counts[1] / counts[2] * (100 - rogue_value("machines_commission_partial_cut")) / 100)
	var/refund = order.deposited - pay
	return_works(order)
	escrow -= order.deposited
	order.deposited = 0
	if(pay > 0)
		rogue_coins_out(pay, user, null, src)
	if(refund > 0)
		deposits[order.commissioner_name] += refund
	to_chat(user, span_notice("Settled partial commission: you collect [pay]m. [refund]m has been returned to [order.commissioner_name]'s deposit."))
	notify(order, "Your commission at [src] was partially fulfilled ([counts[1]]/[counts[2]]). The works were left at the machine; [refund]m has been returned to your deposit.")
	drop_order(order)

/// All delivered: the guildsman is paid, the works wait for the customer (Ratwood complete_order()).
/obj/structure/roguemachine/escrow/proc/complete(datum/rogue_commission/order, mob/living/user)
	var/list/counts = order.progress(src)
	if(counts[1] < counts[2] || !counts[2])
		to_chat(user, span_warning("The order is not yet complete."))
		return
	order.status = COMMISSION_COMPLETE
	escrow -= order.deposited
	rogue_coins_out(order.deposited, user, null, src)
	order.deposited = 0
	notify(order, "Your commission at [src] is ready for collection: [order.label(src)].")
	update_appearance()

/obj/structure/roguemachine/escrow/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	return ..()

/obj/structure/roguemachine/escrow/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		ui = new(user, src, "RogueCommissioner", name)
		ui.open()

/obj/structure/roguemachine/escrow/proc/material_rows(datum/recipe)
	. = list()
	var/list/tally = recipe_tally(recipe)
	for(var/path in tally)
		var/obj/item/material = path
		. += list(list("name" = initial(material.name), "qty" = tally[path]))

/obj/structure/roguemachine/escrow/ui_static_data(mob/user)
	ensure_catalog()
	var/list/data = list()
	var/list/entries = list()
	for(var/datum/recipe as anything in catalog)
		var/obj/item/primary = recipe_primary(recipe)
		entries += list(list(
			"ref" = REF(recipe),
			"name" = recipe_name(recipe),
			"category" = recipe_category(recipe),
			"price" = recipe_price(recipe),
			"material" = primary ? initial(primary.name) : "",
			"materials" = material_rows(recipe),
		))
	data["catalog"] = entries
	data["percent_margin"] = percent_margin
	data["flat_margin"] = flat_margin
	data["item_cap"] = item_cap
	var/list/rows = list()
	for(var/path in materials_in_use())
		var/obj/item/material = path
		var/priority = FALSE
		for(var/parent in priority_material_types)
			if(ispath(path, parent))
				priority = TRUE
				break
		rows += list(list(
			"path" = "[path]",
			"name" = initial(material.name),
			"price" = material_price(path),
			"priority" = priority,
			"enabled" = !(path in disabled_materials),
		))
	data["materials"] = rows
	return data

/obj/structure/roguemachine/escrow/ui_data(mob/user)
	prune_expired()
	var/list/data = list()
	var/customer = user.real_name
	data["locked"] = locked
	data["is_guild"] = is_guild_member(user)
	data["escrow"] = escrow
	data["my_deposit"] = deposits[customer] || 0
	data["has_active_order"] = has_active_order(customer)
	var/list/cart_rows = list()
	var/list/cart = manifests[customer]
	for(var/datum/recipe as anything in cart)
		cart_rows += list(list(
			"ref" = REF(recipe),
			"name" = recipe_name(recipe),
			"qty" = cart[recipe],
			"unit_price" = recipe_price(recipe),
		))
	data["manifest"] = cart_rows
	data["manifest_total"] = manifest_total(customer)
	data["manifest_items"] = manifest_count(customer)
	var/list/order_rows = list()
	for(var/datum/rogue_commission/order as anything in orders)
		var/list/counts = order.progress(src)
		var/list/lines = list()
		for(var/datum/recipe as anything in order.recipe_quantities)
			lines += list(list("name" = recipe_name(recipe), "qty" = order.recipe_quantities[recipe]))
		var/days_left = 0
		if(order.status == COMMISSION_OPEN)
			days_left = max(0, rogue_value("machines_commission_open_days") - (ROGUE_TREASURY_DAY - order.day_posted))
		else if(order.status == COMMISSION_CLAIMED)
			days_left = max(0, rogue_value("machines_commission_claim_days") - (ROGUE_TREASURY_DAY - order.day_claimed))
		order_rows += list(list(
			"ref" = REF(order),
			"commissioner" = order.commissioner_name,
			"smith" = order.smith_name || "",
			"deposited" = order.deposited,
			"status" = order.status,
			"lines" = lines,
			"done" = counts[1],
			"needed" = counts[2],
			"is_commissioner" = order.commissioner_name == customer,
			"is_smith" = order.smith_name == customer,
			"days_left" = days_left,
			"note" = order.note,
		))
	data["orders"] = order_rows
	return data

/obj/structure/roguemachine/escrow/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(!ishuman(user))
		return TRUE
	var/customer = user.real_name
	if(is_guild_member(user) && guild_act(action, params, user))
		return TRUE
	if(!locked)
		to_chat(user, span_warning("[src] is open for guild adjustments - turn the key to close it before posting or claiming work."))
		return TRUE
	var/datum/rogue_commission/order = locate(params["ref"]) in orders
	switch(action)
		if("manifest_add")
			ensure_catalog()
			var/datum/recipe = locate(params["ref"]) in catalog
			if(recipe)
				LAZYINITLIST(manifests[customer])
				var/list/cart = manifests[customer]
				cart[recipe] = min(cart[recipe] + 1, item_cap)
		if("manifest_remove")
			var/list/cart = manifests[customer]
			var/datum/recipe = cart ? (locate(params["ref"]) in cart) : null
			if(recipe)
				cart[recipe] -= 1
				if(cart[recipe] <= 0)
					cart -= recipe
		if("submit")
			submit_manifest(user, params["note"])
		if("refund")
			if(deposits[customer] > 0)
				rogue_coins_out(deposits[customer], user, null, src)
				deposits -= customer
		if("cancel")
			if(order?.status == COMMISSION_OPEN && order.commissioner_name == customer)
				escrow -= order.deposited
				rogue_coins_out(order.deposited, user, null, src)
				order.deposited = 0
				drop_order(order)
		if("claim")
			if(order?.status != COMMISSION_OPEN)
				return TRUE
			if(!is_guild_member(user))
				to_chat(user, span_warning("Only a member of the guild may claim a commission."))
				return TRUE
			order.status = COMMISSION_CLAIMED
			order.smith_name = customer
			order.day_claimed = ROGUE_TREASURY_DAY
			to_chat(user, span_notice("You claim [order.commissioner_name]'s commission."))
			notify(order, "[customer] has claimed your commission at [src].")
		if("release")
			if(order?.status == COMMISSION_CLAIMED && (order.smith_name == customer || is_guild_member(user)))
				reopen(order)
				if(order.smith_name != customer)
					notify(order, "The guildmaster has released the stalled claim on your commission at [src].")
		if("complete")
			if(order?.status == COMMISSION_CLAIMED && order.smith_name == customer)
				complete(order, user)
		if("settle_partial")
			if(order?.status == COMMISSION_CLAIMED && order.smith_name == customer)
				settle_partial(order, user)
		if("collect")
			if(order?.status == COMMISSION_COMPLETE && order.commissioner_name == customer)
				return_works(order)
				drop_order(order)
		if("reject")
			if(!order || order.status == COMMISSION_COMPLETE)
				return TRUE
			if(order.status == COMMISSION_CLAIMED ? (order.smith_name != customer && !is_guild_member(user)) : !is_guild_member(user))
				return TRUE
			var/reason = copytext_char(sanitize(params["reason"]), 1, 200)
			var/refunded = order.deposited
			return_works(order)
			refund_to_deposit(order)
			say("[customer] rejects [order.commissioner_name]'s commission ([order.label(src)])[reason ? ": \"[reason]\"" : ""].")
			notify(order, "[customer] has rejected your commission at [src]. [refunded]m has been returned to your deposit.[reason ? " Reason: \"[reason]\"" : ""]")
			drop_order(order)
	playsound(src, ROGUE_SOUND_BEEP, 50, FALSE, -1)
	return TRUE

/// The guild's adjustments while unlocked (Ratwood guild branch of ui_act()). Returns TRUE when the action was the guild's.
/obj/structure/roguemachine/escrow/proc/guild_act(action, list/params, mob/living/user)
	var/number = text2num(params["value"])
	switch(action)
		if("toggle_lock")
			toggle_lock()
			return TRUE
		if("set_percent_margin")
			if(!locked && isnum(number))
				percent_margin = clamp(round(number), 0, 500)
				update_static_data_for_all_viewers()
			return TRUE
		if("set_flat_margin")
			if(!locked && isnum(number))
				flat_margin = clamp(round(number), 0, ROGUE_TRANSFER_MAX)
				update_static_data_for_all_viewers()
			return TRUE
		if("set_item_cap")
			if(!locked && isnum(number))
				item_cap = clamp(round(number), 1, 10)
				update_static_data_for_all_viewers()
			return TRUE
		if("set_material_price")
			var/path = text2path(params["path"])
			if(!locked && path && (path in material_prices) && isnum(number))
				material_prices[path] = clamp(round(number), 0, ROGUE_TRANSFER_MAX)
				rebuild_catalog()
			return TRUE
		if("toggle_material")
			var/path = text2path(params["path"])
			if(!locked && path && (path in material_prices) && !excluded(path))
				if(path in disabled_materials)
					disabled_materials -= path
				else
					disabled_materials += path
				rebuild_catalog()
			return TRUE
	return FALSE

/// The weavers' and tailors' board: sewing and leatherwork, no metal (Ratwood escrow/tailor).
/obj/structure/roguemachine/escrow/tailor
	keycontrol = list("tailor", "crafterguild", "craftermaster")
	takes_anvil_work = FALSE
	craft_categories = list("Sewing", "Skincrafting")
	default_disabled_materials = list()
	excluded_material_parents = list(/obj/item/ingot, /obj/item/roguegear)
	priority_material_types = list(
		/obj/item/natural/hide,
		/obj/item/natural/silk,
		/obj/item/natural/cloth,
		/obj/item/natural/fibers,
		/obj/item/natural/fur,
	)

/obj/structure/roguemachine/escrow/tailor/examine(mob/user)
	. = ..()
	. += span_info("This commissioner accepts tailoring and garment work only.")

#undef COMMISSION_OPEN
#undef COMMISSION_CLAIMED
#undef COMMISSION_COMPLETE
