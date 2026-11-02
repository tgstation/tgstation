#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// The CASTIFICO finds and strikes the bounties on a name, pays a share for a corpse, and its collar pacifies, forbids spells,
/// cannot be taken off and lets go when torn off.
/datum/unit_test/rogue_machines_castifico

/datum/unit_test/rogue_machines_castifico/Run()
	var/mob/living/carbon/human/consistent/wanted = allocate(__IMPLIED_TYPE__)
	var/obj/structure/chair/wood/rockhill/arrestchair/chair = allocate(/obj/structure/chair/wood/rockhill/arrestchair)
	var/datum/rogue_bounty/bounty = new
	bounty.target = wanted.real_name
	bounty.amount = 100
	GLOB.rogue_head_bounties += bounty
	var/list/found = chair.bounties_on(wanted)
	TEST_ASSERT_EQUAL(length(found), 1, "The CASTIFICO did not find the bounty on the subject's name")
	TEST_ASSERT_EQUAL(chair.collect_bounties(found, TRUE), floor(100 * rogue_value("machines_castifico_corpse_share")), "A corpse did not pay its share of the bounty")
	TEST_ASSERT(!(bounty in GLOB.rogue_head_bounties), "A collected bounty stayed on the board")
	var/obj/item/collar = rogue_castifico_collar(get_turf(wanted))
	collar.AddComponent(/datum/component/rogue_castifico_collar, 100)
	TEST_ASSERT(wanted.equip_to_slot_or_del(collar, ITEM_SLOT_NECK), "The castifico collar could not be put on")
	TEST_ASSERT(HAS_TRAIT(wanted, TRAIT_PACIFISM), "The castifico collar does not pacify its wearer")
	TEST_ASSERT(!wanted.can_cast_magic(MAGIC_RESISTANCE), "The castifico collar does not forbid spells")
	TEST_ASSERT(HAS_TRAIT(collar, TRAIT_NODROP), "The castifico collar can be taken off")
	wanted.dropItemToGround(collar, TRUE)
	TEST_ASSERT(!HAS_TRAIT(wanted, TRAIT_PACIFISM), "A castifico collar torn off still pacifies")

/// The hoard counts things of worth but not coins, and each further piece of a kind is worth less.
/datum/unit_test/rogue_machines_hoard

/datum/unit_test/rogue_machines_hoard/Run()
	var/obj/item/roguecoin/gold/coins = allocate(/obj/item/roguecoin/gold)
	TEST_ASSERT(!SSrogue_hoard.profitable(coins), "The hoard counts coins")
	var/obj/item/ingot/gold/first = allocate(/obj/item/ingot/gold)
	var/obj/item/ingot/gold/second = allocate(/obj/item/ingot/gold)
	first.sellprice = 100
	first.static_price = TRUE
	second.sellprice = 100
	second.static_price = TRUE
	TEST_ASSERT(SSrogue_hoard.profitable(first), "The hoard does not count a gold bar")
	var/list/accounted = list()
	TEST_ASSERT_EQUAL(SSrogue_hoard.count_treasure(first, accounted, 0.5, 0.5), 50, "The first bar did not pay its interest")
	TEST_ASSERT_EQUAL(SSrogue_hoard.count_treasure(second, accounted, 0.5, 0.5), 25, "A second bar of the kind was not worth less")

/// PURITY stocks its wares and sells one for the price and the tariff.
/datum/unit_test/rogue_machines_purity

/datum/unit_test/rogue_machines_purity/Run()
	var/mob/living/carbon/human/consistent/buyer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/roguemachine/drugmachine/purity = allocate(/obj/structure/roguemachine/drugmachine)
	TEST_ASSERT(length(purity.wares), "PURITY has nothing on its shelves")
	var/ware_type = purity.wares[1]
	var/base = purity.wares[ware_type]["PRICE"]
	var/tariff = purity.tariff_on(base)
	purity.budget = base + tariff
	TEST_ASSERT(purity.buy(ware_type, buyer), "PURITY refused a sale it had the coin for")
	TEST_ASSERT_EQUAL(purity.budget, 0, "PURITY took the wrong price")
	TEST_ASSERT_EQUAL(purity.recent_payments, base, "PURITY did not count the takings for the cut")
	TEST_ASSERT(locate(ware_type) in buyer.held_items, "The ware did not reach the buyer's hands")

