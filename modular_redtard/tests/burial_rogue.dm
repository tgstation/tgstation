#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's rot of the dead (burial/corpse_rot.dm). The test map is not a medieval one, so the rot is started by hand, as
/// a death on a medieval map starts it. Past rot_flesh_time the limbs rot - the colour of rot, of no use - and the body
/// is weaker; a rotted limb goes to bones; the cure undoes it all; life ends the rot.
/datum/unit_test/rogue_corpse_rot

/datum/unit_test/rogue_corpse_rot/Run()
	var/mob/living/carbon/human/consistent/corpse = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(corpse.rogue_start_rot(), "A living body started to rot")
	corpse.death()
	var/datum/component/rogue_corpse_rot/rot = corpse.rogue_start_rot()
	TEST_ASSERT_NOTNULL(rot, "A human corpse does not rot")
	rot.amount = rogue_value("rot_flesh_time") + 1
	rot.rot_tick()
	var/obj/item/bodypart/arm = corpse.get_bodypart(BODY_ZONE_L_ARM)
	TEST_ASSERT(arm.rogue_rotted, "A limb did not rot past the rot time")
	TEST_ASSERT_EQUAL(corpse.rogue_rot_stage(), ROGUE_ROT_ROTTEN, "The rotted body is not rotten")
	TEST_ASSERT(corpse.rogue_has_rot(), "The rotted body has no rot")
	TEST_ASSERT(corpse.has_status_effect(/datum/status_effect/rogue_rotted_corpse), "The rotted body is not weakened")
	TEST_ASSERT_EQUAL(LAZYACCESS(arm.color_overrides, "[ROGUE_LIMB_COLOR_ROT]"), ROGUE_ROT_SKIN_COLOR, "The rotted limb is not the colour of rot")
	if(rogue_value("rot_limbs_give_out"))
		TEST_ASSERT(HAS_TRAIT_FROM(arm, TRAIT_PARALYSIS, ROGUE_ROT_TRAIT), "The rotted limb does not give out")
	TEST_ASSERT(arm.rogue_skeletonize(), "A rotted limb did not go to bones")
	TEST_ASSERT_EQUAL(arm.limb_id, SPECIES_SKELETON, "A limb of bones does not look like bones")
	TEST_ASSERT_NULL(LAZYACCESS(arm.color_overrides, "[ROGUE_LIMB_COLOR_ROT]"), "Bones keep the colour of rot")
	TEST_ASSERT_EQUAL(corpse.rogue_rot_stage(), ROGUE_ROT_BONES, "A body with a limb of bones is not bones")
	TEST_ASSERT(corpse.rogue_remove_rot(), "Curing a rotted body found no rot")
	TEST_ASSERT(!arm.rogue_rotted && !arm.rogue_skeleton, "The cure left the limb rotted")
	TEST_ASSERT(arm.limb_id != SPECIES_SKELETON, "The cure left the limb looking like bones")
	TEST_ASSERT_NULL(LAZYACCESS(arm.color_overrides, "[ROGUE_LIMB_COLOR_ROT]"), "The cure left the colour of rot")
	TEST_ASSERT(!HAS_TRAIT_FROM(arm, TRAIT_PARALYSIS, ROGUE_ROT_TRAIT), "The cure left the limb of no use")
	TEST_ASSERT(!corpse.has_status_effect(/datum/status_effect/rogue_rotted_corpse), "The cure left the body weakened")
	TEST_ASSERT_EQUAL(corpse.rogue_rot_amount(), 0, "The cure left the rot counting")
	corpse.revive(HEAL_ALL)
	TEST_ASSERT_NULL(corpse.GetComponent(/datum/component/rogue_corpse_rot), "A body alive again still rots")

/// A body nobody is in turns to dust once it is bones (Ratwood dusts the bodies of NPCs).
/datum/unit_test/rogue_corpse_dust

