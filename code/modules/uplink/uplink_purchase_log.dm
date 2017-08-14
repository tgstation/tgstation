GLOBAL_LIST(uplink_purchase_logs)

/datum/uplink_purchase_log
	var/owner
	var/spent_telecrystals = 0
	var/list/purchase_log
	var/datum/component/uplink/owning_uplink

/datum/uplink_purchase_log/New(_owner, datum/component/uplink/_owning_uplink)
	owner = _owner
	owning_uplink = _owning_uplink
	LAZYINITLIST(GLOB.uplink_purchase_logs)
	LAZYINITLIST(GLOB.uplink_purchase_logs[_owner])
	GLOB.uplink_purchase_logs[_owner] += src
	purchase_log = list()

/datum/uplink_purchase_log/proc/MergeWith(datum/uplink_purchase_log/other)
	//only do this if the owners match
	. = other.owner == owner
	if(!.)
		return

	spent_telecrystals += other.spent_telecrystals
	//don't lose ordering info
	var/list/our_pl = purchase_log
	var/list/their_pl = other.purchase_log
	var/list/new_pl = list()
	purchase_log = new_pl
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
			pl[str_access] = "<big>[icon2base64html(A)]</big>"
			break
		++target_time
	LogCost(cost)

/datum/uplink_purchase_log/proc/LogCost(cost)
	spent_telecrystals += cost

/datum/uplink_purchase_log/proc/GetPurchaseLog()
	. = ""
	var/list/pl = purchase_log
	for(var/I in pl)	//already sorted
		. += pl[I]

/datum/uplink_purchase_log/Destroy()
	var/_owner = owner
	var/list/our_list = GLOB.uplink_purchase_logs[_owner]
	our_list -= src
	if(!our_list.len)
		GLOB.uplink_purchase_logs -= _owner
	purchase_log.Cut()
	var/datum/component/uplink/_owning_uplink = owning_uplink
	if(_owning_uplink)
		_owning_uplink.log = null
		owning_uplink = null
	return ..()
