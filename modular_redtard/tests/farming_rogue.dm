#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's crop data (farming/plants.dm): every crop yields an item with a sprite, or waits for the porter to bring it; its four
/// looks are in the crop sheet; every seed grows a crop, a herb or a sapling and says what it is; every produce gives seeds that
/// grow something.
/datum/unit_test/rogue_farming_data

/datum/unit_test/rogue_farming_data/Run()
	// Crops whose harvest the porter has not brought yet: they cannot be sown until it does.
	var/list/waiting = list(/datum/plant_def/rice, /datum/plant_def/turnip, /datum/plant_def/pumpkin, /datum/plant_def/cucumber, /datum/plant_def/eggplant)
	TEST_ASSERT(length(GLOB.rogue_plant_defs), "No crops are defined")
	for(var/crop_type in GLOB.rogue_plant_defs)
		var/datum/plant_def/crop = GLOB.rogue_plant_defs[crop_type]
		if(!crop.can_grow() && !(crop_type in waiting))
			TEST_FAIL("[crop_type] yields [crop.produce_type || "nothing"], not an item with a sprite")
		if(crop.produce_amount_min < 1 || crop.produce_amount_max < crop.produce_amount_min)
			TEST_FAIL("[crop_type] yields [crop.produce_amount_min] to [crop.produce_amount_max]")
		if(crop.maturation_time <= 0 || crop.produce_time <= 0 || crop.maturation_nutrition <= 0 || crop.produce_nutrition <= 0)
			TEST_FAIL("[crop_type] grows in no time or on no nutrition")
		for(var/look in ROGUE_CROP_GROWING to ROGUE_CROP_DEAD)
			if(!icon_exists(crop.icon, crop.stage_state(look)))
				TEST_FAIL("[crop_type] has no look \"[crop.stage_state(look)]\" in [crop.icon]")
	for(var/seed_type in GLOB.rogue_seed_grows)
		var/grows = GLOB.rogue_seed_grows[seed_type]
		if(!ispath(seed_type, /obj/item))
			TEST_FAIL("[seed_type] in rogue_seed_grows is not an item")
		if(!GLOB.rogue_seed_identities[seed_type])
			TEST_FAIL("[seed_type] does not say what it is")
		if(ispath(grows, /datum/plant_def))
			if(!GLOB.rogue_plant_defs[grows])
				TEST_FAIL("[seed_type] grows [grows], which is not a crop")
		else if(!ispath(grows, /obj/structure/flora/roguegrass/herb) && !ispath(grows, /obj/structure/tree_sapling) && !ispath(grows, /obj/structure/bush_sapling))
			TEST_FAIL("[seed_type] grows [grows], neither a crop, a herb nor a sapling")
	for(var/produce_type in GLOB.rogue_produce_seeds)
		var/seed_type = GLOB.rogue_produce_seeds[produce_type]
		if(!ispath(produce_type, /obj/item) || !GLOB.rogue_seed_grows[seed_type])
			TEST_FAIL("[produce_type] gives [seed_type], which grows nothing")

/// A crop in watered, fed soil drinks, eats and grows, matures, makes produce and comes out as it at harvest; an annual crop is
/// gone after it, unless a legendary farmer reaps it; in dry soil a thirsty crop wilts.
/datum/unit_test/rogue_farming_growth