/datum/unit_test/rogue_corpse_dust/Run()
	var/mob/living/carbon/human/consistent/corpse = allocate(__IMPLIED_TYPE__)
	corpse.death()
	var/datum/component/rogue_corpse_rot/rot = corpse.rogue_start_rot()
	TEST_ASSERT_NOTNULL(rot, "A human corpse does not rot")
	rot.amount = rogue_value("rot_flesh_time") + 1
	rot.rot_tick()
	TEST_ASSERT(!QDELETED(rot), "A rotten body turned to dust before it was bones")
	rot.amount = rogue_value("rot_bones_time") + 1
	rot.rot_tick()
	TEST_ASSERT_EQUAL(corpse.rogue_rot_stage(), ROGUE_ROT_BONES, "The rotted limbs did not go to bones")
	TEST_ASSERT(QDELETED(rot), "A body of bones nobody is in did not turn to dust")

/// Ratwood's graves (burial/graves.dm): a strong digger's scoop deepens a hole and takes up a clod, a clod fills it back;
/// thrown over a body in a pit it seals a grave with the body in it, an empty shovel opens it again; an empty pit filled
/// in stays a hole. An old grave of the map gives up bones; robbing a marked grave curses the robber.
/datum/unit_test/rogue_graves
	normal_floor_required = TRUE

/datum/unit_test/rogue_graves/Run()
	var/turf/ground = run_loc_floor_bottom_left
	ground.ChangeTurf(/turf/open/floor/rogue/dirt/road)
	var/mob/living/carbon/human/consistent/digger = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	digger.rogue_adjust_stat(ROGUE_STAT_STRENGTH, 10)
	var/obj/item/rogueweapon/shovel/shovel = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/obj/structure/closet/crate/wooden/rockhill/dirthole/hole = allocate(__IMPLIED_TYPE__, ground)
	TEST_ASSERT(hole.opened, "A hole was dug closed")
	hole.rogue_shovel(shovel, digger)
	TEST_ASSERT_EQUAL(hole.rogue_stage, ROGUE_HOLE_DEEP, "A strong digger's scoop did not deepen the hole")
	TEST_ASSERT_NOTNULL(shovel.rogue_clod, "Digging put no clod on the shovel")
	hole.rogue_shovel(shovel, digger)
	TEST_ASSERT_EQUAL(hole.rogue_stage, ROGUE_HOLE_SHALLOW, "A clod did not fill the hole back")
	TEST_ASSERT_NULL(shovel.rogue_clod, "Filling the hole kept the clod on the shovel")
	hole.rogue_shovel(shovel, digger)
	shovel.rogue_lose_clod()
	hole.rogue_shovel(shovel, digger)
	TEST_ASSERT_EQUAL(hole.rogue_stage, ROGUE_HOLE_PIT, "Two scoops did not dig a pit")
	var/mob/living/carbon/human/consistent/dead = allocate(__IMPLIED_TYPE__, ground)
	dead.death()
	hole.rogue_shovel(shovel, digger)
	TEST_ASSERT_EQUAL(hole.rogue_stage, ROGUE_HOLE_GRAVE, "A clod thrown over a body did not seal a grave")
	TEST_ASSERT(!hole.opened && (dead in hole), "The grave did not close over the body")
	TEST_ASSERT(hole.rogue_grave_covered(), "A sealed grave is not covered")
	TEST_ASSERT(dead.rogue_buried, "The dead were not buried")
	hole.rogue_shovel(shovel, digger)
	TEST_ASSERT(hole.opened && hole.rogue_stage == ROGUE_HOLE_PIT, "An empty shovel did not open the grave")
	TEST_ASSERT(dead.loc == ground, "The opened grave kept the body")
	dead.forceMove(run_loc_floor_top_right)
	for(var/obj/item/find in ground)
		qdel(find)
	hole.rogue_shovel(shovel, digger)
	TEST_ASSERT(hole.opened && hole.rogue_stage == ROGUE_HOLE_DEEP, "An empty pit filled in did not stay an open hole")

	shovel.rogue_lose_clod()
	var/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot/old_grave = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	old_grave.rogue_lootroll = 0
	var/obj/structure/gravemarker/marker = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	TEST_ASSERT(!old_grave.opened, "An old grave of the map lies open")
	old_grave.rogue_shovel(shovel, digger)
	TEST_ASSERT(old_grave.opened, "An empty shovel did not open the old grave")
	TEST_ASSERT(locate(/obj/item/natural/bundle/bone/full) in old_grave.loc, "The old grave gave up no bones")
	TEST_ASSERT(QDELETED(marker), "Robbing a marked grave left its marker")
	TEST_ASSERT(digger.has_status_effect(/datum/status_effect/rogue_grave_curse), "Robbing a marked grave did not curse the robber")

