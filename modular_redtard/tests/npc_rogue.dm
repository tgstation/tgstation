#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// The NPC people's mind (ai/human_npc_tactics.dm) is built for its kind: breaking free, running (the fleeing kinds only),
/// tending wounds, then the fight and its pastimes.
/datum/unit_test/rogue_npc_mind

/datum/unit_test/rogue_npc_mind/Run()
	var/mob/living/carbon/human/consistent/hunter = allocate(__IMPLIED_TYPE__)
	var/datum/ai_controller/basic_controller/simple/rogue_human/mind = allocate(/datum/ai_controller/basic_controller/simple/rogue_human, hunter)
	TEST_ASSERT_EQUAL(length(mind.behavior_nodes), 3, "A hunting NPC's mind does not have its three roots")
	TEST_ASSERT(istype(mind.behavior_nodes[2], /datum/bt_node/subtree/rogue_npc_self_care), "An NPC does not tend its wounds before the fight")
	var/mob/living/carbon/human/consistent/runner = allocate(__IMPLIED_TYPE__)
	var/datum/ai_controller/basic_controller/simple/rogue_human/retaliate/fleeing/scared = allocate(/datum/ai_controller/basic_controller/simple/rogue_human/retaliate/fleeing, runner)
	TEST_ASSERT_EQUAL(length(scared.behavior_nodes), 4, "A fleeing NPC's mind does not run")

/// What an NPC finds on itself to use: a healing potion, a clean cloth, a throwing knife; and its bleeding limb.
/datum/unit_test/rogue_npc_gear

/datum/unit_test/rogue_npc_gear/Run()
	var/mob/living/carbon/human/consistent/npc = allocate(__IMPLIED_TYPE__)
	npc.AddElement(/datum/element/rogue_blood)
	var/obj/item/reagent_containers/glass/bottle/potion = allocate(__IMPLIED_TYPE__)
	potion.reagents.add_reagent(/datum/reagent/medicine/healthpot, 10)
	npc.put_in_active_hand(potion)
	TEST_ASSERT_EQUAL(npc.rogue_npc_find_potion(), potion, "An NPC does not find the healing potion in its hand")
	var/obj/item/rogueweapon/huntingknife/throwingknife/knife = allocate(__IMPLIED_TYPE__)
	npc.put_in_inactive_hand(knife)
	TEST_ASSERT_EQUAL(npc.rogue_npc_find_throwable(), knife, "An NPC does not find its throwing knife")
	npc.rogue_npc_put_away(knife)
	npc.dropItemToGround(knife)
	var/obj/item/natural/cloth/cloth = allocate(__IMPLIED_TYPE__)
	npc.put_in_inactive_hand(cloth)
	TEST_ASSERT_EQUAL(npc.rogue_npc_find_cloth(), cloth, "An NPC does not find a clean cloth")
	cloth.rogue_soaked = TRUE
	TEST_ASSERT(!npc.rogue_npc_find_cloth(), "An NPC binds wounds with a blood-soaked cloth")
	TEST_ASSERT(!npc.rogue_npc_bleeding_limb(), "An unhurt NPC has a bleeding limb")
	var/obj/item/bodypart/arm = npc.get_bodypart(BODY_ZONE_L_ARM)
	npc.apply_damage(15, BRUTE, arm, wound_bonus = 100, sharpness = SHARP_EDGED)
	TEST_ASSERT_EQUAL(npc.rogue_npc_bleeding_limb(), arm, "An NPC does not see its cut arm bleed")

/// Ratwood npc_detect_sneak(): spotting reveals the sneaker; a sure miss does not.
/datum/unit_test/rogue_npc_spot

/datum/unit_test/rogue_npc_spot/Run()
	var/mob/living/carbon/human/consistent/seeker = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/hider = allocate(__IMPLIED_TYPE__)
	hider.rogue_sneaking = TRUE
	hider.rogue_sneak_hidden = TRUE
	TEST_ASSERT(!seeker.rogue_npc_spot(hider, -1000), "A sure miss spotted the sneaker")
	TEST_ASSERT(hider.rogue_is_hidden(), "A missed sneaker was revealed")
	TEST_ASSERT(seeker.rogue_npc_spot(hider, 1000), "A sure spot missed the sneaker")
	TEST_ASSERT(!hider.rogue_is_hidden(), "A spotted sneaker stayed hidden")
	hider.rogue_stop_sneaking()

/// An NPC strikes and backs off once badly hurt (Vibelin harass), and its retreat is not toward the foe.
/datum/unit_test/rogue_npc_harass

/datum/unit_test/rogue_npc_harass/Run()
	var/mob/living/carbon/human/consistent/fighter = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/foe = allocate(__IMPLIED_TYPE__, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT(!fighter.rogue_npc_wants_harass(), "A fresh NPC strikes and backs off")
	fighter.apply_damage(fighter.maxHealth * 0.5, BRUTE, BODY_ZONE_CHEST)
	TEST_ASSERT(fighter.rogue_npc_wants_harass(), "A badly hurt NPC does not strike and back off")
	var/turf/retreat = fighter.rogue_npc_retreat_turf(foe)
	TEST_ASSERT(retreat && get_dist(retreat, foe) >= get_dist(fighter, foe), "An NPC backs off toward its foe")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
