#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood butcher() (husbandry/butchering.dm): botches below Journeyman and fewer the better the butcher, perfect cuts from Journeyman
/// on; a botch yields the botched amount of a kind or none, a perfect cut the perfect amount, and every cut takes its kind off the carcass.
/datum/unit_test/rogue_butchering

/datum/unit_test/rogue_butchering/Run()
	TEST_ASSERT_EQUAL(rogue_butcher_botch_chance(ROGUE_RANK_NONE), rogue_value("butcher_botch_chance"), "An unskilled butcher does not botch at Ratwood's chance")
	TEST_ASSERT(rogue_butcher_botch_chance(ROGUE_RANK_APPRENTICE) < rogue_butcher_botch_chance(ROGUE_RANK_NOVICE), "A better butcher botches as often")
	TEST_ASSERT_EQUAL(rogue_butcher_botch_chance(ROGUE_RANK_JOURNEYMAN), 0, "A Journeyman still botches cuts")
	TEST_ASSERT_EQUAL(rogue_butcher_perfect_chance(ROGUE_RANK_APPRENTICE), 0, "An Apprentice makes perfect cuts")
	TEST_ASSERT_EQUAL(rogue_butcher_perfect_chance(ROGUE_RANK_JOURNEYMAN), rogue_value("butcher_perfect_journeyman"), "A Journeyman's perfect cuts are not Ratwood's")
	TEST_ASSERT_EQUAL(rogue_butcher_perfect_chance(ROGUE_RANK_LEGENDARY), rogue_value("butcher_perfect_master"), "A legendary butcher's cuts are not all perfect")
	var/mob/living/simple_animal/hostile/retaliate/rogue/cow/cow = allocate(__IMPLIED_TYPE__)
	cow.death()
	var/steak = /obj/item/reagent_containers/food/snacks/rogue/meat/steak
	var/hide = /obj/item/natural/hide
	var/sinew = /obj/item/alch/sinew
	var/bones = /obj/item/natural/bundle/bone/full
	TEST_ASSERT(cow.rogue_butcher_results[steak], "The porter's cow yields no steaks")
	TEST_ASSERT_EQUAL(cow.rogue_cut_off(steak, 100, 0), "botched", "A sure botch was not botched")
	TEST_ASSERT_EQUAL(count_cuts(cow.loc, steak), cow.rogue_botched_butcher_results[steak], "A botched cut did not yield the botched steaks")
	TEST_ASSERT(!(steak in cow.rogue_butcher_results), "The steaks stayed on the carcass after their cut")
	TEST_ASSERT_EQUAL(cow.rogue_cut_off(hide, 100, 0), "botched", "A sure botch was not botched")
	TEST_ASSERT_EQUAL(count_cuts(cow.loc, hide), 0, "A botched cut of what the botched yield lacks still gave it")
	TEST_ASSERT_EQUAL(cow.rogue_cut_off(sinew, 0, 100), "perfect", "A sure perfect cut was not perfect")
	TEST_ASSERT_EQUAL(count_cuts(cow.loc, sinew), cow.rogue_perfect_butcher_results[sinew], "A perfect cut did not yield the perfect sinews")
	var/usual = cow.rogue_butcher_results[bones]
	TEST_ASSERT_EQUAL(cow.rogue_cut_off(bones, 0, 0), "normal", "A plain cut was not a normal one")
	TEST_ASSERT_EQUAL(count_cuts(cow.loc, bones), usual, "A normal cut did not yield the usual bones")

/// How many things of exactly this type lie here.
/datum/unit_test/rogue_butchering/proc/count_cuts(turf/here, path)
	. = 0
	for(var/atom/movable/thing as anything in here)
		if(thing.type == path)
			.++

/// Ratwood's meathook: a carcass hung on it yields a piece more of every food, and a piece less once it is taken down.
/datum/unit_test/rogue_meathook

