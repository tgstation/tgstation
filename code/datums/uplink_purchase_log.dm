GLOBAL_LIST(uplink_purchase_logs_by_key)	//assoc key = /datum/uplink_purchase_log

/datum/uplink_purchase_log
	var/owner
	var/list/purchase_log				//assoc path-of-item = /datum/uplink_purchase_entry
	var/datum/component/uplink/parent
	var/total_spent = 0

/datum/uplink_purchase_log/New(_owner, datum/component/uplink/_parent)
	owner = _owner
	parent = _parent
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	if(owner)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			stack_trace("WARNING: DUPLICATE PURCHASE LOGS DETECTED. [_owner] [_parent] [_parent.type]")
			MergeWithAndDel(GLOB.uplink_purchase_logs_by_key[owner])
		GLOB.uplink_purchase_logs_by_key[owner] = src
	purchase_log = list()

/datum/uplink_purchase_log/Destroy()
	purchase_log = null
	parent = null
	return ..()

/datum/uplink_purchase_log/proc/MergeWithAndDel(datum/uplink_purchase_log/other)
	if(!istype(other))
		return
	. = owner == other.owner
	if(!.)
		return
	for(var/path in other.purchase_log)
		if(!purchase_log[path])
			purchase_log[path] = other.purchase_log[path]
		else
			var/datum/uplink_purchase_entry/UPE = purchase_log[path]
			var/datum/uplink_purchase_entry/UPE_O = other.purchase_log[path]
			UPE.amount_purchased += UPE_O.amount_purchased
	qdel(other)

/datum/uplink_purchase_log/proc/TotalTelecrystalsSpent()
	. = total_spent

/datum/uplink_purchase_log/proc/generate_render(show_key = TRUE)
	. = ""
	for(var/path in purchase_log)
		var/datum/uplink_purchase_entry/UPE = purchase_log[path]
		. += "<big>\[[UPE.icon_b64][show_key?"([owner])":""]\]</big>"

/datum/uplink_purchase_log/proc/LogPurchase(atom/A, cost)
	var/datum/uplink_purchase_entry/UPE
	if(purchase_log[A.type])
		UPE = purchase_log[A.type]
	else
		UPE = new
		purchase_log[A.type] = UPE
		UPE.path = A.type
		UPE.icon_b64 = "[icon2base64html(A)]"
	UPE.amount_purchased++
	total_spent += cost

/datum/uplink_purchase_entry
	var/amount_purchased = 0
	var/path
	var/icon_b64
