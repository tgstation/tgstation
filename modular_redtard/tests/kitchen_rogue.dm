#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's chicken stews mend wounds (survival/soups.dm, rogue_heal_wounds()) and coffee gives the Vigorized buff. The test map
/// is not a medieval one, so the patient is given the blood element by hand.
/datum/unit_test/rogue_stews_and_coffee

/datum/unit_test/rogue_stews_and_coffee/Run()
	var/mob/living/carbon/human/consistent/patient = allocate(__IMPLIED_TYPE__)
	patient.AddElement(/datum/element/rogue_blood)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	patient.apply_damage(15, BRUTE, arm, wound_bonus = 100, sharpness = SHARP_EDGED)
	var/datum/wound/rogue/dynamic/slash/slash = arm.get_wound_type(/datum/wound/rogue/dynamic/slash)
	TEST_ASSERT(slash, "A cut did not open a slash")
	var/health = slash.rogue_health
	patient.reagents.add_reagent(/datum/reagent/consumable/soup/stew/lavishchicken, 10)
	patient.reagents.metabolize(patient, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(QDELETED(slash) || slash.rogue_health < health, "Lavish frybird stew did not mend the slash")
	var/datum/reagent/consumable/soup/stew/plain = /datum/reagent/consumable/soup/stew/meat
	TEST_ASSERT_EQUAL(initial(plain.rogue_wound_heal), 0, "A meat stew mends wounds, Ratwood's only chicken stews do")
	patient.reagents.clear_reagents()
	patient.reagents.add_reagent(/datum/reagent/consumable/caffeine/coffee, 5)
	patient.reagents.metabolize(patient, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(patient.has_status_effect(/datum/status_effect/rogue_vigorized), "Coffee did not vigorize")

/// The night fatigue (survival/fatigue.dm) shows the dream bank's tiredness: a status a step, the third one slowing the feet;
/// a night owl does not tire at night; coffee lifts the fatigue.
/datum/unit_test/rogue_night_fatigue

/datum/unit_test/rogue_night_fatigue/Run()
	var/mob/living/carbon/human/consistent/sleeper = allocate(__IMPLIED_TYPE__)
	var/datum/component/rogue_dreams/dreams = sleeper.AddComponent(/datum/component/rogue_dreams)
	dreams.grow_tired()
	TEST_ASSERT_EQUAL(sleeper.rogue_fatigue_stage(), 1, "A night did not tire")
	TEST_ASSERT(!sleeper.has_movespeed_modifier(/datum/movespeed_modifier/rogue_exhausted), "One night's tiredness slows the feet")
	dreams.grow_tired()
	dreams.grow_tired()
	dreams.grow_tired()
	TEST_ASSERT_EQUAL(sleeper.rogue_fatigue_stage(), 3, "Night fatigue does not stop at its third step")
	TEST_ASSERT(sleeper.has_movespeed_modifier(/datum/movespeed_modifier/rogue_exhausted), "Exhaustion does not slow the feet")
	dreams.tiredness = 2
	dreams.rogue_sync_fatigue()
	TEST_ASSERT_EQUAL(sleeper.rogue_fatigue_stage(), 2, "The fatigue status did not follow the dream bank down")
	TEST_ASSERT(!sleeper.has_movespeed_modifier(/datum/movespeed_modifier/rogue_exhausted), "A lifted exhaustion still slows the feet")
	sleeper.rogue_coffee_wakes(rogue_value("survival_coffee_fatigued"), 1)
	TEST_ASSERT_EQUAL(sleeper.rogue_fatigue_stage(), 0, "Enough coffee did not lift two nights' fatigue")
	TEST_ASSERT_EQUAL(dreams.tiredness, 0, "Coffee left the dream bank tired")
	ADD_TRAIT(sleeper, TRAIT_NIGHT_OWL, TRAIT_GENERIC)
	dreams.grow_tired()
	TEST_ASSERT_EQUAL(dreams.tiredness, 0, "A night owl tired at night")
	dreams.rogue_owl_tires()
	TEST_ASSERT_EQUAL(sleeper.rogue_fatigue_stage(), 1, "A night owl did not tire by day")

/// Ratwood's dishes without items in block 1 (survival/kneading.dm): the missing handpies, the spider pie for an Underdark
/// Chef only, the pumpkin pie, the maturing of a cheese wheel.
/datum/unit_test/rogue_dishes

/datum/unit_test/rogue_dishes/Run()
	var/mob/living/carbon/human/consistent/cook = allocate(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/food/snacks/rogue/piedough/dough = allocate(__IMPLIED_TYPE__)
	var/list/fillings = list(
		/obj/item/reagent_containers/food/snacks/rogue/truffles = /obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/mushroom,
		/obj/item/reagent_containers/food/snacks/rogue/meat/crab = /obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/crab,
		/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison = /obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/berry,
		/obj/item/reagent_containers/food/snacks/grown/apple = /obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/apple,
		/obj/item/reagent_containers/food/snacks/rogue/veg/potato_sliced = /obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/potato,
		/obj/item/reagent_containers/food/snacks/grown/cabbage/rogue = /obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw/cabbage,
	)
	for(var/filling_type in fillings)
		var/obj/item/filling = allocate(filling_type)
		var/datum/rogue_food_recipe/recipe = rogue_food_recipe_for(dough, filling)
		TEST_ASSERT_EQUAL(recipe?.result_type, fillings[filling_type], "[filling_type] in piedough makes no handpie of its own")
	var/obj/item/reagent_containers/food/snacks/rogue/foodbase/piebottom/bottom = allocate(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/food/snacks/rogue/meat/mince/spider/mince = allocate(__IMPLIED_TYPE__)
	var/datum/rogue_food_recipe/spider_pie = rogue_food_recipe_for(bottom, mince)
	TEST_ASSERT(istype(spider_pie, /datum/rogue_food_recipe/pie/spider), "Spidermeat in a pie bottom starts no spider pie")
	TEST_ASSERT(!spider_pie.can_prepare(cook), "Anyone knows the underdark delicacy")
	ADD_TRAIT(cook, TRAIT_UNDERDARK_CHEF, TRAIT_GENERIC)
	TEST_ASSERT(spider_pie.can_prepare(cook), "An Underdark Chef cannot make a spider pie")
	var/obj/item/reagent_containers/food/snacks/rogue/preserved/pumpkin_mashed/pumpkin = allocate(__IMPLIED_TYPE__)
	var/datum/rogue_food_recipe/pumpkin_pie = rogue_food_recipe_for(bottom, pumpkin)
	TEST_ASSERT(istype(pumpkin_pie, /datum/rogue_food_recipe/pie/pumpkin), "Mashed pumpkin in a pie bottom starts no pumpkin pie")
	TEST_ASSERT_EQUAL(length(pumpkin_pie.ingredients), 4, "The pumpkin pie does not take pumpkin, cheese, an egg and sugar")
	var/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel/wheel = allocate(__IMPLIED_TYPE__)
	var/turf/spot = get_turf(wheel)
	wheel.rogue_cheese_matured()
	TEST_ASSERT(QDELETED(wheel), "The matured wheel did not give way to the cheese")
	var/obj/item/reagent_containers/food/snacks/rogue/cheddar/cheddar = locate() in spot
	TEST_ASSERT(cheddar, "A matured wheel made no wheel of cheese")
	var/obj/item/natural/cloth/cloth = locate() in spot
	TEST_ASSERT(cloth, "A matured wheel did not give the cloth back")
	qdel(cheddar)
	qdel(cloth)
	var/list/tastes = rogue_palate_names(/obj/item/reagent_containers/food/snacks/rogue/cheese, /datum/reagent/consumable/caffeine/coffee)
	TEST_ASSERT_EQUAL(length(tastes), 2, "A servant does not name both the favourite food and drink")
	TEST_ASSERT_EQUAL(length(rogue_palate_names(null, null)), 0, "A servant names tastes the noble has none of")

/// The kiln's pottery (crafting/kiln_quality.dm): named at the low tiers too, worth the kiln's factor, and shattering when thrown.
/datum/unit_test/rogue_fired_pottery

/datum/unit_test/rogue_fired_pottery/Run()
	var/obj/item/reagent_containers/glass/cup/claycup/cup = allocate(__IMPLIED_TYPE__)
	cup.rogue_quality = ROGUE_POTTERY_QUALITY(0)
	cup.sellprice = 20
	cup.static_price = TRUE
	cup.rogue_apply_kiln_quality(0)
	TEST_ASSERT(findtext(cup.name, "crude ") == 1, "Crude fired pottery is not named so: [cup.name]")
	TEST_ASSERT_EQUAL(cup.get_real_price(), round(20 * rogue_value("survival_kiln_price_crude")), "Crude fired pottery is not worth the kiln's factor")
	TEST_ASSERT(cup.rogue_pottery_fragile, "Fired pottery is not fragile")
	var/turf/spot = get_turf(cup)
	cup.throw_impact(spot, null)
	TEST_ASSERT(QDELETED(cup), "A thrown fragile cup did not shatter")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