/datum/unit_test/rogue_meathook/Run()
	var/obj/structure/meathook/hook = allocate(__IMPLIED_TYPE__)
	var/mob/living/simple_animal/hostile/retaliate/rogue/cow/cow = allocate(__IMPLIED_TYPE__)
	cow.death()
	var/steak = /obj/item/reagent_containers/food/snacks/rogue/meat/steak
	var/hide = /obj/item/natural/hide
	var/steaks = cow.rogue_butcher_results[steak]
	var/hides = cow.rogue_butcher_results[hide]
	TEST_ASSERT(hook.buckle_mob(cow, force = TRUE), "The carcass could not be hung on the hook")
	TEST_ASSERT_EQUAL(cow.rogue_butcher_results[steak], steaks + rogue_value("meathook_meat_bonus"), "The hook did not give more meat")
	TEST_ASSERT_EQUAL(cow.rogue_butcher_results[hide], hides, "The hook gave more of what is not food")
	hook.unbuckle_mob(cow, force = TRUE)
	TEST_ASSERT_EQUAL(cow.rogue_butcher_results[steak], steaks, "The extra meat stayed with a carcass taken down")

/// Ratwood's hive (husbandry/apiary.dm): a queen sets the colony's size, the bees at home work pollen into honeycombs that come out
/// as honey, and a disease that runs its course kills the colony and its queen.
/datum/unit_test/rogue_apiary

/datum/unit_test/rogue_apiary/Run()
	var/obj/structure/apiary/hive = allocate(__IMPLIED_TYPE__)
	var/obj/item/queen_bee/queen = allocate(__IMPLIED_TYPE__)
	queen.rogue_efficiency = 1
	hive.rogue_insert_queen(queen, quiet = TRUE)
	TEST_ASSERT_EQUAL(hive.rogue_queen, queen, "The queen did not settle in the hive")
	TEST_ASSERT_EQUAL(queen.loc, hive, "The queen is not inside the hive")
	TEST_ASSERT(hive.rogue_max_bees > rogue_value("apiary_max_bees"), "The queen did not let the colony grow")
	hive.rogue_bees = 10
	hive.rogue_pollen = rogue_value("apiary_comb_work") * 2
	for(var/tick in 1 to 100)
		hive.rogue_work_pollen()
	TEST_ASSERT(hive.rogue_combs >= 1, "The bees made no honeycomb of their pollen")
	TEST_ASSERT_EQUAL(hive.rogue_pollen, 0, "The bees did not work all their pollen")
	var/combs = hive.rogue_combs
	var/list/honey = hive.rogue_spill_honey()
	TEST_ASSERT_EQUAL(length(honey), combs, "Every honeycomb did not come out")
	TEST_ASSERT(istype(honey[1], /obj/item/reagent_containers/food/snacks/rogue/honey), "A honeycomb came out as something else")
	TEST_ASSERT_EQUAL(hive.rogue_combs, 0, "The honeycombs stayed in the hive")
	hive.rogue_comb_progress = rogue_value("apiary_bee_cost")
	hive.rogue_raise_bee()
	TEST_ASSERT_EQUAL(hive.rogue_bees, 11, "Comb work raised no bee")
	hive.rogue_infect()
	TEST_ASSERT(hive.rogue_disease, "The hive did not fall sick")
	hive.rogue_disease_severity = 100
	hive.rogue_run_disease()
	TEST_ASSERT_EQUAL(hive.rogue_bees, 0, "A disease at its worst left bees alive")
	TEST_ASSERT(!hive.rogue_queen && QDELETED(queen), "A disease at its worst left the queen alive")
	TEST_ASSERT(!hive.rogue_disease, "The empty hive stayed sick")

/// Ratwood's bees: on a crop they pollinate its soil (farming's pollinate()), gather pollen and tell the hive what they visited, not
/// twice running; home, they bring the pollen in and rest before they count among the bees at home.
/datum/unit_test/rogue_bee_pollination

