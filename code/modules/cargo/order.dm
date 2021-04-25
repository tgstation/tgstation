
///not signed, doesn't necessarily mean it needs one or not.
#define SIGNATURE_NOT_FILLED 0
///signed by someone else. whoops!
#define SIGNATURE_INCORRECT 1
///signed by person whose signature is needed.
#define SIGNATURE_CORRECT 2

/obj/item/paper/fluff/jobs/cargo/manifest
	var/datum/supply_order/order
	var/order_cost = 0
	var/order_id = 0
	var/errors = 0
	var/signature_ckey_required
	var/signature_status = SIGNATURE_NOT_FILLED

/obj/item/paper/fluff/jobs/cargo/manifest/field_filled(with_what, by_whom)
	if(!signature_ckey_required || signature_status != SIGNATURE_NOT_FILLED)
		return
	if(signature_ckey_required == by_whom)
		signature_fulfilled = SIGNATURE_CORRECT
	else
		signature_fulfilled = SIGNATURE_INCORRECT

/obj/item/paper/fluff/jobs/cargo/manifest/examine(mob/user)
	. = ..()
	if(signature_ckey_required && signature_status == SIGNATURE_NOT_FILLED)
		. += "<span class='notice'>Getting the signature of whomever ordered this will get you a higher grade from Centcom.</span>"

/obj/item/paper/fluff/jobs/cargo/manifest/New(atom/A, order, id, cost)
	..()
	src.order = order
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
	var/datum/supply_pack/pack
	var/datum/bank_account/paying_account
	var/obj/item/coupon/applied_coupon

/datum/supply_order/New(datum/supply_pack/pack, orderer, orderer_rank, orderer_ckey, reason, paying_account, coupon)
	id = SSshuttle.ordernum++
	src.pack = pack
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account
	src.applied_coupon = coupon

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/paper/requisition = new(T)

	requisition.name = "requisition form - #[id] ([pack.name])"
	requisition.info += "<h2>[station_name()] Supply Requisition</h2>"
	requisition.info += "<hr/>"
	requisition.info += "Order #[id]<br/>"
	requisition.info += "Time of Order: [station_time_timestamp()]<br/>"
	requisition.info += "Item: [pack.name]<br/>"
	requisition.info += "Access Restrictions: [SSid_access.get_access_desc(pack.access)]<br/>"
	requisition.info += "Requested by: [orderer]<br/>"
	if(paying_account)
		requisition.info += "Paid by: [paying_account.account_holder]<br/>"
	requisition.info += "Rank: [orderer_rank]<br/>"
	requisition.info += "Comment: [reason]<br/>"

	requisition.update_appearance()
	return requisition

/**
 * generates-the-manifests.
 *
 * Arguments:
 * * container: crate the manifest should be pinned to
 * * owner: orderer, "Cargo" unless requested or self purchased
 * * packname: name of the pack ordered, exists if the order is singular
 * * signature_requirement: ckey of owner, if the manifest should require signing.
 */
/datum/supply_order/proc/generateManifest(obj/container, owner, packname, signature_requirement)
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest = new(container, src id, 0)

	var/station_name = (manifest.errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()

	manifest.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"
	manifest.info += "<h2>[command_name()] Shipping Manifest</h2>"
	manifest.info += "<hr/>"
	if(owner && !(owner == "Cargo"))
		manifest.info += "Direct purchase from [owner]<br/>"
		manifest.name += " - Purchased by [owner]"
	manifest.info += "Order[packname?"":"s"]: [id]<br/>"
	manifest.info += "Destination: [station_name]<br/>"
	if(packname)
		manifest.info += "Item: [packname]<br/>"
	manifest.info += "Contents: <br/>"
	manifest.info += "<ul>"
	for(var/atom/movable/ordered in container.contents - manifest)
		if((manifest.errors & MANIFEST_ERROR_CONTENTS))
			if(prob(50))
				manifest.info += "<li>[ordered.name]</li>"
			else
				continue
		manifest.info += "<li>[ordered.name]</li>"
	manifest.info += "</ul>"
	if(signature_requirement)
		manifest.signature_ckey_required = signature_requirement
		manifest.info += "Signature of [owner]: \[________________________]"
	manifest.info += "<h4>Stamp below to confirm receipt of goods:</h4>"

	if(manifest.errors & MANIFEST_ERROR_ITEM)
		if(istype(container, /obj/structure/closet/crate/secure) || istype(container, /obj/structure/closet/crate/large))
			manifest.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(container.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(container.contents))

	manifest.update_appearance()
	manifest.forceMove(container)

	if(istype(container, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/order = container
		order.manifest = manifest
		order.update_appearance()
	else
		container.contents += manifest

	return manifest

/datum/supply_order/proc/generate(atom/A)
	var/account_holder
	if(paying_account)
		account_holder = paying_account.account_holder
	else
		account_holder = "Cargo"
	var/obj/structure/closet/crate/C = pack.generate(A, paying_account)
	generateManifest(C, account_holder, pack)
	return C

/datum/supply_order/proc/generateCombo(miscbox, misc_own, misc_contents)
	for (var/I in misc_contents)
		new I(miscbox)
	generateManifest(miscbox, misc_own, "")
	return
