#define CATEGORY_CODERBUS "Coderbus"
/// Ensures market items have acceptable variable values and restocking works.
/datum/unit_test/market

/datum/unit_test/market/Run()
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


	var/datum/market/unit_test/market = SSmarket.markets[/datum/market/unit_test]
	TEST_ASSERT(market, "Couldn't find the unit test market")
	var/list/category_items = market.available_items[CATEGORY_CODERBUS]
	var/datum/market_item/unit_test/item = category_items[category_items[1]]
	TEST_ASSERT(item, "Couldn't find the unit test market item")
	TEST_ASSERT_EQUAL(item.stock, 1, "The unit test market item is incorrectly stocked. Only one should be in stock")

	var/mob/living/user = allocate(/mob/living)
	var/obj/item/holochip/chip = allocate(/obj/item/holochip, run_loc_floor_bottom_left, INFINITY)
	var/obj/machinery/ltsrbt/pad = allocate(/obj/machinery/ltsrbt)

	pad.item_interaction(user, chip)

	TEST_ASSERT_EQUAL(item, category_items[category_items[1]], "The unit test market item has been replaced during restock")
	TEST_ASSERT_EQUAL(item.stock, 2, "The unit test market item is incorrectly stocked after restock. There should be two in stock")

/datum/market/unit_test
	name = "Unit Test Market"
	shipping = list(SHIPPING_METHOD_TELEPORT = 0)

/datum/market_item/unit_test
	name = "Your Own Special Singularity"
	desc = "ALL HAIL LORD SINGULOTH!!!"
	category = CATEGORY_CODERBUS
	markets = list(/datum/market/unit_test)
	item = /obj/singularity
	price = 42069
	stock_min = 1
	stock = 1
	stock_max = 2
	availability_prob = 100

#undef CATEGORY_CODERBUS
