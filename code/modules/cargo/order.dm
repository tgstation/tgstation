/// The chance for a manifest or crate to be created with errors
#define MANIFEST_ERROR_CHANCE 5

// MANIFEST BITFLAGS
/// Determines if the station name will be incorrect on the manifest
#define MANIFEST_ERROR_NAME (1 << 0)
/// Determines if contents will be deleted from the manifest but still be present in the crate
#define MANIFEST_ERROR_CONTENTS (1 << 1)
/// Determines if contents will be deleted from the crate but still be present in the manifest
#define MANIFEST_ERROR_ITEM (1 << 2)

/obj/item/paper/fluff/jobs/cargo/manifest
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0

/obj/item/paper/fluff/jobs/cargo/manifest/Initialize(mapload, id, cost, manifest_can_fail = TRUE)
	. = ..()
	order_id = id
	order_cost = cost
	if(!manifest_can_fail)
		return

	if(prob(MANIFEST_ERROR_CHANCE) && (world.time-SSticker.round_start_time > STATION_RENAME_TIME_LIMIT)) //Too confusing if station name gets changed
		errors |= MANIFEST_ERROR_NAME
		investigate_log("Supply order #[order_id] generated a manifest with an incorrect station name.", INVESTIGATE_CARGO)
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_CONTENTS
		investigate_log("Supply order #[order_id] generated a manifest missing listed contents.", INVESTIGATE_CARGO)
	else if(prob(MANIFEST_ERROR_CHANCE)) //Content and item errors could remove the same items, so only one at a time
		errors |= MANIFEST_ERROR_ITEM
		investigate_log("Supply order #[order_id] generated with incorrect contents shipped.", INVESTIGATE_CARGO)

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_approved()
	return LAZYLEN(stamp_cache) && !is_denied()

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_denied()
	return LAZYLEN(stamp_cache) && ("stamp-deny" in stamp_cache)

/datum/supply_order
	var/id
	var/cost_type
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/discounted_pct
	///If set to FALSE, we won't charge when the cargo shuttle arrives with this.
	var/charge_on_purchase = TRUE
	///area this order wants to reach, if not null then it will come with the deliver_first component set to this area
	var/department_destination
	var/datum/supply_pack/pack
	var/datum/bank_account/paying_account
	var/obj/item/coupon/applied_coupon
	///Boolean on whether the manifest can fail or not.
	var/manifest_can_fail = TRUE
	///Boolean on whether the manifest can be cancelled through cargo consoles.
	var/can_be_cancelled = TRUE

/datum/supply_order/New(
	datum/supply_pack/pack,
	orderer,
	orderer_rank,
	orderer_ckey,
	reason,
	paying_account,
	department_destination,
	coupon,
	charge_on_purchase = TRUE,
	manifest_can_fail = TRUE,
	cost_type = "cr",
	can_be_cancelled = TRUE,
)
	id = SSshuttle.order_number++
	src.cost_type = cost_type
	src.pack = pack
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account
	src.department_destination = department_destination
	src.applied_coupon = coupon
	src.charge_on_purchase = charge_on_purchase
	src.manifest_can_fail = manifest_can_fail
	src.can_be_cancelled = can_be_cancelled

//returns the total cost of this order. Its not the total price paid by cargo but the total value of this order
/datum/supply_order/proc/get_final_cost()
	var/cost = pack.get_cost()
	if(applied_coupon) //apply discount price
		cost -= (cost * applied_coupon.discount_pct_off)
	if(!isnull(paying_account)) //privately purchased means 1.1x the cost
		cost *= 1.1
	return cost

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/paper/requisition_paper = new(T)

	requisition_paper.name = "requisition form - #[id] ([pack.name])"
	var/requisition_text = "<h2>[station_name()] Supply Requisition</h2>"
	requisition_text += "<hr/>"
	requisition_text += "Order #[id]<br/>"
	requisition_text+= "Time of Order: [station_time_timestamp()]<br/>"
	requisition_text += "Item: [pack.name]<br/>"
	requisition_text += "Access Restrictions: [SSid_access.get_access_desc(pack.access)]<br/>"
	requisition_text += "Requested by: [orderer]<br/>"
	if(paying_account)
		requisition_text += "Paid by: [paying_account.account_holder]<br/>"
	requisition_text += "Rank: [orderer_rank]<br/>"
	requisition_text += "Comment: [reason]<br/>"

	requisition_paper.add_raw_text(requisition_text)
	requisition_paper.update_appearance()
	return requisition_paper

