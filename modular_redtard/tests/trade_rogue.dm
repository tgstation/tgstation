#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// A held road doubles a region's import price and halves what it pays for exports; past its daily pace a region sells dearer.
/datum/unit_test/rogue_trade_blockade_prices

/datum/unit_test/rogue_trade_blockade_prices/Run()
	var/datum/rogue_trade_good/grain = new /datum/rogue_trade_good/grain
	var/datum/rogue_trade_region/producer = new /datum/rogue_trade_region/kingsfield
	var/datum/rogue_trade_region/buyer = new /datum/rogue_trade_region/rosawood
	producer.new_day(1)
	buyer.new_day(1)
	var/open_import = producer.import_unit_cost(grain)
	TEST_ASSERT(open_import > 0, "Kingsfield does not sell grain")
	TEST_ASSERT(producer.import_unit_cost(grain, producer.produces[grain.id] * 2) > open_import, "Grain far past the daily pace is not dearer")
	var/open_export = buyer.export_unit_price(grain)
	TEST_ASSERT(open_export > 0, "Rosawood does not buy grain")
	producer.blockaded = TRUE
	buyer.blockaded = TRUE
	TEST_ASSERT(producer.import_unit_cost(grain) >= open_import * rogue_value("trade_blockade_import_mult") - 1, "A held road does not raise the import price")
	TEST_ASSERT(buyer.export_unit_price(grain) < open_export, "A held road does not lower what a region pays")
	qdel(grain)
	qdel(producer)
	qdel(buyer)

/// Every economic event names a price tier that has a value, shortages raising and gluts lowering the price.
/datum/unit_test/rogue_trade_event_tiers

/datum/unit_test/rogue_trade_event_tiers/Run()
	for(var/event_type in subtypesof(/datum/rogue_economic_event))
		var/datum/rogue_economic_event/event = new event_type
		var/mod = rogue_event_price_mod(event.price_tier)
		if(event.event_type == ROGUE_EVENT_SHORTAGE)
			TEST_ASSERT(mod > 1, "[event_type] is a shortage that does not raise its price (tier [event.price_tier])")
		else
			TEST_ASSERT(mod < 1, "[event_type] is a glut that does not lower its price (tier [event.price_tier])")
		TEST_ASSERT(length(event.affected_goods), "[event_type] moves no goods")
		qdel(event)

/// A condition of a foreign realm removes, scales and adds its ships' cargo lines.
/datum/unit_test/rogue_trade_realm_condition

/datum/unit_test/rogue_trade_realm_condition/Run()
	var/datum/rogue_foreign_realm/avar = new /datum/rogue_foreign_realm/aavnr
	var/datum/rogue_realm_condition/drought = new /datum/rogue_realm_condition/aavnr_steppe_drought
	drought.apply_to(avar)
	TEST_ASSERT(drought in avar.conditions, "The drought did not befall Avar")
	for(var/list/line as anything in avar.effective_pool(TRUE))
		TEST_ASSERT(line["good"] != "GRAIN", "Avar's ships still sell grain through a drought")
	var/found_grain = FALSE
	for(var/list/line as anything in avar.effective_pool(FALSE))
		if(line["good"] == "GRAIN")
			found_grain = TRUE
			TEST_ASSERT(line["price_mod"] > 1, "Avar does not pay a premium for grain in a drought")
	TEST_ASSERT(found_grain, "Avar's ships do not buy grain in a drought")
	qdel(drought)
	qdel(avar)

/// The pricing engine prices a smithed thing from its bars, times its category's markup, per unit made.
/datum/unit_test/rogue_trade_pricing_engine

