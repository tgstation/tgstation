#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Only one as strong as a door's kick threshold breaks its lock with kicks, and such a one always does once the lock is worn
/// through.
/datum/unit_test/rogue_doors_kick

/datum/unit_test/rogue_doors_kick/Run()
	var/mob/living/carbon/human/consistent/weakling = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/brute = allocate(__IMPLIED_TYPE__)
	brute.rogue_adjust_stat(ROGUE_STAT_STRENGTH, 10)
	var/obj/structure/mineral_door/rockhill/wood/door = allocate(__IMPLIED_TYPE__)
	door.keylock = TRUE
	door.locked = TRUE
	for(var/kick in 1 to 30)
		door.kick_lock(weakling)
	TEST_ASSERT(door.locked, "A weak kick broke the lock of a door")
	for(var/kick in 1 to initial(door.kickthresh))
		if(door.kick_lock(brute))
			break
	TEST_ASSERT(!door.locked, "Kicks of a strong one never broke the lock of a door")

/// A winch and a lever take longer for the weak and no time for the strong.
/datum/unit_test/rogue_doors_winch_lever

/datum/unit_test/rogue_doors_winch_lever/Run()
	var/mob/living/carbon/human/consistent/weakling = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/brute = allocate(__IMPLIED_TYPE__)
	weakling.rogue_adjust_stat(ROGUE_STAT_STRENGTH, -5)
	brute.rogue_adjust_stat(ROGUE_STAT_STRENGTH, 5)
	var/obj/structure/rockhill/winch/winch = allocate(__IMPLIED_TYPE__)
	var/obj/structure/lever/lever = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(winch.crank_time(weakling) > winch.crank_time(brute), "Strength does not speed up cranking a winch")
	TEST_ASSERT_EQUAL(winch.crank_time(brute), 0, "A strong one does not crank a winch at once")
	TEST_ASSERT(lever.pull_time(weakling) > lever.pull_time(brute), "Strength does not speed up pulling a lever")
	TEST_ASSERT_EQUAL(lever.pull_time(brute), 0, "A strong one does not pull a lever at once")

/// Mending a door takes its craft, the shorter the better one knows it; a broken door takes its first material, then its
/// second, and comes back shut and whole.
/datum/unit_test/rogue_doors_repair

/datum/unit_test/rogue_doors_repair/Run()
	var/mob/living/carbon/human/consistent/townsman = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/carpenter = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/master = allocate(__IMPLIED_TYPE__)
	carpenter.rogue_set_skill(/datum/attribute/skill/craft/carpentry, 1 * ROGUE_SKILL_PER_RANK)
	master.rogue_set_skill(/datum/attribute/skill/craft/carpentry, 4 * ROGUE_SKILL_PER_RANK)
	var/obj/structure/mineral_door/rockhill/wood/door = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(door.repair_time(townsman), "One with no carpentry can mend a wooden door")
	TEST_ASSERT_NOTNULL(door.repair_time(carpenter), "A carpenter cannot mend a wooden door")
	TEST_ASSERT(door.repair_time(master) < door.repair_time(carpenter), "Carpentry does not shorten mending a door")
	door.update_integrity(door.max_integrity * door.integrity_failure)
	door.atom_break(BRUTE)
	TEST_ASSERT(door.broken && !door.density, "A broken door still stands in the way")
	TEST_ASSERT_EQUAL(door.repair_material(), door.repair_cost_first, "A broken door does not start mending with its first material")
	door.repair_state = 1
	TEST_ASSERT_EQUAL(door.repair_material(), door.repair_cost_second, "A half mended door does not finish with its second material")
	door.fix_door()
	TEST_ASSERT(!door.broken && door.density, "A mended door stays broken")
	TEST_ASSERT_EQUAL(door.get_integrity(), door.max_integrity, "A mended door is not whole")

/// A try at a lock is likelier and shorter the better one picks locks, perception helps, a hard lock hinders.
/datum/unit_test/rogue_doors_lockpicking