/datum/supply_order/proc/generateManifest(obj/container, owner, packname, cost) //generates-the-manifests.
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest_paper = new(null, id, cost, manifest_can_fail)

	var/station_name = (manifest_paper.errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()

	manifest_paper.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"

	var/manifest_text = "<h2>[command_name()] Shipping Manifest</h2>"
	manifest_text += "<hr/>"
	if(owner && !(owner == "Cargo"))
		manifest_text += "Direct purchase from [owner]<br/>"
		manifest_paper.name += " - Purchased by [owner]"
	manifest_text += "Order[packname?"":"s"]: [id]<br/>"
	manifest_text += "Destination: [station_name]<br/>"
	if(packname)
		manifest_text += "Item: [packname]<br/>"
	manifest_text += "Contents: <br/>"
	manifest_text += "<ul>"
	var/container_contents = list() // Associative list with the format (item_name = nº of occurences, ...)
	for(var/atom/movable/AM in container.contents - manifest_paper)
		container_contents[AM.name]++
	if((manifest_paper.errors & MANIFEST_ERROR_CONTENTS) && container_contents)
		if(HAS_TRAIT(container, TRAIT_NO_MANIFEST_CONTENTS_ERROR))
			manifest_paper.errors &= ~MANIFEST_ERROR_CONTENTS
		else
			for(var/iteration in 1 to rand(1, round(container.contents.len * 0.5))) // Remove anywhere from one to half of the items
				var/missing_item = pick(container_contents)
				container_contents[missing_item]--
				if(container_contents[missing_item] == 0) // To avoid 0s and negative values on the manifest
					container_contents -= missing_item


	for(var/item in container_contents)
		manifest_text += "<li> [container_contents[item]] [item][container_contents[item] == 1 ? "" : "s"]</li>"
	manifest_text += "</ul>"
	manifest_text += "<h4>Stamp below to confirm receipt of goods:</h4>"

	manifest_paper.add_raw_text(manifest_text)

	if(manifest_paper.errors & MANIFEST_ERROR_ITEM)
		if(HAS_TRAIT(container, TRAIT_NO_MISSING_ITEM_ERROR))
			manifest_paper.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(container.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(container.contents))


	manifest_paper.update_appearance()
	manifest_paper.forceMove(container)

	if(istype(container, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = container
		C.manifest = manifest_paper
		C.update_appearance()
	else
		container.contents += manifest_paper

	return manifest_paper

/datum/supply_order/proc/generate(atom/A)
	var/account_holder
	if(paying_account)
		account_holder = paying_account.account_holder
	else
		account_holder = "Cargo"
	var/obj/structure/closet/crate/crate = pack.generate(A, paying_account)
	if(department_destination)
		crate.AddElement(/datum/element/deliver_first, department_destination, pack.cost)
	generateManifest(crate, account_holder, pack, pack.cost)
	return crate

/datum/supply_order/proc/generateCombo(miscbox, misc_own, misc_contents, misc_cost)
	for (var/I in misc_contents)
		new I(miscbox)
	generateManifest(miscbox, misc_own, "", misc_cost)
	return

/datum/supply_order/proc/append_order(list/new_contents, cost_increase)
	for(var/i as anything in new_contents)
		if(pack.contains[i])
			pack.contains[i] += new_contents[i]
		else
			pack.contains += i
			pack.contains[i] = new_contents[i]
	pack.cost += cost_increase

#undef MANIFEST_ERROR_CHANCE
#undef MANIFEST_ERROR_NAME
#undef MANIFEST_ERROR_CONTENTS
#undef MANIFEST_ERROR_ITEM