/datum/unit_test/rogue_farming_growth/Run()
	var/mob/living/carbon/human/consistent/farmer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/soil/soil = allocate(/obj/structure/soil)
	var/datum/plant_def/crop = GLOB.rogue_plant_defs[/datum/plant_def/cabbage]
	soil.insert_plant(crop)
	TEST_ASSERT_EQUAL(soil.plant, crop, "Planting did not set the crop")
	soil.water = ROGUE_SOIL_MAX_WATER
	soil.nutrition = ROGUE_SOIL_MAX_NUTRITION
	soil.process(60)
	TEST_ASSERT(soil.growth_time > 0, "A crop in watered, fed soil did not grow")
	TEST_ASSERT(soil.nutrition < ROGUE_SOIL_MAX_NUTRITION, "Growing ate no nutrition")
	TEST_ASSERT(soil.water < ROGUE_SOIL_MAX_WATER, "The crop drank no water")
	soil.add_growth(crop.maturation_time)
	TEST_ASSERT(soil.matured, "The crop did not mature")
	soil.add_growth(crop.produce_time)
	TEST_ASSERT(soil.produce_ready, "The matured crop made no produce")
	soil.yield_produce()
	var/heads = 0
	for(var/obj/item/reagent_containers/food/snacks/grown/cabbage/rogue/head in soil.loc)
		heads++
	TEST_ASSERT(heads >= crop.produce_amount_min && heads <= crop.produce_amount_max, "The harvest gave [heads] cabbages")
	TEST_ASSERT(isnull(soil.plant), "An annual crop stayed planted after its harvest")
	farmer.rogue_set_skill(ROGUE_FARMING_SKILL, ROGUE_SKILL_LEVEL_LEGENDARY)
	soil.insert_plant(crop)
	soil.add_growth(crop.maturation_time)
	soil.add_growth(crop.produce_time)
	soil.user_harvests(farmer)
	TEST_ASSERT_EQUAL(soil.plant, crop, "A legendary farmer's annual crop did not stay to grow again")
	TEST_ASSERT(!soil.matured && !soil.produce_ready, "A legendary farmer's annual crop did not start over")
	soil.water = 0
	var/health = soil.plant_health
	soil.process(60)
	TEST_ASSERT(soil.plant_health < health, "A thirsty crop in dry soil did not wilt")

/// Weeds grow in watered, fed soil and die in dry soil; pulled, they are gone; soil left with nothing in it flattens away.
/datum/unit_test/rogue_farming_weeds

/datum/unit_test/rogue_farming_weeds/Run()
	var/obj/structure/soil/soil = allocate(/obj/structure/soil)
	soil.water = ROGUE_SOIL_MAX_WATER
	soil.nutrition = ROGUE_SOIL_MAX_NUTRITION
	soil.process(10 * 60)
	TEST_ASSERT(soil.weeds > 0, "Weeds did not grow in watered, fed soil")
	soil.deweed()
	TEST_ASSERT_EQUAL(soil.weeds, 0, "Pulled weeds stayed")
	soil.weeds = ROGUE_SOIL_MAX_WEEDS / 2
	soil.water = 0
	soil.process(60)
	TEST_ASSERT(soil.weeds < ROGUE_SOIL_MAX_WEEDS / 2, "Weeds did not die in dry soil")
	var/obj/structure/soil/bare = allocate(/obj/structure/soil, run_loc_floor_top_right)
	bare.process(rogue_value("farm_soil_decay_time") / (1 SECONDS))
	TEST_ASSERT(QDELETED(bare), "Soil with nothing in it did not flatten away")

/// Seeds go into soil: a crop seed plants its crop, a herb seed a seedling.
/datum/unit_test/rogue_farming_sowing

/datum/unit_test/rogue_farming_sowing/Run()
	var/mob/living/carbon/human/consistent/farmer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/soil/soil = allocate(/obj/structure/soil)
	var/obj/item/seeds/pear/seed = allocate(/obj/item/seeds/pear)
	TEST_ASSERT(soil.rogue_plant_seed(seed, farmer), "A pear seed was not planted")
	TEST_ASSERT_EQUAL(soil.plant, GLOB.rogue_plant_defs[/datum/plant_def/tree/pear], "A pear seed planted something else")
	TEST_ASSERT(QDELETED(seed), "The planted seed stayed")
	var/obj/structure/soil/herb_soil = allocate(/obj/structure/soil, run_loc_floor_top_right)
	var/obj/item/herbseed/rosa/herb_seed = allocate(/obj/item/herbseed/rosa)
	TEST_ASSERT(herb_soil.rogue_plant_seed(herb_seed, farmer), "A herb seed was not planted")
	TEST_ASSERT(locate(/obj/structure/soil_seedling/herb) in get_turf(herb_soil), "A herb seed made no seedling")

/// A tree sapling in watered, fed soil drinks from it and grows into a shrub; left dry after that it withers.
/datum/unit_test/rogue_farming_sapling

