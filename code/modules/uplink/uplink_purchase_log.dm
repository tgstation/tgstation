GLOBAL_LIST(uplink_purchase_logs_by_key) //assoc key = /datum/uplink_purchase_log

/datum/uplink_purchase_log
	var/owner
	var/list/purchase_log //assoc path-of-item = /datum/uplink_purchase_entry
	var/total_spent = 0

/datum/uplink_purchase_log/New(_owner, datum/component/uplink/_parent)
	owner = _owner
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	if(owner)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			stack_trace("WARNING: DUPLICATE PURCHASE LOGS DETECTED. [_owner] [_parent] [_parent.type]")
			MergeWithAndDel(GLOB.uplink_purchase_logs_by_key[owner])
		GLOB.uplink_purchase_logs_by_key[owner] = src
	purchase_log = list()

/datum/uplink_purchase_log/Destroy()
	purchase_log = null
	if(GLOB.uplink_purchase_logs_by_key[owner] == src)
		GLOB.uplink_purchase_logs_by_key -= owner
	return ..()

/datum/uplink_purchase_log/proc/MergeWithAndDel(datum/uplink_purchase_log/other)
	if(!istype(other))
		return
	. = owner == other.owner
	if(!.)
		return
	for(var/hash in other.purchase_log)
		if(!purchase_log[hash])
			purchase_log[hash] = other.purchase_log[hash]
		else
			var/datum/uplink_purchase_entry/UPE = purchase_log[hash]
			var/datum/uplink_purchase_entry/UPE_O = other.purchase_log[hash]
			UPE.amount_purchased += UPE_O.amount_purchased
	qdel(other)

/datum/uplink_purchase_log/proc/TotalTelecrystalsSpent()
	. = total_spent

#define FORMAT_COST(uplink_entry) (uplink_entry.spent_cost ? "[uplink_entry.spent_cost] TC" : (uplink_entry.base_cost ? "Free" : "Surplus"))

/datum/uplink_purchase_log/proc/generate_render(show_key = TRUE)
	. = ""
	for(var/hash in purchase_log)
		var/datum/uplink_purchase_entry/UPE = purchase_log[hash]
		. += "<span class='tooltip_container'>\[[UPE.icon_b64][show_key ? "([owner])":""]<span class='tooltip_hover'><b>[UPE.name]</b><br>[FORMAT_COST(UPE)]<br>[UPE.desc]</span>[(UPE.amount_purchased > 1) ? "x[UPE.amount_purchased]" : ""]\]</span>"

#undef FORMAT_COST

/// Logs that an uplink item was purchased
/datum/uplink_purchase_log/proc/log_purchase(atom/spawned_item, datum/uplink_item/uplink_item, spent_cost)
	var/hash = hash_purchase(uplink_item, spent_cost)
	var/datum/uplink_purchase_entry/purchase_entry = purchase_log[hash]
	if(isnull(purchase_entry))
		purchase_entry = new()
		purchase_entry.set_item(spawned_item)
		purchase_entry.name = uplink_item.name
		purchase_entry.desc = uplink_item.desc
		purchase_entry.base_cost = initial(uplink_item.cost)
		purchase_entry.spent_cost = spent_cost
		purchase_log[hash] = purchase_entry

	purchase_entry.amount_purchased += 1
	total_spent += spent_cost

/// Used to add custom items into the purchase log
/datum/uplink_purchase_log/proc/log_purchase_custom(datum/uplink_purchase_entry/custom_entry)
	purchase_log[REF(custom_entry)] = custom_entry
	total_spent += custom_entry.spent_cost

/datum/uplink_purchase_log/proc/hash_purchase(datum/uplink_item/uplink_item, spent_cost)
	return "[uplink_item.type]|[uplink_item.name]|[uplink_item.cost]|[spent_cost]"

/datum/uplink_purchase_entry
	var/amount_purchased = 0
	var/path
	var/icon_b64
	var/desc
	var/base_cost
	var/spent_cost
	var/name

/datum/uplink_purchase_entry/proc/set_item(obj/item/to_set)
	path = to_set.type
	icon_b64 = "[icon2base64html(to_set)]"
