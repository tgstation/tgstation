GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))

/proc/get_uplink_items(uplink_flag, allow_sales = TRUE, allow_restricted = TRUE)
	var/list/filtered_uplink_items = list()
	var/list/sale_items = list()

	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/I = new path
		if(!I.item)
			continue
		if (!(I.purchasable_from & uplink_flag))
			continue
		if (I.restricted && !allow_restricted)
			continue

		if(!filtered_uplink_items[I.category])
			filtered_uplink_items[I.category] = list()
		filtered_uplink_items[I.category][I.name] = I
		if(I.limited_stock < 0 && !I.cant_discount && I.item && I.cost > 1)
			sale_items += I
	if(allow_sales)
		var/datum/team/nuclear/nuclear_team
		if (uplink_flag & UPLINK_NUKE_OPS) // uplink code kind of needs a redesign
			nuclear_team = locate() in GLOB.antagonist_teams // the team discounts could be in a GLOB with this design but it would make sense for them to be team specific...
		if (!nuclear_team)
			create_uplink_sales(3, "Discounted Gear", 1, sale_items, filtered_uplink_items)
		else
			if (!nuclear_team.team_discounts)
				// create 5 unlimited stock discounts
				create_uplink_sales(5, "Discounted Team Gear", -1, sale_items, filtered_uplink_items)
				// Create 10 limited stock discounts
				create_uplink_sales(10, "Limited Stock Team Gear", 1, sale_items, filtered_uplink_items)
				nuclear_team.team_discounts = list("Discounted Team Gear" = filtered_uplink_items["Discounted Team Gear"], "Limited Stock Team Gear" = filtered_uplink_items["Limited Stock Team Gear"])
			else
				for(var/cat in nuclear_team.team_discounts)
					for(var/item in nuclear_team.team_discounts[cat])
						var/datum/uplink_item/D = nuclear_team.team_discounts[cat][item]
						var/datum/uplink_item/O = filtered_uplink_items[initial(D.category)][initial(D.name)]
						O.refundable = FALSE

				filtered_uplink_items["Discounted Team Gear"] = nuclear_team.team_discounts["Discounted Team Gear"]
				filtered_uplink_items["Limited Stock Team Gear"] = nuclear_team.team_discounts["Limited Stock Team Gear"]


	return filtered_uplink_items

/proc/create_uplink_sales(num, category_name, limited_stock, sale_items, uplink_items)
	if (num <= 0)
		return

	if(!uplink_items[category_name])
		uplink_items[category_name] = list()

	for (var/i in 1 to num)
		var/datum/uplink_item/I = pick_n_take(sale_items)
		var/datum/uplink_item/A = new I.type
		var/discount = A.get_discount()
		var/list/disclaimer = list("Void where prohibited.", "Not recommended for children.", "Contains small parts.", "Check local laws for legality in region.", "Do not taunt.", "Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.", "Keep away from fire or flames.", "Product is provided \"as is\" without any implied or expressed warranties.", "As seen on TV.", "For recreational use only.", "Use only as directed.", "16% sales tax will be charged for orders originating within Space Nebraska.")
		A.limited_stock = limited_stock
		I.refundable = FALSE //THIS MAN USES ONE WEIRD TRICK TO GAIN FREE TC, CODERS HATES HIM!
		A.refundable = FALSE
		if(A.cost >= 20) //Tough love for nuke ops
			discount *= 0.5
		A.category = category_name
		A.cost = max(round(A.cost * discount),1)
		A.name += " ([round(((initial(A.cost)-A.cost)/initial(A.cost))*100)]% off!)"
		A.desc += " Normally costs [initial(A.cost)] TC. All sales final. [pick(disclaimer)]"
		A.item = I.item

		uplink_items[category_name][A.name] = A


/**
 * Uplink Items
 *
 * Items that can be spawned from an uplink. Can be limited by gamemode.
**/
/datum/uplink_item
	/// Name of the uplink item
	var/name = "item name"
	/// Category of the uplink
	var/datum/uplink_category/category
	/// Description of the uplink
	var/desc = "item description"
	/// Path to the item to spawn.
	var/item = null
	/// Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/refund_path = null
	/// Cost of the item.
	var/cost = 0
	/// Amount of TC to refund, in case there's a TC penalty for refunds.
	var/refund_amount = 0
	/// Whether this item is refundable or not.
	var/refundable = FALSE
	// Chance of being included in the surplus crate.
	var/surplus = 100
	/// Whether this can be discounted or not
	var/cant_discount = FALSE
	/// How many items of this stock can be purchased.
	var/limited_stock = -1 //Setting this above zero limits how many times this item can be bought by the same traitor in a round, -1 is unlimited
	/// A bitfield to represent what uplinks can purchase this item.
	/// See [`code/__DEFINES/uplink.dm`].
	var/purchasable_from = ALL
	/// If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/list/restricted_roles = list()
	/// The minimum amount of progression needed for this item to be added to uplinks.
	var/progression_minimum = 0
	/// Whether this purchase is visible in the purchase log.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	/// Whether this purchase is restricted or not (VR/Events related)
	var/restricted = FALSE
	/// Can this item be deconstructed to unlock certain techweb research nodes?
	var/illegal_tech = TRUE

/datum/uplink_category
	/// Name of the category
	var/name
	/// Weight of the category. Used to determine the positioning in the uplink. High weight = appears first
	var/weight = 0

/datum/uplink_item/proc/get_discount()
	return pick(4;0.75,2;0.5,1;0.25)

/datum/uplink_item/proc/purchase(mob/user, datum/component/uplink/U)
	var/atom/A = spawn_item(item, user, U)
	log_uplink("[key_name(user)] purchased [src] for [cost] telecrystals from [U.parent]'s uplink")
	if(purchase_log_vis && U.purchase_log)
		U.purchase_log.LogPurchase(A, src, cost)

/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	if(ishuman(user) && istype(A, /obj/item))
		var/mob/living/carbon/human/H = user
		if(H.put_in_hands(A))
			to_chat(H, span_boldnotice("[A] materializes into your hands!"))
			return A
	to_chat(user, span_boldnotice("[A] materializes onto the floor!"))
	return A

/datum/uplink_category/discounts
	name = "Discounts"
	weight = -1

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = /datum/uplink_category/discounts

// Special equipment (Dynamically fills in uplink component)
/datum/uplink_item/special_equipment
	category = "Objective-Specific Equipment"
	name = "Objective-Specific Equipment"
	desc = "Equipment necessary for accomplishing specific objectives. If you are seeing this, something has gone wrong."
	limited_stock = 1
	illegal_tech = FALSE

/datum/uplink_item/special_equipment/purchase(mob/user, datum/component/uplink/U)
	..()
	if(user?.mind?.failed_special_equipment)
		user.mind.failed_special_equipment -= item
