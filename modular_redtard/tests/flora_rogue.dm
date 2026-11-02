#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's blow classes (rockhill/destruction.dm): a club bounces off a bush but a chop bites, a blade skids off a boulder but
/// a club cracks it, wood takes both, and only a pick hurts what gives way to a pick. A blow under a structure's deflection
/// leaves no mark.
/datum/unit_test/rogue_structure_blows

/datum/unit_test/rogue_structure_blows/Run()
	var/mob/living/carbon/human/consistent/smasher = allocate(__IMPLIED_TYPE__)
	var/obj/item/rockhill/weapon = allocate(/obj/item/rockhill)
	weapon.force = 20
	var/datum/intent/club = new
	club.blade_class = BCLASS_BLUNT
	var/datum/intent/chop = new
	chop.blade_class = BCLASS_CHOP
	var/datum/intent/pick = new
	pick.blade_class = BCLASS_PICK
	var/obj/structure/flora/roguegrass/bush/bush = allocate(/obj/structure/flora/roguegrass/bush)
	TEST_ASSERT_EQUAL(bush.rockhill_dulling, "cut", "A bush does not give way to cuts only")
	TEST_ASSERT_EQUAL(bush.rockhill_blow_damage(weapon, smasher, club), 0, "A club hurt a bush")
	TEST_ASSERT(bush.rockhill_blow_damage(weapon, smasher, chop) > 0, "A chop did not bite into a bush")
	var/obj/structure/roguerock/boulder = allocate(/obj/structure/roguerock)
	TEST_ASSERT_EQUAL(boulder.rockhill_dulling, "bash", "A boulder does not give way to blunt blows only")
	TEST_ASSERT_EQUAL(boulder.rockhill_blow_damage(weapon, smasher, chop), 0, "A chop hurt a boulder")
	TEST_ASSERT(boulder.rockhill_blow_damage(weapon, smasher, club) > 0, "A club did not crack a boulder")
	var/obj/structure/table/wood/rockhill/wood/table = allocate(/obj/structure/table/wood/rockhill/wood)
	TEST_ASSERT_EQUAL(table.rockhill_dulling, "bashchop", "A wooden table does not give way to clubs and blades")
	TEST_ASSERT(table.rockhill_blow_damage(weapon, smasher, club) > 0, "A club did not hurt a table")
	TEST_ASSERT(table.rockhill_blow_damage(weapon, smasher, chop) > 0, "A chop did not hurt a table")
	table.rockhill_dulling = "pick"
	TEST_ASSERT_EQUAL(table.rockhill_blow_damage(weapon, smasher, club), 0, "A club hurt what gives way to a pick only")
	TEST_ASSERT(table.rockhill_blow_damage(weapon, smasher, pick) > 0, "A pick did not bite into what gives way to a pick")
	table.rockhill_dulling = "bashchop"
	table.damage_deflection = 1000
	TEST_ASSERT_EQUAL(table.rockhill_blow(weapon, smasher), 0, "A blow under the deflection marked a table")

/// Ratwood's debris (rockhill/destruction.dm): a boulder breaks into a stone; a wooden table broken by blows leaves Ratwood's
/// debris and none of the planks of TG's table.
/datum/unit_test/rogue_structure_debris

/datum/unit_test/rogue_structure_debris/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/obj/structure/roguerock/boulder = allocate(/obj/structure/roguerock, spot)
	boulder.take_damage(boulder.max_integrity, BRUTE, MELEE, FALSE)
	TEST_ASSERT(QDELETED(boulder), "A boulder survived damage to its whole integrity")
	TEST_ASSERT(locate(/obj/item/natural/stone) in spot, "A broken boulder left no stone")
	var/turf/table_spot = run_loc_floor_top_right
	var/obj/structure/table/wood/rockhill/wood/table = allocate(/obj/structure/table/wood/rockhill/wood, table_spot)
	table.take_damage(table.max_integrity, BRUTE, MELEE, FALSE)
	TEST_ASSERT(QDELETED(table), "A table survived damage to its whole integrity")
	TEST_ASSERT(!(locate(/obj/item/stack/sheet/mineral/wood) in table_spot), "A table broken by blows dropped TG's planks")

/// Ratwood's searchable plants (rockhill/flora.dm): a bush always holds fibres, wild pumpkins at least a pumpkin and fibres,
/// grass holds nothing to search; a bush holds whoever walks into it and grass rustles under them.
/datum/unit_test/rogue_flora_search

