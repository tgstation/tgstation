/// Ensures black market items have acceptable variable values.
/datum/unit_test/blackmarket

/datum/unit_test/blackmarket/Run()
	for(var/datum/market_item/prototype as anything in subtypesof(/datum/market_item))
		if(prototype::abstract_path == prototype) //skip abstract paths
			continue
		if(!prototype::category)
			TEST_FAIL("[prototype] doesn't have a set category (or the abstract path var isn't correctly set)")
			continue
		if(!prototype::item)
			TEST_FAIL("[prototype] doesn't have a set item (or the abstract path var isn't correctly set)")
			continue
		if(isnull(prototype::price) && prototype::price_max <= prototype::price_min)
			TEST_FAIL("[prototype] doesn't have a correctly set random price (price_max should be higher than price_min)")
		if(isnull(prototype::stock) && prototype::stock_max < prototype::stock_min)
			TEST_FAIL("[prototype] doesn't have a correctly set random stock (stock_max shouldn't be lower than stock_min)")
		if(!isnum(prototype::availability_prob))
			TEST_FAIL("[prototype] doesn't have a set availability_prob (must be a number)")
		if(!prototype::name)
			TEST_FAIL("[prototype] doesn't have a set name")
		if(!prototype::desc)
			TEST_FAIL("[prototype] doesn't have a set desc")
