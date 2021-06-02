///tests for a codebase limit on the total cost of all red tc items, meant to encourage a percise scope for red tc. limit is in antagonists.dm
/datum/unit_test/red_tc_limit/Run()
	var/total_red_tc = 0

	for(var/datum/uplink_item/uplink_item as anything in subtypesof(/datum/uplink_item))
		total_red_tc += uplink_item.red_cost
	if(total_red_tc > RED_TELECRYSTAL_LIMIT)
		Fail("The red telecrystal items total cost is greater than the codebase limit of [RED_TELECRYSTAL_LIMIT]")