/datum/unit_test/rogue_trade_pricing_engine/Run()
	var/datum/rogue_trade_good/iron = new /datum/rogue_trade_good/iron_ingot
	var/datum/rogue_pricing_engine/engine = new
	var/list/goods = list()
	goods[iron.id] = iron
	engine.set_baselines(goods)
	TEST_ASSERT_EQUAL(engine.baselines[/obj/item/ingot/iron], iron.base_price, "Iron is not priced by its trade price")
	TEST_ASSERT_EQUAL(engine.derive(100, "Garments (Fine)", 2), round(100 * rogue_value("trade_markup_fine_garment") / 2), "Fine garments do not take their markup")
	engine.derive_all()
	var/datum/anvil_recipe/plain
	for(var/datum/anvil_recipe/recipe as anything in GLOB.rogue_anvil_recipes)
		if(recipe.req_bar == /obj/item/ingot/iron && !length(recipe.additional_items) && recipe.created_item && !engine.fixed[recipe.created_item])
			plain = recipe
			break
	if(plain)
		var/expected = engine.derive(iron.base_price, plain.display_category || "Smithing (Misc)", plain.createditem_num)
		TEST_ASSERT(engine.prices[plain.created_item] && engine.prices[plain.created_item] <= expected, "[plain.type] is not priced from one iron bar")
	qdel(engine)
	qdel(iron)

/// The pledge pays commissions while it holds enough, refunds them, and the Golden Bull renews it at dawn.
/datum/unit_test/rogue_trade_burgher_pledge

/datum/unit_test/rogue_trade_burgher_pledge/Run()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/pledge/old_pledge = treasury.burgher_pledge
	var/datum/rogue_decree/old_bull = treasury.decrees[ROGUE_DECREE_GOLDEN_BULL]
	var/datum/bank_account/rogue/pledge/pledge = new("Burgher Pledge")
	treasury.burgher_pledge = pledge
	pledge.adjust_money(300, "test")
	TEST_ASSERT(treasury.draw_pledge(200, "test commission"), "The pledge did not pay a commission it could cover")
	TEST_ASSERT_EQUAL(pledge.account_balance, 100, "The commission was not drawn from the pledge")
	TEST_ASSERT(!treasury.draw_pledge(200, "test commission"), "The pledge paid a commission it could not cover")
	TEST_ASSERT(treasury.refund_pledge(50, "test refund"), "The pledge took no refund")
	TEST_ASSERT_EQUAL(pledge.account_balance, 150, "The refund did not reach the pledge")
	var/datum/rogue_decree/golden_bull/bull = new
	treasury.decrees[ROGUE_DECREE_GOLDEN_BULL] = bull
	var/before = pledge.account_balance
	treasury.tick_burgher_pledge()
	TEST_ASSERT_EQUAL(pledge.account_balance, before + treasury.pledge_renewal() + treasury.pledge_arms_tribute(), "The Golden Bull did not renew the pledge")
	bull.active = FALSE
	before = pledge.account_balance
	treasury.tick_burgher_pledge()
	TEST_ASSERT_EQUAL(pledge.account_balance, before, "A suspended Golden Bull renewed the pledge")
	if(old_bull)
		treasury.decrees[ROGUE_DECREE_GOLDEN_BULL] = old_bull
	else
		treasury.decrees -= ROGUE_DECREE_GOLDEN_BULL
	treasury.burgher_pledge = old_pledge
	qdel(bull)
	qdel(pledge)

/// The Ordinance of the Baths tithes a share of the bathhouse's dues to the Church, adding up shares of a mammon; broken, none.
/datum/unit_test/rogue_trade_ordinance_tithe

/datum/unit_test/rogue_trade_ordinance_tithe/Run()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/old_church = treasury.funds[ROGUE_FUND_CHURCH]
	var/old_ordinance = treasury.bathhouse_ordinance
	var/old_debt = treasury.bathhouse_tithe_debt
	var/datum/bank_account/rogue/fund/church/church = new("Church Fund")
	treasury.funds[ROGUE_FUND_CHURCH] = church
	treasury.bathhouse_ordinance = TRUE
	treasury.bathhouse_tithe_debt = 0
	TEST_ASSERT_EQUAL(treasury.bathhouse_tithe(100, 0.1), 10, "The Ordinance did not tithe a tenth")
	TEST_ASSERT_EQUAL(treasury.bathhouse_tithe(5, 0.1), 0, "Half a mammon of tithe was paid at once")
	TEST_ASSERT_EQUAL(treasury.bathhouse_tithe(5, 0.1), 1, "Two halves of a mammon did not make a coin of tithe")
	treasury.bathhouse_ordinance = FALSE
	TEST_ASSERT_EQUAL(treasury.bathhouse_tithe(100, 0.1), 0, "A broken Ordinance still tithed")
	treasury.bathhouse_ordinance = old_ordinance
	treasury.bathhouse_tithe_debt = old_debt
	if(old_church)
		treasury.funds[ROGUE_FUND_CHURCH] = old_church
	else
		treasury.funds -= ROGUE_FUND_CHURCH
	qdel(church)