/datum/unit_test/rogue_farming_sapling/Run()
	var/obj/structure/soil/soil = allocate(/obj/structure/soil)
	soil.water = ROGUE_SOIL_MAX_WATER
	soil.nutrition = ROGUE_SOIL_MAX_NUTRITION
	var/obj/structure/tree_sapling/sapling = allocate(/obj/structure/tree_sapling)
	TEST_ASSERT_EQUAL(sapling.linked_soil, soil, "A sapling planted in soil did not root in it")
	sapling.process(60)
	TEST_ASSERT(sapling.growth_progress > 0, "A sapling in watered, fed soil did not grow")
	TEST_ASSERT(soil.water < ROGUE_SOIL_MAX_WATER, "The sapling drank nothing")
	sapling.growth_progress = rogue_value("farm_tree_stage_time")
	sapling.process(1)
	TEST_ASSERT_EQUAL(sapling.stage, ROGUE_TREESAP_SHRUB, "The sapling did not become a shrub")
	soil.water = 0
	for(var/i in 1 to 10)
		if(sapling.dead)
			break
		sapling.process(60)
	TEST_ASSERT(sapling.dead, "A sapling left in dry soil did not wither")

/// The composter takes stalks, flipped compost rots into ready compost, and ready compost comes out a heap at a time; a thresher
/// beats grain and a fiber out of stalks.
/datum/unit_test/rogue_farming_compost

/datum/unit_test/rogue_farming_compost/Run()
	var/mob/living/carbon/human/consistent/farmer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/composter/composter = allocate(/obj/structure/composter)
	var/obj/item/natural/chaff/wheat/stalks = allocate(/obj/item/natural/chaff/wheat)
	TEST_ASSERT(composter.try_handle_adding_compost(stalks, farmer, TRUE), "The composter did not take stalks")
	TEST_ASSERT_EQUAL(composter.unflipped_compost, rogue_value("farm_compost_food"), "Stalks gave the wrong compost")
	composter.flip_compost()
	TEST_ASSERT_EQUAL(composter.flipped_compost, rogue_value("farm_compost_food"), "Flipping did not turn the compost")
	composter.process(60)
	TEST_ASSERT(composter.ready_compost > 0, "Flipped compost did not rot")
	composter.ready_compost = rogue_value("farm_compost_per_item")
	TEST_ASSERT(istype(composter.take_out_compost(), /obj/item/compost), "No compost came out of a composter with enough ready")
	var/obj/item/natural/chaff/wheat/more_stalks = allocate(/obj/item/natural/chaff/wheat, run_loc_floor_top_right)
	more_stalks.thresh()
	TEST_ASSERT(QDELETED(more_stalks), "Threshed stalks stayed")
	TEST_ASSERT(locate(/obj/item/reagent_containers/food/snacks/grown/wheat) in run_loc_floor_top_right, "Threshing gave no grain")
	TEST_ASSERT(locate(/obj/item/natural/fibers) in run_loc_floor_top_right, "Threshing gave no fiber")

/// A hoe tills grass into dirt, dirt into soil and soil again.
/datum/unit_test/rogue_farming_tilling
	normal_floor_required = TRUE

/datum/unit_test/rogue_farming_tilling/Run()
	var/mob/living/carbon/human/consistent/farmer = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/turf/tile = run_loc_floor_bottom_left
	tile.ChangeTurf(/turf/open/floor/rogue/grass)
	TEST_ASSERT(rogue_till_tile(tile, farmer), "A hoe did not till grass")
	TEST_ASSERT(istype(tile, /turf/open/floor/rogue/dirt), "Tilled grass did not turn to dirt")
	TEST_ASSERT(rogue_till_tile(tile, farmer), "A hoe did not till dirt")
	var/obj/structure/soil/soil = locate() in tile
	TEST_ASSERT(soil, "Tilled dirt made no soil")
	TEST_ASSERT(rogue_till_tile(tile, farmer), "A hoe did not till the soil")
	TEST_ASSERT(soil.tilled_time > 0, "Tilling the soil did not till it")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
