#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's thirst (survival/thirst.dm): the step of thirst follows the hydration with its status, water quenches and salt
/// water dries out. The test map is not a medieval one, so the drinker is given the thirst element by hand.
/datum/unit_test/rogue_thirst

/datum/unit_test/rogue_thirst/Run()
	var/mob/living/carbon/human/consistent/drinker = allocate(__IMPLIED_TYPE__)
	drinker.AddElement(/datum/element/rogue_thirst)
	TEST_ASSERT_NOTNULL(drinker.rogue_hydration, "The thirst element gave no hydration")
	drinker.rogue_set_hydration(500)
	TEST_ASSERT_EQUAL(drinker.rogue_thirst_stage, 1, "500 hydration is not a little thirsty")
	TEST_ASSERT(drinker.has_status_effect(/datum/status_effect/rogue_thirst), "A little thirst shows no status")
	drinker.rogue_set_hydration(50)
	TEST_ASSERT_EQUAL(drinker.rogue_thirst_stage, 3, "50 hydration is not parched")
	TEST_ASSERT(istype(drinker.has_status_effect(/datum/status_effect/rogue_thirst), /datum/status_effect/rogue_thirst/parched), "Parched shows the wrong status")
	drinker.reagents.add_reagent(/datum/reagent/water, 10)
	drinker.reagents.metabolize(drinker, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(drinker.rogue_hydration > 50, "Water did not quench thirst")
	drinker.rogue_set_hydration(800)
	TEST_ASSERT_EQUAL(drinker.rogue_thirst_stage, 0, "800 hydration is still thirsty")
	TEST_ASSERT(!drinker.has_status_effect(/datum/status_effect/rogue_thirst), "A quenched thirst still shows")
	drinker.reagents.clear_reagents()
	var/before = drinker.rogue_hydration
	drinker.reagents.add_reagent(/datum/reagent/water/salt, 10)
	drinker.reagents.metabolize(drinker, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(drinker.rogue_hydration < before, "Salt water did not dry the drinker out")
	var/datum/reagent/consumable/soup/porridge/oats = /datum/reagent/consumable/soup/porridge/oatmeal
	TEST_ASSERT(initial(oats.rogue_hydration_tick) < 6, "Porridge quenches as much as a broth")

/// Ratwood's water (rockhill/swimming.dm, survival/washing.dm): cold water chills a wader, a swimmer at the shore swims for
/// free while a stroke costs stamina by Swimming, washing cleans a thing, and a bog leech takes hold of a limb.
/datum/unit_test/rogue_swimming
	normal_floor_required = TRUE

/datum/unit_test/rogue_swimming/Run()
	var/turf/open/water/river/river = run_loc_floor_bottom_left.ChangeTurf(/turf/open/water/river)
	var/mob/living/carbon/human/consistent/swimmer = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	TEST_ASSERT(river.rogue_swim, "A river is not deep enough to swim")
	swimmer.bodytemperature = BODYTEMP_NORMAL
	river.rogue_wade(swimmer)
	TEST_ASSERT(swimmer.bodytemperature < BODYTEMP_NORMAL, "Cold river water did not chill the wader")
	TEST_ASSERT_EQUAL(river.rogue_swim_drain(swimmer, NORTH), 0, "A swimmer by the shore spent stamina")
	var/unskilled = swimmer.rogue_swim_cost()
	TEST_ASSERT_EQUAL(unskilled, rogue_value("swim_drain"), "An unskilled swimmer without armour does not spend the base stamina")
	swimmer.rogue_set_skill(/datum/attribute/skill/misc/swimming, 3 * ROGUE_SKILL_PER_RANK)
	TEST_ASSERT(swimmer.rogue_swim_cost() < unskilled, "Swimming did not make the strokes cheaper")

	var/obj/item/knife/kitchen/knife = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	knife.add_blood_DNA(swimmer.get_blood_dna_list())
	TEST_ASSERT(GET_ATOM_BLOOD_DNA_LENGTH(knife), "The knife did not get bloody")
	river.rogue_item_washed(knife, swimmer)
	TEST_ASSERT(!GET_ATOM_BLOOD_DNA_LENGTH(knife), "Washing in the river did not clean the knife")

	var/obj/item/natural/worms/leech/leech = rogue_set_wild_leech(swimmer, list(BODY_ZONE_CHEST))
	TEST_ASSERT_NOTNULL(leech, "No bog leech took hold")
	var/obj/item/bodypart/chest = swimmer.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(leech in chest.rogue_leeches, "The bog leech is not on the chest")

/// Ratwood's relaxing bath (survival/washing.dm): a soak heals, and a long enough soak lifts a night's fatigue.
/datum/unit_test/rogue_relaxing_bath

/datum/unit_test/rogue_relaxing_bath/Run()
	var/mob/living/carbon/human/consistent/bather = allocate(__IMPLIED_TYPE__)
	var/datum/component/rogue_dreams/dreams = bather.AddComponent(/datum/component/rogue_dreams)
	dreams.tiredness = 1
	dreams.rogue_sync_fatigue()
	var/list/soak = list("count" = rogue_value("bath_soak_goal") - 1, "first" = TRUE, "rested" = FALSE)
	TEST_ASSERT(bather.rogue_bath_soak(soak, 1), "An unarmoured bather got nothing out of the soak")
	TEST_ASSERT(bather.has_status_effect(/datum/status_effect/rogue_miracle_heal), "The soak did not heal")
	TEST_ASSERT_EQUAL(dreams.tiredness, 0, "A long soak did not lift a night's fatigue")
	TEST_ASSERT_EQUAL(bather.rogue_fatigue_stage(), 0, "The lifted fatigue still shows")

/// Ratwood's fishing (rockhill/fishing.dm): bait is known, a water's catch is drawn, fish get a rarity with its name and look,
/// fish thrown into water swim off, and a baited crayfish cage set in water catches.
/datum/unit_test/rogue_fishing
	normal_floor_required = TRUE

/datum/unit_test/rogue_fishing/Run()
	var/obj/item/natural/worms/worm = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NOTNULL(rogue_bait_data(worm), "A worm is no bait")
	var/obj/item/knife/kitchen/knife = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(rogue_bait_data(knife), "A knife is bait")
	var/turf/open/water/river/river_type = /turf/open/water/river
	var/fresh = initial(river_type.rogue_fish_waters)
	TEST_ASSERT_NOTNULL(fresh, "A river has no catch")
	var/list/fresh_catch = GLOB.rogue_catch_tables[fresh]
	TEST_ASSERT(fresh_catch[/obj/item/reagent_containers/food/snacks/fish/sunny], "The sunny is not in the river's catch")
	var/caught = rogue_pick_catch(fresh, rogue_bait_data(worm))
	TEST_ASSERT(caught in fresh_catch, "A river gave a catch not of its own")

	var/obj/item/reagent_containers/food/snacks/fish/crab/crab = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(findtext(crab.icon_state, "crab") == 1, "A crab is not drawn by its rarity ([crab.icon_state])")
	TEST_ASSERT(findtext(crab.name, " crab"), "A crab has no rarity in its name ([crab.name])")
	var/obj/item/reagent_containers/food/snacks/fish/sole/sole = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_EQUAL(sole.icon_state, "sole", "A sole lost its own sprite")

	var/turf/open/water/river/river = run_loc_floor_bottom_left.ChangeTurf(/turf/open/water/river)
	var/obj/item/reagent_containers/food/snacks/fish/sunny/released = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	released.forceMove(river)
	TEST_ASSERT(QDELETED(released), "A fish put into water did not swim off")

	var/obj/item/fishingcage/cage = allocate(__IMPLIED_TYPE__, river)
	cage.rogue_deployed = TRUE
	worm.forceMove(cage)
	cage.rogue_bait_cage(worm, 0)
	cage.rogue_catch_at = 0
	cage.process(SSOBJ_DT)
	TEST_ASSERT_NOTNULL(cage.rogue_caught, "A baited cage in the water caught nothing")
	TEST_ASSERT_NULL(cage.rogue_cage_bait, "The cage kept its bait after the catch")

/// Ratwood's wood bins (survival/vessels.dm): a water bin holds water, a wash leaves it dirty, rain fills a standing bin and a
/// kick's fall empties it; a trash bin holds none.
/datum/unit_test/rogue_wood_bins

/datum/unit_test/rogue_wood_bins/Run()
	var/obj/item/roguebin/water/bin = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(bin.reagents?.has_reagent(/datum/reagent/water, rogue_value("bin_start_water")), "A water bin came without its water")
	TEST_ASSERT(bin.rogue_take_wash_water(), "A water bin had no water for a wash")
	bin.rogue_dirty_water()
	TEST_ASSERT(!bin.reagents.has_reagent(/datum/reagent/water), "Washing left clean water in the bin")
	TEST_ASSERT(bin.reagents.has_reagent(/datum/reagent/water/gross), "Washing did not dirty the bin's water")
	bin.rogue_catch_rain(10)
	TEST_ASSERT(bin.reagents.has_reagent(/datum/reagent/water), "Rain did not fill the bin")
	bin.rogue_tip_over()
	TEST_ASSERT(bin.rogue_tipped, "The bin did not fall")
	TEST_ASSERT_EQUAL(bin.reagents.total_volume, 0, "A fallen bin kept its water")
	bin.rogue_catch_rain(10)
	TEST_ASSERT_EQUAL(bin.reagents.total_volume, 0, "Rain filled a fallen bin")
	var/obj/item/roguebin/trash/trash = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(trash.reagents, "A trash bin holds water")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
