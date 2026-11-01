#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// A Ratwood brew (alchemy/alcohol.dm) makes one as drunk a tick as Ratwood does (sqrt(volume) x boozepwr x ALCOHOL_RATE),
/// takes none of TG's addiction, and enough of it leaves one Drunk; emberwine lies dormant before it is spent.
/datum/unit_test/rogue_alcohol

/datum/unit_test/rogue_alcohol/Run()
	var/mob/living/carbon/human/consistent/drinker = allocate(__IMPLIED_TYPE__)
	drinker.reagents.add_reagent(/datum/reagent/consumable/ethanol/cider, 16)
	var/datum/reagent/consumable/ethanol/cider = drinker.reagents.has_reagent(/datum/reagent/consumable/ethanol/cider)
	TEST_ASSERT(cider?.rogue_brew, "Ratwood's cider is not a Ratwood brew")
	TEST_ASSERT(!length(cider.addiction_types), "A Ratwood brew carries TG's addiction to drink")
	drinker.reagents.metabolize(drinker, SSMOBS_DT, can_overdose = TRUE)
	var/expected = sqrt(16) * 40 * ALCOHOL_RATE
	TEST_ASSERT(abs(drinker.get_drunk_amount() - expected) < 0.01, "A tick of 16 units of cider made one [drinker.get_drunk_amount()] drunk, Ratwood makes one [expected] drunk")
	TEST_ASSERT(!drinker.has_status_effect(/datum/status_effect/rogue_intoxicant/drunk), "A little cider already left one Drunk")
	drinker.reagents.add_reagent(/datum/reagent/consumable/ethanol/aqua_vitae, 100)
	drinker.reagents.metabolize(drinker, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(drinker.has_status_effect(/datum/status_effect/rogue_intoxicant/drunk), "Aqua vitae did not leave one Drunk")
	drinker.reagents.clear_reagents()
	drinker.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer/emberwine, 5)
	drinker.reagents.metabolize(drinker, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(drinker.reagents.has_reagent(/datum/reagent/consumable/ethanol/beer/emberwine, 5), "Dormant emberwine was spent")
	var/datum/reagent/emberwine = drinker.reagents.has_reagent(/datum/reagent/consumable/ethanol/beer/emberwine)
	emberwine.current_cycle = 19
	drinker.reagents.metabolize(drinker, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(emberwine.metabolization_rate > 0, "Emberwine did not wake after its dormant cycles")

/// Ratwood's drugs (alchemy/drugs.dm) give their highs, and a powder is sniffed whole into the blood.
/datum/unit_test/rogue_drugs

/datum/unit_test/rogue_drugs/Run()
	var/mob/living/carbon/human/consistent/user = allocate(__IMPLIED_TYPE__)
	user.reagents.add_reagent(/datum/reagent/ozium, 5)
	user.reagents.metabolize(user, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(user.has_status_effect(/datum/status_effect/rogue_intoxicant/ozium), "Ozium gave no high")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_NOPAIN), "Ozium did not take the pain away")
	user.reagents.clear_reagents()
	user.reagents.add_reagent(/datum/reagent/starsugar, 5)
	user.reagents.metabolize(user, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(user.has_status_effect(/datum/status_effect/rogue_intoxicant/starsugar), "Starsugar gave no high")
	TEST_ASSERT(user.has_movespeed_modifier(/datum/movespeed_modifier/reagent/rogue_starsugar), "Starsugar did not quicken the feet")
	user.reagents.clear_reagents()
	TEST_ASSERT(!user.has_movespeed_modifier(/datum/movespeed_modifier/reagent/rogue_starsugar), "Spent starsugar still quickens the feet")
	var/obj/item/reagent_containers/powder/ozium/powder = allocate(__IMPLIED_TYPE__)
	powder.reagents.clear_reagents()
	powder.reagents.add_reagent(/datum/reagent/ozium, 5)
	user.put_in_active_hand(powder)
	powder.rogue_sniff_powder(user, user)
	TEST_ASSERT(QDELETED(powder), "A sniffed powder was left")
	TEST_ASSERT(user.reagents.has_reagent(/datum/reagent/ozium), "A sniffed powder did not get into the blood")

/// The rot of the cauldron infects one who can turn and is gone; cursed water wearies the living but not the undead.
/datum/unit_test/rogue_rot_and_cursed_water

/datum/unit_test/rogue_rot_and_cursed_water/Run()
	var/mob/living/carbon/human/consistent/victim = allocate(__IMPLIED_TYPE__)
	victim.mind_initialize()
	victim.reagents.add_reagent(/datum/reagent/deaditerot, 1)
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/rogue_deadite_rot), "The rot did not infect")
	TEST_ASSERT(!victim.reagents.has_reagent(/datum/reagent/deaditerot), "The rot stayed in the blood")
	victim.reagents.add_reagent(/datum/reagent/water/cursed, 10)
	victim.reagents.metabolize(victim, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT(victim.get_stamina_loss() > 0, "Cursed water did not weary the living")
	victim.reagents.clear_reagents()
	victim.set_stamina_loss(0)
	victim.mob_biotypes |= MOB_UNDEAD
	victim.reagents.add_reagent(/datum/reagent/water/cursed, 10)
	victim.reagents.metabolize(victim, SSMOBS_DT, can_overdose = TRUE)
	TEST_ASSERT_EQUAL(victim.get_stamina_loss(), 0, "Cursed water wearied the undead")

/// The keg (survival/brewing.dm) brews wheat beer from wheat and water, bottles it, and a fruit wine ages in it.
/datum/unit_test/rogue_keg

/datum/unit_test/rogue_keg/Run()
	var/mob/living/carbon/human/consistent/brewer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/fermentation_keg/keg = allocate(__IMPLIED_TYPE__)
	keg.selected_recipe = new /datum/brewing_recipe/beer
	TEST_ASSERT(!keg.try_n_brew(brewer), "An empty keg would brew")
	keg.reagents.add_reagent(/datum/reagent/water, 198)
	for(var/i in 1 to 6)
		var/obj/item/wheat = allocate(/obj/item/reagent_containers/food/snacks/grown/wheat)
		TEST_ASSERT(keg.rogue_stock(brewer, wheat), "The keg did not take wheat for its beer")
	TEST_ASSERT(keg.try_n_brew(brewer), "Six wheat and the water did not make a brew")
	keg.start_brew()
	TEST_ASSERT(keg.brewing, "The brew did not start")
	TEST_ASSERT(!keg.reagents.total_volume, "The brew left the water in the keg")
	TEST_ASSERT(keg.brew_timer, "The brew has no end")
	deltimer(keg.brew_timer)
	keg.end_brew()
	TEST_ASSERT(keg.ready_to_bottle, "The finished brew does not wait to be bottled")
	var/turf/spot = get_turf(keg)
	TEST_ASSERT(keg.bottle(brewer, "brew_red_bottle"), "The finished brew could not be bottled")
	var/bottles = 0
	for(var/obj/item/reagent_containers/glass/bottle/brewing_bottle/bottle in spot)
		bottles++
		TEST_ASSERT(bottle.reagents.has_reagent(/datum/reagent/consumable/ethanol/beer, 50), "A bottle of wheat beer holds no beer")
		qdel(bottle)
	TEST_ASSERT_EQUAL(bottles, 6, "Wheat beer did not fill its six bottles")
	TEST_ASSERT_NULL(keg.selected_recipe, "The bottled keg kept its recipe")
	keg.selected_recipe = new /datum/brewing_recipe/jack_wine
	keg.ready_to_bottle = TRUE
	keg.age_start_time = world.time - 11 MINUTES
	TEST_ASSERT_EQUAL(keg.rogue_brewed_reagent(), /datum/reagent/consumable/ethanol/jackberrywine/aged, "Jackberry wine did not age")
	TEST_ASSERT(keg.rogue_can_pick(/datum/brewing_recipe/brandy/strawberry) == FALSE, "Brandy was offered on jackberry wine")

/// Reading a vessel (alchemy/reagent_sight.dm): an alchemist from Apprentice reads it reagent by reagent, the unskilled reads
/// TG's line; Ratwood's pestle grinds in the mortar as TG's does.
/datum/unit_test/rogue_reagent_sight

/datum/unit_test/rogue_reagent_sight/Run()
	var/mob/living/carbon/human/consistent/viewer = allocate(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/glass/bottle/vial = allocate(__IMPLIED_TYPE__)
	vial.AddElement(/datum/element/rogue_reagent_sight)
	vial.reagents.add_reagent(/datum/reagent/medicine/healthpot, 10)
	var/list/lines = vial.examine(viewer)
	TEST_ASSERT(!("It contains:" in lines), "An unskilled viewer read the vessel reagent by reagent")
	viewer.rogue_set_skill(ROGUE_ALCHEMY_SKILL, ROGUE_RANK_APPRENTICE * ROGUE_SKILL_PER_RANK)
	lines = vial.examine(viewer)
	TEST_ASSERT("It contains:" in lines, "An apprentice alchemist did not read the vessel")
	var/obj/item/reagent_containers/glass/mortar/mortar = allocate(__IMPLIED_TYPE__)
	var/obj/item/pestle/rogue/pestle = allocate(__IMPLIED_TYPE__)
	viewer.put_in_active_hand(pestle)
	TEST_ASSERT_EQUAL(mortar.item_interaction(viewer, pestle), ITEM_INTERACT_SUCCESS, "The mortar does not take Ratwood's pestle")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