/datum/unit_test/rogue_doors_lockpicking/Run()
	var/mob/living/carbon/human/consistent/novice = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/thief = allocate(__IMPLIED_TYPE__)
	thief.rogue_set_skill(/datum/attribute/skill/misc/lockpicking, 4 * ROGUE_SKILL_PER_RANK)
	var/obj/item/lockpick/lockpick = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(rockhill_pick_chance(thief, lockpick, 1) > rockhill_pick_chance(novice, lockpick, 1), "Lockpicking does not raise the chance of a try")
	TEST_ASSERT(rockhill_pick_time(thief, 1) < rockhill_pick_time(novice, 1), "Lockpicking does not shorten a try")
	TEST_ASSERT(rockhill_pick_step(thief) > rockhill_pick_step(novice), "Lockpicking does not move the pins further")
	var/novice_chance = rockhill_pick_chance(novice, lockpick, 1)
	novice.rogue_adjust_stat(ROGUE_STAT_PERCEPTION, 10)
	TEST_ASSERT(rockhill_pick_chance(novice, lockpick, 1) > novice_chance, "Perception does not help to pick a lock")
	TEST_ASSERT(rockhill_pick_chance(novice, lockpick, 3) < rockhill_pick_chance(novice, lockpick, 1), "A hard lock is no harder to pick")
	TEST_ASSERT(rockhill_pick_time(novice, 3) > rockhill_pick_time(novice, 1), "A try at a hard lock is no longer")

/// Keys and locks of one lock id share its hash; a custom key opens the custom lock of its number fitted to a door or chest
/// and no other, and the chest's own check by lock id agrees.
/datum/unit_test/rogue_doors_custom_locks

/datum/unit_test/rogue_doors_custom_locks/Run()
	var/mob/living/carbon/human/consistent/smith = allocate(__IMPLIED_TYPE__)
	var/obj/item/roguekey/house_key = allocate(/obj/item/roguekey)
	house_key.rockhill_set_lock("rogue_test_house", rockhill_lock_hash("rogue_test_house", TRUE))
	var/obj/structure/mineral_door/rockhill/wood/house = allocate(__IMPLIED_TYPE__)
	house.rockhill_set_lock("rogue_test_house", rockhill_lock_hash("rogue_test_house"))
	TEST_ASSERT_EQUAL(house.lockhash, house_key.lockhash, "A key and a door of one lock id got different hashes")
	TEST_ASSERT(rockhill_key_turns(house_key, house.lockhash, FALSE), "A key does not turn the lock of its id")

	var/obj/item/customblank/blank = allocate(__IMPLIED_TYPE__)
	blank.rockhill_set_custom_lock(5)
	var/obj/item/roguekey/key = blank.finish_key(smith)
	TEST_ASSERT(QDELETED(blank), "Finishing a blank left the blank")
	TEST_ASSERT(key.rockhill_custom, "A finished blank is not a custom key")
	var/obj/item/customlock/lock = allocate(__IMPLIED_TYPE__)
	lock.rockhill_set_custom_lock(5)
	lock.finish_lock(smith)
	var/obj/structure/mineral_door/rockhill/wood/door = allocate(__IMPLIED_TYPE__)
	door.keylock = FALSE
	TEST_ASSERT(lock.fit_to(smith, door), "A finished lock did not fit a door without a lock")
	TEST_ASSERT(door.keylock, "A door with a lock fitted has no keyhole")
	TEST_ASSERT(rockhill_key_turns(key, door.lockhash, FALSE), "A custom key does not turn the custom lock of its number")
	var/obj/item/roguekey/stranger = allocate(/obj/item/roguekey)
	stranger.rockhill_set_custom_lock(6)
	TEST_ASSERT(!rockhill_key_turns(stranger, door.lockhash, FALSE), "A custom key turns a lock of another number")

	var/obj/item/customlock/chest_lock = allocate(__IMPLIED_TYPE__)
	chest_lock.rockhill_set_lock(key.lockid, key.lockhash)
	chest_lock.finish_lock(smith)
	var/obj/structure/closet/crate/wooden/rockhill/chest = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(chest_lock.fit_to(smith, chest), "A finished lock did not fit a chest without a lock")
	TEST_ASSERT(rockhill_key_turns(key, chest.lockhash, TRUE), "A custom key does not turn the chest lock aligned to it")
	TEST_ASSERT(rockhill_key_fits(key, chest.lockid, TRUE), "The chest's check by lock id refuses the key of its lock")
	qdel(key)

/// The imprinter runs on an unfinished lock, takes in a key and gives its lock to a door, and turns a lock without its key.
/datum/unit_test/rogue_doors_lock_imprinter