/// Ratwood's earth (burial/digging.dm): a free hand takes clods from dirt until it is a road; a shovel breaks dirt into a
/// road and its clod mends it; a road by water is mud, slow to walk.
/datum/unit_test/rogue_earth
	normal_floor_required = TRUE

/datum/unit_test/rogue_earth/Run()
	var/mob/living/carbon/human/consistent/digger = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/turf/open/floor/rogue/dirt/ground = run_loc_floor_bottom_left
	ground.ChangeTurf(/turf/open/floor/rogue/dirt)
	for(var/i in 1 to rogue_value("dirt_clods"))
		TEST_ASSERT(!istype(ground, /turf/open/floor/rogue/dirt/road), "Dirt became a road before its clods ran out")
		TEST_ASSERT_EQUAL(ground.attack_hand_secondary(digger, list()), SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN, "A free hand took no clod of dirt")
		var/obj/item/natural/dirtclod/clod = digger.get_active_held_item()
		TEST_ASSERT(istype(clod), "The clod is not in the hand")
		qdel(clod)
	TEST_ASSERT(istype(ground, /turf/open/floor/rogue/dirt/road), "Dirt with its clods taken did not become a road")

	var/obj/item/rogueweapon/shovel/shovel = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/turf/field = get_step(run_loc_floor_bottom_left, NORTH)
	field.ChangeTurf(/turf/open/floor/rogue/dirt)
	TEST_ASSERT(shovel.rogue_dig(field, digger), "A shovel did not dig dirt")
	TEST_ASSERT(istype(field, /turf/open/floor/rogue/dirt/road), "The first scoop did not break the dirt into a road")
	TEST_ASSERT_NOTNULL(shovel.rogue_clod, "Digging put no clod on the shovel")
	TEST_ASSERT(shovel.rogue_dig(field, digger), "A shovel did not throw its clod on a road")
	TEST_ASSERT(!istype(field, /turf/open/floor/rogue/dirt/road), "A clod did not mend the road into dirt")
	TEST_ASSERT_NULL(shovel.rogue_clod, "Mending the road kept the clod on the shovel")

	var/turf/water = get_step(run_loc_floor_bottom_left, EAST)
	water.ChangeTurf(/turf/open/water/rockhill)
	ground.ChangeTurf(/turf/open/floor/rogue/dirt/road, flags = CHANGETURF_FORCEOP)
	TEST_ASSERT(ground.rogue_muddy, "A road by water is not mud")
	TEST_ASSERT_EQUAL(ground.slowdown, rogue_value("mud_slowdown"), "Mud is not slow to walk")

/// Ratwood's dead bodies (burial/dead_bodies.dm): each kind lies in a pose of its sheet and has things to find; a lucky
/// search pulls three out, and nothing is left after.
/datum/unit_test/rogue_dead_bodies

/datum/unit_test/rogue_dead_bodies/Run()
	for(var/body_type in subtypesof(/obj/structure/deadbody))
		var/obj/structure/deadbody/kind = allocate(body_type)
		if(!length(kind.rockhill_loot))
			TEST_FAIL("[body_type] has nothing to find")
			continue
		if(!(kind.icon_state in kind.rockhill_poses) || !icon_exists(kind.icon, kind.icon_state))
			TEST_FAIL("[body_type] lies as \"[kind.icon_state]\", not a pose of its kind in its sheet")
		var/list/finds = kind.rockhill_loot.Copy()
		if(length(kind.rockhill_loot_lucky))
			finds += kind.rockhill_loot_lucky
		for(var/find in finds)
			if(!istext(find) && !ispath(find, /obj/item))
				TEST_FAIL("[body_type] hides [find], which is not an item")
	var/mob/living/carbon/human/consistent/searcher = allocate(__IMPLIED_TYPE__)
	searcher.rogue_adjust_stat(ROGUE_STAT_FORTUNE, 10)
	var/obj/structure/deadbody/generic/body = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_EQUAL(body.rogue_loot_body(searcher), 3, "A lucky search did not turn up three things")
	TEST_ASSERT(body.rogue_looted, "A searched body was not looted")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
