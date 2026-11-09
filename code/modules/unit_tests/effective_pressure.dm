/// Ensures calculate_affecting_pressure returns the expected effective pressure for various gear configurations
/datum/unit_test/effective_pressure
	abstract_type = /datum/unit_test/effective_pressure
	/// The expected effective pressure for the given gear configuration
	var/expected_pressure = -1

/datum/unit_test/effective_pressure/Run()
	var/mob/living/carbon/human/consistent/guy = EASY_ALLOCATE()
	ADD_TRAIT(guy, TRAIT_GODMODE, INNATE_TRAIT)
	prepare_for_test(guy)
	TEST_ASSERT_EQUAL(guy.calculate_affecting_pressure(0), expected_pressure, "Effective pressure calculation failed!")

/datum/unit_test/effective_pressure/proc/prepare_for_test(mob/living/carbon/human/guy)
	return

/// no gear, no protection
/datum/unit_test/effective_pressure/no_gear
	expected_pressure = 0

/// just wearing a helmet offers no protection
/datum/unit_test/effective_pressure/helmet_only
	expected_pressure = 0

/datum/unit_test/effective_pressure/helmet_only/prepare_for_test(mob/living/carbon/human/guy)
	var/obj/item/clothing/head/utility/hardhat/red/hat = EASY_ALLOCATE()
	guy.equip_to_appropriate_slot(hat)

/// firesuit + firehelmet should offer full protection
/datum/unit_test/effective_pressure/firesuit
	expected_pressure = ONE_ATMOSPHERE

/datum/unit_test/effective_pressure/firesuit/prepare_for_test(mob/living/carbon/human/guy)
	var/obj/item/clothing/suit/utility/fire/firefighter/suit = EASY_ALLOCATE()
	var/obj/item/clothing/head/utility/hardhat/red/hat = EASY_ALLOCATE()
	guy.equip_to_appropriate_slot(suit)
	guy.equip_to_appropriate_slot(hat)

/// lacking a head means you don't need to protect it, thus a firesuit alone should suffice
/datum/unit_test/effective_pressure/firesuit_no_head
	expected_pressure = ONE_ATMOSPHERE

/datum/unit_test/effective_pressure/firesuit_no_head/prepare_for_test(mob/living/carbon/human/guy)
	var/obj/item/clothing/suit/utility/fire/firefighter/suit = EASY_ALLOCATE()
	guy.equip_to_appropriate_slot(suit)
	var/obj/item/bodypart/head/guy_head = guy.get_bodypart(BODY_ZONE_HEAD)
	guy_head.drop_limb(TRUE)
	qdel(guy_head)

/// Checks pressure protections flags
/datum/unit_test/pressure_protection_flags

/datum/unit_test/pressure_protection_flags/Run()
	var/mob/living/carbon/human/consistent/guy = EASY_ALLOCATE()
	ADD_TRAIT(guy, TRAIT_GODMODE, INNATE_TRAIT)

	var/obj/item/clothing/suit/utility/fire/firefighter/suit = EASY_ALLOCATE()
	guy.equip_to_appropriate_slot(suit)
	TEST_ASSERT(guy.pressure_protected_bodyparts & PRESSURE_CHEST_PROTECTED_BY_EQUIPMENT, "Equipping a firesuit didn't provide chest pressure protection")
	TEST_ASSERT(guy.pressure_protected_bodyparts & PRESSURE_LEGS_PROTECTED_BY_EQUIPMENT, "Equipping a firesuit didn't provide leg pressure protection")
	TEST_ASSERT(guy.pressure_protected_bodyparts & PRESSURE_ARMS_PROTECTED_BY_EQUIPMENT, "Equipping a firesuit didn't provide arm pressure protection")

	var/obj/item/bodypart/leg/left/left_leg = guy.get_bodypart(BODY_ZONE_L_LEG)
	TEST_ASSERT(!(guy.pressure_protected_bodyparts & PRESSURE_LEGS_PROTECTED_NATIVELY), "Removing one legs provided full pressure protection")
	qdel(left_leg)
	var/obj/item/bodypart/leg/right/right_leg = guy.get_bodypart(BODY_ZONE_R_LEG)
	TEST_ASSERT(guy.pressure_protected_bodyparts & PRESSURE_LEGS_PROTECTED_NATIVELY, "Removing both legs didn't provide full pressure protection")
	qdel(right_leg)

	var/obj/item/bodypart/arm/left/left_arm = guy.get_bodypart(BODY_ZONE_L_ARM)
	TEST_ASSERT(!(guy.pressure_protected_bodyparts & PRESSURE_ARMS_PROTECTED_NATIVELY), "Removing one arm provided full pressure protection")
	qdel(left_arm)
	var/obj/item/bodypart/arm/right/right_arm = guy.get_bodypart(BODY_ZONE_R_ARM)
	TEST_ASSERT(guy.pressure_protected_bodyparts & PRESSURE_ARMS_PROTECTED_NATIVELY, "Removing both arms didn't provide full pressure protection")
	qdel(right_arm)

	var/obj/item/bodypart/head/head = guy.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(guy.pressure_protected_bodyparts & PRESSURE_HEAD_PROTECTED_NATIVELY, "Removing the head didn't provide full pressure protection")
	qdel(head)
