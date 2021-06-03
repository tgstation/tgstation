/**
 * ## uplink costs unit test
 *
 * Does two things:
 * * Tests for a codebase limit on the total cost of all red tc items, meant to encourage a percise scope for red tc. limit is in antagonists.dm
 * * Tests for items that cost both red and black. It's not supported and should not be done both designwise and codewise
 */
/datum/unit_test/uplink_costs/Run()
	var/total_red_tc = 0

	for(var/datum/uplink_item/uplink_item as anything in subtypesof(/datum/uplink_item))
		var/costs_red = FALSE
		var/costs_black = FALSE
		if(initial(uplink_item.red_cost))
			costs_red = TRUE
			total_red_tc += initial(uplink_item.red_cost)
		if(initial(uplink_item.black_cost))
			costs_black = TRUE
		if(costs_red && costs_black)
			Fail("[initial(uplink_item.name)] costs both red and black telecrystals.")
	if(total_red_tc > RED_TELECRYSTAL_LIMIT)
		Fail("The red telecrystal items total cost is at [total_red_tc], greater than the codebase limit of [RED_TELECRYSTAL_LIMIT]")