/datum/unit_test/rogue_doors_lock_imprinter/Run()
	var/mob/living/carbon/human/consistent/artificer = allocate(__IMPLIED_TYPE__)
	var/obj/item/contraption/lock_imprinter/imprinter = allocate(__IMPLIED_TYPE__)
	var/obj/item/customlock/power = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(imprinter.insert_power(artificer, power), "An unfinished lock did not power the imprinter")
	TEST_ASSERT_EQUAL(imprinter.current_charge, rogue_value("imprinter_charges"), "The imprinter did not get its uses")
	var/obj/item/roguekey/key = allocate(/obj/item/roguekey)
	key.rockhill_set_lock("rogue_test_vault", rockhill_lock_hash("rogue_test_vault", TRUE))
	imprinter.store_key(artificer, key)
	imprinter.cycle_mode(artificer)
	TEST_ASSERT_EQUAL(imprinter.mode, "Imprinter", "A hammer did not turn the imprinter from Examiner to Imprinter")
	var/obj/structure/mineral_door/rockhill/wood/door = allocate(__IMPLIED_TYPE__)
	imprinter.imprint_lock(artificer, door)
	TEST_ASSERT_EQUAL(door.lockid, "rogue_test_vault", "The imprinted door did not get the key's lock id")
	TEST_ASSERT(rockhill_key_turns(key, door.lockhash, FALSE), "The stored key does not turn the imprinted door")
	TEST_ASSERT_EQUAL(imprinter.current_charge, rogue_value("imprinter_charges") - 1, "Imprinting did not spend a use")
	imprinter.cycle_mode(artificer)
	door.locked = FALSE
	imprinter.turn_lock(artificer, door)
	TEST_ASSERT(door.locked, "The imprinter in Unlocker mode did not lock a shut door")

/// Mending a window takes carpentry; a broken one takes a small log, then glass, and comes back glazed.
/datum/unit_test/rogue_doors_window_repair

/datum/unit_test/rogue_doors_window_repair/Run()
	var/mob/living/carbon/human/consistent/townsman = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/carpenter = allocate(__IMPLIED_TYPE__)
	carpenter.rogue_set_skill(/datum/attribute/skill/craft/carpentry, 2 * ROGUE_SKILL_PER_RANK)
	var/obj/structure/roguewindow/window = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(window.repair_time(townsman), "One with no carpentry can mend a window")
	TEST_ASSERT(window.repair_time(carpenter) < rogue_value("window_repair_time"), "Carpentry does not shorten mending a window")
	window.update_integrity(window.max_integrity * window.integrity_failure)
	window.atom_break(BRUTE)
	TEST_ASSERT(window.broken && !window.opacity, "A broken window is still whole")
	TEST_ASSERT_EQUAL(window.repair_material(), /obj/item/grown/log/tree/small, "A broken window does not start mending with a small log")
	window.repair_started = TRUE
	TEST_ASSERT_EQUAL(window.repair_material(), /obj/item/natural/glass, "A half mended window does not finish with glass")
	window.fix_window()
	TEST_ASSERT(!window.broken, "A mended window stays broken")
	TEST_ASSERT_EQUAL(window.get_integrity(), window.max_integrity, "A mended window is not whole")
	TEST_ASSERT_EQUAL(window.opacity, initial(window.opacity), "A mended window does not shut the view as before")

/// Hiding takes the less time the better one sneaks, and each spot words it its own way.
/datum/unit_test/rogue_doors_hiding