/datum/unit_test/rogue_bee_pollination/Run()
	var/obj/structure/apiary/hive = allocate(__IMPLIED_TYPE__)
	var/obj/structure/soil/soil = allocate(/obj/structure/soil, run_loc_floor_top_right)
	soil.insert_plant(GLOB.rogue_plant_defs[/datum/plant_def/poppy])
	var/obj/effect/rogue_bees/bees = allocate(/obj/effect/rogue_bees, run_loc_floor_top_right, hive, 2)
	TEST_ASSERT(bees in hive.rogue_bee_groups, "The bees are not of their hive")
	TEST_ASSERT(bees.try_pollinate(), "Bees on a crop did not pollinate it")
	bees.finish_pollinating()
	TEST_ASSERT(soil.pollination_time > 0, "The bees did not pollinate the soil")
	TEST_ASSERT(bees.pollen > 0, "The bees gathered no pollen")
	TEST_ASSERT_EQUAL(LAZYACCESS(hive.rogue_pollen_sources, /datum/plant_def/poppy), 1, "The hive does not know its bees visited the poppies")
	TEST_ASSERT(!bees.try_pollinate(), "The bees pollinated the same crop twice running")
	var/pollen = bees.pollen
	hive.rogue_bees_out = 2
	bees.enter_hive()
	TEST_ASSERT(QDELETED(bees), "The bees did not go into the hive")
	TEST_ASSERT_EQUAL(hive.rogue_pollen, pollen, "The bees did not bring their pollen home")
	TEST_ASSERT_EQUAL(hive.rogue_bees_asleep, 2, "The bees back home do not rest")
	hive.rogue_wake(2)
	TEST_ASSERT_EQUAL(hive.rogue_bees, 2, "Rested bees do not count among those at home")
	TEST_ASSERT(ispath(hive.rogue_honey_type(), /obj/item/reagent_containers/food/snacks/rogue/honey), "Poppy honey is not honey")

/// The small ways of Ratwood's beasts: a shove tips a cow over, a calf cannot be; an egg is crushed underfoot; any fed beast drops
/// manure unless its kind is clean; a caparison's pattern is drawn on the mount; a shooed tamed beast calls its own kind along.
/datum/unit_test/rogue_husbandry_details

/datum/unit_test/rogue_husbandry_details/Run()
	var/mob/living/carbon/human/consistent/farmer = allocate(__IMPLIED_TYPE__)
	var/mob/living/simple_animal/hostile/retaliate/rogue/cow/cow = allocate(__IMPLIED_TYPE__)
	cow.rogue_tip_over(farmer)
	TEST_ASSERT_EQUAL(cow.icon_state, "cow_tip", "A tipped cow does not lie on its side")
	TEST_ASSERT(cow.IsParalyzed(), "A tipped cow is not down")
	cow.SetParalyzed(0)
	cow.rogue_get_up()
	TEST_ASSERT_EQUAL(cow.icon_state, cow.icon_living, "The cow did not get up")
	var/mob/living/basic/rockhill/calf = /mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet
	TEST_ASSERT_NULL(initial(calf.rogue_tip_state), "A calf, which has no such look, can be tipped over")
	var/obj/item/reagent_containers/food/snacks/egg/egg = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	egg.rogue_crush(farmer)
	TEST_ASSERT(QDELETED(egg), "A crushed egg is still whole")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/food/egg_smudge) in run_loc_floor_top_right, "A crushed egg left no smudge")
	var/mob/living/basic/rockhill/troll = /mob/living/simple_animal/hostile/retaliate/rogue/troll
	TEST_ASSERT_EQUAL(initial(troll.rogue_manure_type), /obj/item/natural/poo/horse, "A fed troll drops nothing, as no Ratwood beast but the clean ones")
	var/mob/living/basic/rockhill/wolf = /mob/living/simple_animal/hostile/retaliate/rogue/wolf
	TEST_ASSERT_NULL(initial(wolf.rogue_manure_type), "A wolf drops manure, which Ratwood's does not")
	var/mob/living/simple_animal/hostile/retaliate/rogue/saiga/saiga = allocate(__IMPLIED_TYPE__)
	var/obj/item/caparison/cloth = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_EQUAL(length(cloth.rogue_tack_overlays(saiga, ROGUE_TACK_LOW_LAYER)), 2, "A plain caparison is not drawn in two parts")
	cloth.rogue_detail_state = "quad"
	TEST_ASSERT_EQUAL(length(cloth.rogue_tack_overlays(saiga, ROGUE_TACK_LOW_LAYER)), 4, "A caparison's pattern is not drawn over it")
	var/mob/living/simple_animal/hostile/retaliate/rogue/cow/kin = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(kin.ai_controller, "A cow has no mind to call")
	cow.rogue_set_upon_everyone()
	TEST_ASSERT(farmer in kin.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "A shooed cow did not call its kind on the farmer")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