/// A sale at the tavern's stall is banked in the tavern's fund instead of waiting in the stall.
/datum/unit_test/rogue_trade_stall_takings

/datum/unit_test/rogue_trade_stall_takings/Run()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/bank_account/rogue/old_tavern = treasury.funds[ROGUE_FUND_TAVERN]
	var/datum/bank_account/rogue/fund/tavern/tavern = new("Tavern Earnings")
	treasury.funds[ROGUE_FUND_TAVERN] = tavern
	var/obj/structure/roguemachine/vendor/innrockhill/stall = allocate(/obj/structure/roguemachine/vendor/innrockhill)
	TEST_ASSERT_EQUAL(stall.takings_fund(), tavern, "The tavern's stall does not belong to the tavern's fund")
	stall.profits = 20
	TEST_ASSERT(stall.bank_takings(20), "The tavern's stall did not bank its takings")
	TEST_ASSERT_EQUAL(tavern.account_balance, 20, "The takings did not reach the tavern's fund")
	TEST_ASSERT_EQUAL(stall.profits, 0, "The banked takings stayed in the stall")
	var/obj/structure/roguemachine/vendor/street = allocate(/obj/structure/roguemachine/vendor)
	TEST_ASSERT_NULL(street.takings_fund(), "A merchant's stall banks its takings in a fund")
	if(old_tavern)
		treasury.funds[ROGUE_FUND_TAVERN] = old_tavern
	else
		treasury.funds -= ROGUE_FUND_TAVERN
	qdel(tavern)

/// Every homeland that trades by sea names a foreign realm, and a character of Avar is kin to Avar's ships.
/datum/unit_test/rogue_trade_kinship

/datum/unit_test/rogue_trade_kinship/Run()
	var/list/realm_ids = list()
	for(var/realm_type in subtypesof(/datum/rogue_foreign_realm))
		var/datum/rogue_foreign_realm/realm = new realm_type
		realm_ids += realm.id
		qdel(realm)
	var/list/homelands = rogue_homelands()
	for(var/homeland_name in GLOB.rogue_homeland_realms)
		TEST_ASSERT(homelands[homeland_name], "No homeland is named [homeland_name]")
		TEST_ASSERT(GLOB.rogue_homeland_realms[homeland_name] in realm_ids, "[homeland_name] names no foreign realm")
	var/mob/living/carbon/human/consistent/sailor = allocate(__IMPLIED_TYPE__)
	sailor.rogue_set_homeland(homelands["Avar"])
	TEST_ASSERT_EQUAL(rogue_homeland_realm(sailor), "aavnr", "A character of Avar is no kin to Avar")
	sailor.rogue_set_homeland(homelands["Ferentia"])
	TEST_ASSERT_NULL(rogue_homeland_realm(sailor), "A Ferentian is kin to a foreign realm")

/// A crown import costs a quarter more for every order of it today.
/datum/unit_test/rogue_trade_crown_import_price

/datum/unit_test/rogue_trade_crown_import_price/Run()
	var/datum/rogue_crown_import/cow = new /datum/rogue_crown_import/cow
	var/first = cow.price()
	TEST_ASSERT_EQUAL(first, max(cow.base_cost, rogue_value("trade_crown_import_min")), "A first crown import is not at its base cost")
	cow.ordered_today = 1
	TEST_ASSERT_EQUAL(cow.price(), max(round(cow.base_cost * (1 + rogue_value("trade_crown_import_elasticity"))), rogue_value("trade_crown_import_min")), "A second order today is not dearer")
	qdel(cow)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