/datum/unit_test/rogue_flora_search/Run()
	var/obj/structure/flora/roguegrass/bush/bush = allocate(/obj/structure/flora/roguegrass/bush)
	TEST_ASSERT(bush.rockhill_searchable(), "A bush cannot be searched")
	TEST_ASSERT(/obj/item/natural/fibers in bush.rockhill_loot, "A bush holds no fibres")
	TEST_ASSERT(bush.GetComponent(/datum/component/rockhill_hiding_spot), "One cannot hide in a bush")
	var/obj/structure/flora/roguegrass/pumpkin/pumpkins = allocate(/obj/structure/flora/roguegrass/pumpkin)
	TEST_ASSERT(/obj/item/natural/shellplant/pumpkin in pumpkins.rockhill_loot, "Wild pumpkins hold no pumpkin")
	TEST_ASSERT(/obj/item/natural/fibers in pumpkins.rockhill_loot, "Wild pumpkins hold no fibres")
	var/obj/structure/flora/roguegrass/grass = allocate(/obj/structure/flora/roguegrass)
	TEST_ASSERT(!grass.rockhill_searchable(), "Grass can be searched")
	var/mob/living/carbon/human/consistent/walker = allocate(__IMPLIED_TYPE__)
	bush.rockhill_brushed(walker)
	TEST_ASSERT(walker.IsImmobilized(), "A bush did not hold whoever walked into it")

/// Ratwood's herbs (rockhill/herbs.dm): every herb the porter brought gives an ingredient, says what it is, and grows its
/// ingredient back once picked.
/datum/unit_test/rogue_herbs

/datum/unit_test/rogue_herbs/Run()
	for(var/obj/structure/flora/roguegrass/herb/herb_type as anything in subtypesof(/obj/structure/flora/roguegrass/herb))
		if(herb_type == /obj/structure/flora/roguegrass/herb/random)
			continue
		if(!ispath(initial(herb_type.herbtype), /obj/item))
			TEST_FAIL("[herb_type] gives [initial(herb_type.herbtype) || "nothing"], not an item")
	var/obj/structure/flora/roguegrass/herb/salvia/salvia = allocate(/obj/structure/flora/roguegrass/herb/salvia)
	TEST_ASSERT_EQUAL(salvia.desc, "An herb. This one looks like [salvia.name].", "A herb keeps the placeholder description")
	TEST_ASSERT(salvia.herbtype in salvia.rockhill_loot, "A herb holds no ingredient")
	salvia.rockhill_loot.Cut()
	salvia.rockhill_picked = TRUE
	salvia.rockhill_herb_regrow()
	TEST_ASSERT(salvia.herbtype in salvia.rockhill_loot, "A picked herb did not grow its ingredient back")
	TEST_ASSERT(!salvia.rockhill_picked, "A herb grown back still counts as picked")

/// Ratwood's sparks (rockhill/sparks.dm): a spark lights an unlit torch and a campfire that has fuel, and sets grass alight.
/datum/unit_test/rogue_sparks

/datum/unit_test/rogue_sparks/Run()
	var/obj/item/flashlight/flare/torch/torch = allocate(/obj/item/flashlight/flare/torch)
	TEST_ASSERT(!torch.light_on, "A new torch is lit")
	torch.spark_act()
	TEST_ASSERT(torch.light_on, "A spark did not light a torch")
	var/obj/machinery/light/rogue/campfire/campfire = allocate(/obj/machinery/light/rogue/campfire)
	campfire.burn_out(silent = TRUE)
	TEST_ASSERT(!campfire.lit, "A campfire did not go out")
	campfire.spark_act()
	TEST_ASSERT(campfire.lit, "A spark did not light a campfire with fuel")
	var/obj/structure/flora/roguegrass/grass = allocate(/obj/structure/flora/roguegrass)
	TEST_ASSERT(grass.resistance_flags & FLAMMABLE, "Grass does not burn")
	grass.spark_act()
	TEST_ASSERT(QDELETED(grass) || (grass.resistance_flags & ON_FIRE), "A spark did not set grass alight")

/// Ratwood's ore veins (rockhill/mining.dm): every vein a random rock can roll gives ore when dug, spreads by a chance of its
/// own, and shows in a miner's Ore Sight.
/datum/unit_test/rogue_ore_veins

/datum/unit_test/rogue_ore_veins/Run()
	for(var/rock_type in GLOB.rockhill_random_veins)
		var/list/spec = GLOB.rockhill_random_veins[rock_type]
		for(var/vein in spec[2])
			var/list/drops = GLOB.rockhill_vein_drops[vein]
			if(!drops || !ispath(drops[1], /obj/item))
				TEST_FAIL("[rock_type] rolls [vein], which gives no ore")
			if(rogue_value_or("vein_spread_[vein]", 0) <= 0)
				TEST_FAIL("[vein] has no spread chance")

/// Rockhill's sky (rockhill/sky.dm): every sunlit part of an area lies under a shaded area it can move back into.
/datum/unit_test/rogue_sky_areas

/datum/unit_test/rogue_sky_areas/Run()
	for(var/area/rogue/area_type as anything in subtypesof(/area/rogue))
		if(!initial(area_type.rockhill_sunlit))
			continue
		var/area/rogue/shaded = initial(area_type.parent_type)
		if(!ispath(shaded, /area/rogue) || initial(shaded.rockhill_sunlit))
			TEST_FAIL("[area_type] has no shaded area to move back into")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
