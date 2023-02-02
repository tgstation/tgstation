/// Allocates a new Human, and equips them with the given tank type and a breathing tube.
/datum/unit_test/breath_sanity/proc/equip_labrat(/mob/living/carbon/human/lab_rat, /obj/item/tank/internals/tank_type)
	var/obj/item/clothing/mask/breath/tube = allocate(/obj/item/clothing/mask/breath)
	var/obj/item/tank/internals/emergency_oxygen/source = allocate(tank_type)
	lab_rat.equip_to_slot_if_possible(tube, ITEM_SLOT_MASK)
	lab_rat.equip_to_slot_if_possible(source, ITEM_SLOT_HANDS)
	return source

/// Tests to make sure humans can breath in normal situations
/// Built to prevent regression on an issue surrounding QUANTIZE() and BREATH_VOLUME
/// See the comment on BREATH_VOLUME for more details
/datum/unit_test/breath_sanity/Run()
	// Test internals breathing.
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/tank/internals/source = equip_labrat(lab_rat, /obj/item/tank/internals/emergency_oxygen)
	if(!source.toggle_internals() || !lab_rat.internal)
		TEST_FAIL("toggle_internals() failed to open internals.")
		return

	lab_rat.breathe()
	TEST_ASSERT(!lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Humans can't get a full breath from standard o2 tanks")
	lab_rat.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	// Test turning internals off.
	if(!lab_rat.toggle_internals() || lab_rat.internal)
		TEST_FAIL("toggle_internals() failed to close internals")

	// Test empty internals suffocation.
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	source = equip_labrat(lab_rat, /obj/item/tank/internals/emergency_oxygen/empty)
	source.toggle_internals()
	lab_rat.breathe()
	TEST_ASSERT(lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Humans can't suffocate from empty o2 tanks")

	// Test Nitrogen internals suffocation.
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	source = equip_labrat(lab_rat, /obj/item/tank/internals/emergency_oxygen/empty)
	source.air_contents.assert_gas(/datum/gas/nitrogen)
	source.air_contents.gases[/datum/gas/nitrogen][MOLES] = (10 * ONE_ATMOSPHERE) *  source.volume / (R_IDEAL_GAS_EQUATION * T20C)
	source.toggle_internals()
	lab_rat.breathe()
	TEST_ASSERT(lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Humans can't suffocate from n2 tanks")

	// Test turf breathing.
	lab_rat = allocate(/mob/living/carbon/human/consistent)
	lab_rat.forceMove(run_loc_floor_bottom_left)
	var/turf/open/to_fill = run_loc_floor_bottom_left
	//Prep the floor
	to_fill.initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	to_fill.air = to_fill.create_gas_mixture()
	lab_rat.breathe()
	TEST_ASSERT(!lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Humans can't get a full breath from the standard initial_gas_mix on a turf")

/// Tests to make sure plasmaman can breath from their internal tanks
/datum/unit_test/breath_sanity/breath_sanity_plasmamen/Run()
	var/mob/living/carbon/human/species/plasma/lab_rat = allocate(/mob/living/carbon/human/species/plasma)
	var/obj/item/clothing/mask/breath/tube = allocate(/obj/item/clothing/mask/breath)
	var/obj/item/tank/internals/plasmaman/source = allocate(/obj/item/tank/internals/plasmaman)

	lab_rat.equip_to_slot_if_possible(tube, ITEM_SLOT_MASK)
	lab_rat.equip_to_slot_if_possible(source, ITEM_SLOT_HANDS)
	source.toggle_internals(lab_rat)

	lab_rat.breathe()

	TEST_ASSERT(!lab_rat.has_alert(ALERT_NOT_ENOUGH_PLASMA), "Plasmamen can't get a full breath from a standard plasma tank")
	lab_rat.clear_alert(ALERT_NOT_ENOUGH_PLASMA)

	//Prep the mob
	source.toggle_internals(lab_rat)
	TEST_ASSERT(!lab_rat.internal, "Plasmaman toggle_internals() failed to toggle internals")

/// Tests to make sure ashwalkers can breath from the lavaland air
/datum/unit_test/breath_sanity/breath_sanity_ashwalker/Run()
	var/mob/living/carbon/human/species/lizard/ashwalker/lab_rat = allocate(/mob/living/carbon/human/species/lizard/ashwalker)

	//Prep the mob
	lab_rat.forceMove(run_loc_floor_bottom_left)

	var/turf/open/to_fill = run_loc_floor_bottom_left
	//Prep the floor
	to_fill.initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	to_fill.air = to_fill.create_gas_mixture()

	lab_rat.breathe()

	TEST_ASSERT(!lab_rat.has_alert(ALERT_NOT_ENOUGH_OXYGEN), "Ashwalkers can't get a full breath from the Lavaland's initial_gas_mix on a turf")

/datum/unit_test/breath_sanity/breath_sanity_ashwalker/Destroy()
	//Reset initial_gas_mix to avoid future issues on other tests
	var/turf/open/to_fill = run_loc_floor_bottom_left
	to_fill.initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	return ..()