/// The POTION SELLER takes a fluid in, sells drams of it into the buyer's bottle and keeps the profit.
/datum/unit_test/rogue_machines_potion_seller

/datum/unit_test/rogue_machines_potion_seller/Run()
	var/mob/living/carbon/human/consistent/owner = allocate(__IMPLIED_TYPE__)
	var/obj/structure/roguemachine/potionseller/seller = allocate(/obj/structure/roguemachine/potionseller)
	var/obj/item/reagent_containers/glass/bottle/rogue/source = allocate(/obj/item/reagent_containers/glass/bottle/rogue)
	source.reagents.add_reagent(/datum/reagent/water, 30)
	seller.locked = FALSE
	seller.pour_in(source, owner)
	TEST_ASSERT(seller.potions[/datum/reagent/water], "The poured fluid is not on the shelf")
	TEST_ASSERT_EQUAL(seller.reagents.get_reagent_amount(/datum/reagent/water), 30, "The vat did not take the whole bottle")
	seller.potions[/datum/reagent/water]["PRICE"] = 1
	seller.locked = TRUE
	var/obj/item/reagent_containers/glass/bottle/rogue/target = allocate(/obj/item/reagent_containers/glass/bottle/rogue)
	target.forceMove(seller)
	seller.inserted = target
	seller.budget = 100
	seller.sell(/datum/reagent/water, 10, owner)
	TEST_ASSERT_EQUAL(target.reagents.get_reagent_amount(/datum/reagent/water), 10, "The buyer's bottle was not filled")
	TEST_ASSERT_EQUAL(seller.budget, 90, "The drams were not paid for")
	TEST_ASSERT_EQUAL(seller.profits, 10, "The seller did not keep the profit")

/// The smith's scrapper buys an iron bar it lists, from its coffer, and turns away copper it does not.
/datum/unit_test/rogue_machines_scrapper

/datum/unit_test/rogue_machines_scrapper/Run()
	var/mob/living/carbon/human/consistent/seller = allocate(__IMPLIED_TYPE__)
	var/obj/structure/roguemachine/scrapper/smith/scrapper = allocate(/obj/structure/roguemachine/scrapper/smith)
	var/obj/item/ingot/iron/bar = allocate(/obj/item/ingot/iron)
	seller.put_in_hands(bar)
	var/coffer = scrapper.budget
	TEST_ASSERT(scrapper.recycle(bar, seller), "The scrapper refused an iron bar it buys")
	TEST_ASSERT_EQUAL(bar.loc, scrapper, "The bar is not in the hopper")
	TEST_ASSERT_EQUAL(scrapper.material_held[/obj/item/ingot/iron], 1, "The hopper did not count the bar")
	TEST_ASSERT_EQUAL(scrapper.budget, coffer - scrapper.material_prices[/obj/item/ingot/iron], "The bar was not paid from the coffer")
	var/obj/item/ingot/copper/copper = allocate(/obj/item/ingot/copper)
	seller.put_in_hands(copper)
	TEST_ASSERT(!scrapper.recycle(copper, seller), "The scrapper bought copper it does not take by default")

/// A commission is priced from its materials and margins, posted from the deposit, delivered and paid out.
/datum/unit_test/rogue_machines_commissioner

/datum/unit_test/rogue_machines_commissioner/Run()
	var/mob/living/carbon/human/consistent/customer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/roguemachine/escrow/board = allocate(/obj/structure/roguemachine/escrow)
	var/datum/crafting_recipe/roguetown/work = new
	work.name = "test bar"
	work.reqs = list(/obj/item/ingot/iron = 2)
	work.result = /obj/item/ingot/steel
	board.percent_margin = 50
	board.flat_margin = 5
	board.material_prices[/obj/item/ingot/iron] = 10
	var/price = board.recipe_price(work)
	TEST_ASSERT_EQUAL(price, 35, "A work is not priced as its materials and the margins")
	board.deposits[customer.real_name] = 100
	var/list/cart = list()
	cart[work] = 1
	board.manifests[customer.real_name] = cart
	board.submit_manifest(customer, "")
	TEST_ASSERT_EQUAL(length(board.orders), 1, "The commission was not posted")
	TEST_ASSERT_EQUAL(board.escrow, price, "The price was not held in escrow")
	TEST_ASSERT_EQUAL(board.deposits[customer.real_name], 100 - price, "The price was not taken from the deposit")
	var/datum/rogue_commission/order = board.orders[1]
	order.status = "claimed"
	order.smith_name = customer.real_name
	var/obj/item/ingot/steel/made = allocate(/obj/item/ingot/steel)
	customer.put_in_hands(made)
	board.deliver(made, customer)
	TEST_ASSERT_EQUAL(made.loc, board, "The finished work was not delivered")
	board.complete(order, customer)
	TEST_ASSERT_EQUAL(order.status, "complete", "A fully delivered commission was not completed")
	TEST_ASSERT_EQUAL(board.escrow, 0, "The escrow was not paid out")
	qdel(work)