/datum/unit_test/rogue_doors_hiding/Run()
	var/mob/living/carbon/human/consistent/novice = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/sneak = allocate(__IMPLIED_TYPE__)
	sneak.rogue_set_skill(/datum/attribute/skill/misc/sneaking, ROGUE_SKILL_RANK_MAX * ROGUE_SKILL_PER_RANK)
	var/obj/structure/table/wood/rockhill/table = allocate(__IMPLIED_TYPE__)
	var/datum/component/rockhill_hiding_spot/spot = table.GetComponent(/datum/component/rockhill_hiding_spot)
	TEST_ASSERT_NOTNULL(spot, "One cannot hide under a table")
	TEST_ASSERT_EQUAL(spot.preposition, "under", "One does not hide under a table")
	TEST_ASSERT(spot.hide_time(novice) > spot.hide_time(sneak), "Sneaking does not speed up hiding")
	TEST_ASSERT_EQUAL(spot.hide_time(sneak), rogue_value("hiding_time_min"), "A master sneak does not hide in the shortest time")
	TEST_ASSERT(!(spot.on_attack_hand(table, novice) & COMPONENT_CANCEL_ATTACK_CHAIN), "One not sneaking hides under a table")
	var/obj/structure/flora/roguegrass/bush/bush = allocate(__IMPLIED_TYPE__)
	var/datum/component/rockhill_hiding_spot/bush_spot = bush.GetComponent(/datum/component/rockhill_hiding_spot)
	TEST_ASSERT_EQUAL(bush_spot?.preposition, "in", "One does not hide in a bush")
	var/obj/structure/bookcase/shelf = allocate(__IMPLIED_TYPE__)
	var/datum/component/rockhill_hiding_spot/shelf_spot = shelf.AddComponent(/datum/component/rockhill_hiding_spot)
	TEST_ASSERT_EQUAL(shelf_spot.preposition, "behind", "One does not hide behind a bookcase")

/// A lit candle glows and burns its wax, is snuffed in hand, lit by a spark or a flame, trampled out by a runner and leaves a
/// stub; a skull candle never burns down.
/datum/unit_test/rogue_doors_candles

/datum/unit_test/rogue_doors_candles/Run()
	var/mob/living/carbon/human/consistent/reader = allocate(__IMPLIED_TYPE__)
	var/obj/item/candle/yellow/lit/candle = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(candle.lit && candle.light_on, "A lit candle of the map gives no light")
	TEST_ASSERT(candle.get_temperature(), "A lit candle is cold")
	var/wax = candle.wax
	candle.process(2)
	TEST_ASSERT(candle.wax < wax, "A lit candle does not burn its wax")
	candle.attack_self(reader)
	TEST_ASSERT(!candle.lit && !candle.light_on, "Using a lit candle in hand did not snuff it")
	TEST_ASSERT(!candle.get_temperature(), "A snuffed candle is still hot")
	candle.spark_act()
	TEST_ASSERT(candle.lit, "A spark did not light a candle")
	var/obj/item/candle/skull/lit/skull = allocate(__IMPLIED_TYPE__)
	var/skull_wax = skull.wax
	skull.process(2)
	TEST_ASSERT_EQUAL(skull.wax, skull_wax, "A skull candle burns down")
	var/obj/item/candle/yellow/unlit = allocate(__IMPLIED_TYPE__)
	unlit.item_interaction(reader, skull, list())
	TEST_ASSERT(unlit.lit, "A candle held to a flame did not catch")
	reader.set_move_intent(MOVE_INTENT_RUN)
	reader.forceMove(run_loc_floor_top_right)
	reader.forceMove(get_turf(candle))
	TEST_ASSERT(!candle.lit, "Running over a candle did not trample it out")
	TEST_ASSERT(candle.wax <= rogue_value("candle_trampled_wax"), "A trampled candle kept its wax")
	candle.light_candle()
	candle.wax = 0.5
	var/turf/spot = get_turf(candle)
	candle.process(2)
	TEST_ASSERT(QDELETED(candle), "A candle out of wax is still there")
	TEST_ASSERT(locate(/obj/item/trash/candle) in spot, "A candle burned to the end left no stub")

/// A door basher (the minotaur) walks into a locked door to hurt it and plans its way through a shut one, which others do not.
/datum/unit_test/rogue_doors_bashers

/datum/unit_test/rogue_doors_bashers/Run()
	var/mob/living/simple_animal/hostile/retaliate/rogue/minotaur/minotaur = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/townsman = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(HAS_TRAIT(minotaur, TRAIT_BASHDOORS), "A minotaur does not bash doors")
	var/obj/structure/mineral_door/rockhill/wood/door = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(door.CanAStarPass(NORTH, new /datum/can_pass_info(minotaur)), "A minotaur does not plan its way through a shut door")
	TEST_ASSERT(!door.CanAStarPass(NORTH, new /datum/can_pass_info(townsman)), "One without door bashing plans its way through a shut door")
	door.keylock = TRUE
	door.locked = TRUE
	var/integrity = door.get_integrity()
	door.Bumped(minotaur)
	TEST_ASSERT(door.get_integrity() < integrity, "A minotaur walking into a locked door did not hurt it")
	TEST_ASSERT(door.locked, "A minotaur walking into a locked door unlocked it")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
