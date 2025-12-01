/// Test various permutations of ethereal revival
/datum/unit_test/ethereal_revival

/datum/unit_test/ethereal_revival/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/heart/ethereal/respawn_heart = new()
	respawn_heart.Insert(victim, special = TRUE, movement_flags = DELETE_IF_REPLACED) // Pretend this guy is an ethereal
	victim.mock_client = new()

	victim.death()
	TEST_ASSERT_NOTNULL(respawn_heart.crystalize_timer_id, "Ethereal heart didn't respond to host death.")
	victim.revive()
	TEST_ASSERT_NULL(respawn_heart.crystalize_timer_id, "Ethereal heart didn't respond to host revival.")

	victim.death()
	victim.apply_damage(300)
	TEST_ASSERT_NULL(respawn_heart.crystalize_timer_id, "Ethereal heart didn't cancel revival on taking damage.")

	instant_crystallise(victim, respawn_heart)
	TEST_ASSERT_NOTNULL(respawn_heart.current_crystal, "Ethereal heart didn't successfully crystallise host.")

	qdel(respawn_heart.current_crystal)
	TEST_ASSERT(respawn_heart.crystalize_cooldown > 0, "Ethereal heart didn't go on cooldown after crystallising.")
	TEST_ASSERT(respawn_heart.crystalize_cooldown < INFINITY, "Ethereal heart got stuck on cooldown when crystal was destroyed.")

	instant_crystallise(victim, respawn_heart)
	TEST_ASSERT_NULL(respawn_heart.current_crystal, "Ethereal crystallised while heart was on cooldown.")

	victim.gain_trauma(/datum/brain_trauma/special/ptsd, resilience = TRAUMA_RESILIENCE_BASIC) // One you can't gain via revival
	var/obj/item/bodypart/leg/left_leg = victim.get_bodypart(BODY_ZONE_L_LEG)
	left_leg.dismember()
	var/obj/item/bodypart/leg/right_leg = victim.get_bodypart(BODY_ZONE_R_LEG)
	var/datum/wound/slash/flesh/severe/crit_wound = new()
	crit_wound.apply_wound(right_leg)
	kill_and_revive(victim, respawn_heart)

	TEST_ASSERT(victim.health == victim.maxHealth, "Ethereal not fully healed after reviving.")
	TEST_ASSERT_NOTNULL(victim.get_bodypart(BODY_ZONE_L_LEG), "Ethereal failed to regrow limb when reviving.")
	TEST_ASSERT(!length(right_leg.wounds), "Ethereal failed to fix wound when reviving.")
	var/list/current_traumas = victim.get_traumas()
	TEST_ASSERT(!(locate(/datum/brain_trauma/special/ptsd) in current_traumas), "Ethereal failed to heal curable brain trauma when reviving.")
	TEST_ASSERT(length(current_traumas) == 1, "Ethereal failed to gain trauma when reviving.")

	kill_and_revive(victim, respawn_heart)
	TEST_ASSERT(length(victim.get_traumas()) == 2, "Ethereal failed to gain additional trauma on second revival.")

	instant_crystallise(victim, respawn_heart)
	victim.heal_and_revive()
	TEST_ASSERT_NULL(respawn_heart.current_crystal, "Crystal didn't despawn when player was revived by other means.")

/datum/unit_test/ethereal_revival/proc/instant_crystallise(mob/living/carbon/victim, obj/item/organ/heart/ethereal/respawn_heart)
	victim.death()
	deltimer(respawn_heart.crystalize_timer_id)
	respawn_heart.crystalize(victim)

/datum/unit_test/ethereal_revival/proc/kill_and_revive(mob/living/carbon/victim, obj/item/organ/heart/ethereal/respawn_heart)
	COOLDOWN_RESET(respawn_heart, crystalize_cooldown)
	instant_crystallise(victim, respawn_heart)
	var/obj/structure/ethereal_crystal/crystal = respawn_heart.current_crystal
	crystal.heal_ethereal()