/// Zads fly from the cote to a bonded cage, wait there and fly home to the reserve.
/datum/unit_test/rogue_machines_zadcote

/datum/unit_test/rogue_machines_zadcote/Run()
	var/mob/living/carbon/human/consistent/keeper = allocate(__IMPLIED_TYPE__)
	ADD_TRAIT(keeper, TRAIT_AGENT_MERCHANT, TRAIT_SOURCE_UNIT_TESTS)
	var/obj/item/roguemachine/zadcote/merchant/cote = allocate(/obj/item/roguemachine/zadcote/merchant)
	var/obj/item/screwdriver/cage = allocate(/obj/item/screwdriver)
	TEST_ASSERT(cote.attach_cage(cage, keeper), "The cote did not bond a cage")
	var/datum/rogue_zadlink/link = cote.slots[1]
	TEST_ASSERT_EQUAL(link.cage(), cage, "The cage is not on the first zadlink")
	var/reserve = cote.reserve
	TEST_ASSERT(cote.dispatch(link, 1, "hello", FALSE, 0, keeper, ""), "The cote refused to send a zad")
	TEST_ASSERT_EQUAL(cote.reserve, reserve - 1, "The zad did not leave the reserve")
	var/datum/rogue_zad_flight/flight = link.flight()
	TEST_ASSERT(flight, "No flight is on the zadlink")
	flight.turnback_checked = TRUE
	flight.arrival_time = world.time
	cote.process(1)
	var/datum/component/rogue_zadcage/bond = link.cage_component()
	TEST_ASSERT(bond.occupied, "The zad did not land in the cage")
	TEST_ASSERT(bond.send_home(null, null), "The zad would not fly home")
	TEST_ASSERT_EQUAL(length(cote.returning), 1, "The zad is not on its way home")
	var/datum/rogue_zad_flight/homeward = cote.returning[1]
	homeward.lost = 0
	homeward.arrival_time = world.time
	cote.process(1)
	TEST_ASSERT_EQUAL(cote.reserve, reserve, "The zad did not come back to the reserve")

/// The Otavan imports carry their goods and arrive crated.
/datum/unit_test/rogue_machines_marquette

/datum/unit_test/rogue_machines_marquette/Run()
	TEST_ASSERT(length(rogue_inqports()), "The MARQUETTE sells nothing")
	var/datum/rogue_inqport/reds
	for(var/datum/rogue_inqport/import as anything in rogue_inqports())
		TEST_ASSERT(length(import.wares), "[import.name] holds nothing")
		if(import.name == "3 Bottles of Red")
			reds = import
	TEST_ASSERT(reds, "The bottles of red are not sold")
	var/turf/spot = run_loc_floor_bottom_left
	reds.deliver(spot)
	var/obj/structure/closet/crate = locate(/obj/structure/closet/crate/wooden/rockhill/crate/chest) in spot
	TEST_ASSERT(crate, "The import did not arrive crated")
	var/bottles = 0
	for(var/obj/item/reagent_containers/glass/bottle/rogue/healthpot/bottle in crate)
		bottles++
	TEST_ASSERT_EQUAL(bottles, 3, "The crate does not hold three bottles of red")
	qdel(crate)

/// A care package of the Wretch always holds a health potion.
/datum/unit_test/rogue_machines_carebox

/datum/unit_test/rogue_machines_carebox/Run()
	var/datum/rogue_carebox_table/wretch/table = new
	var/list/items = table.items_of(table.extra_loot)
	TEST_ASSERT(/obj/item/reagent_containers/glass/bottle/rogue/healthpot in items, "The Wretch's package lacks its health potion")
	for(var/choice in table.loot)
		TEST_ASSERT(length(table.items_of(table.loot[choice])), "The package choice [choice] holds nothing")
	qdel(table)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
