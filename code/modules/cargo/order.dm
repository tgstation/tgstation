/// The chance for a manifest to create errors 
#define MANIFEST_ERROR_CHANCE 5

// Manifest bitflags 
/// Determines if a manifest will generate the incorrect station name on the paper
#define MANIFEST_ERROR_NAME (1 << 0)
/// Determines if a manifest will incorrectly list the items in the crate
#define MANIFEST_ERROR_CONTENTS (1 << 1)
/// Determines if contents will be deleted from a crate but still be present on the manifest 
#define MANIFEST_ERROR_ITEM (1 << 2)

/obj/item/paper/fluff/jobs/cargo/manifest
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0

/obj/item/paper/fluff/jobs/cargo/manifest/New(atom/A, id, cost)
	..()
	order_id = id
	order_cost = cost

	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_NAME
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_CONTENTS
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_ITEM

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_approved()
	return stamped?.len && !is_denied()

/obj/item/paper/fluff/jobs/cargo/manifest/proc/is_denied()
	return stamped && ("stamp-deny" in stamped)

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/discounted_pct
	///area this order wants to reach, if not null then it will come with the deliver_first component set to this area
	var/department_destination
	var/datum/supply_pack/pack
	var/datum/bank_account/paying_account
	var/obj/item/coupon/applied_coupon

/datum/supply_order/New(datum/supply_pack/pack, orderer, orderer_rank, orderer_ckey, reason, paying_account, department_destination, coupon)
	id = SSshuttle.ordernum++
	src.pack = pack
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account
	src.department_destination = department_destination
	src.applied_coupon = coupon

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/paper/P = new(T)

	P.name = "requisition form - #[id] ([pack.name])"
	P.info += "<h2>[station_name()] Supply Requisition</h2>"
	P.info += "<hr/>"
	P.info += "Order #[id]<br/>"
	P.info += "Time of Order: [station_time_timestamp()]<br/>"
	P.info += "Item: [pack.name]<br/>"
	P.info += "Access Restrictions: [SSid_access.get_access_desc(pack.access)]<br/>"
	P.info += "Requested by: [orderer]<br/>"
	if(paying_account)
		P.info += "Paid by: [paying_account.account_holder]<br/>"
	P.info += "Rank: [orderer_rank]<br/>"
	P.info += "Comment: [reason]<br/>"

	P.update_appearance()
	return P

/datum/supply_order/proc/generateManifest(obj/container, owner, packname, cost) //generates-the-manifests.
	var/obj/item/paper/fluff/jobs/cargo/manifest/P = new(container, id, cost)

	var/station_name = (P.errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()

	P.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"
	P.info += "<h2>[command_name()] Shipping Manifest</h2>"
	P.info += "<hr/>"
	if(owner && !(owner == "Cargo"))
		P.info += "Direct purchase from [owner]<br/>"
		P.name += " - Purchased by [owner]"
	P.info += "Order[packname?"":"s"]: [id]<br/>"
	P.info += "Destination: [station_name]<br/>"
	if(packname)
		P.info += "Item: [packname]<br/>"
	P.info += "Contents: <br/>"
	P.info += "<ul>"
	for(var/atom/movable/AM in container.contents - P)
		if((P.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				P.info += "<li>[AM.name]</li>"
			else
				continue
		P.info += "<li>[AM.name]</li>"
	P.info += "</ul>"
	P.info += "<h4>Stamp below to confirm receipt of goods:</h4>"

	if(P.errors & MANIFEST_ERROR_ITEM)
		if(istype(container, /obj/structure/closet/crate/secure) || istype(container, /obj/structure/closet/crate/large))
			P.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(container.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(container.contents))

	P.update_appearance()
	P.forceMove(container)

	if(istype(container, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = container
		C.manifest = P
		C.update_appearance()
	else
		container.contents += P

	return P

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

#undef MANIFEST_ERROR_CHANCE
#undef MANIFEST_ERROR_NAME
#undef MANIFEST_ERROR_CONTENTS
#undef MANIFEST_ERROR_ITEM
