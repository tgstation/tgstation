/// Tests to make sure humans can breath in normal situations
/// Built to prevent regression on an issue surrounding QUANTIZE() and BREATH_VOLUME
/// See the comment on BREATH_VOLUME for more details
/datum/unit_test/breath_sanity

/datum/unit_test/breath_sanity/Run()
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/mask/breath/tube = allocate(/obj/item/clothing/mask/breath)
	var/obj/item/tank/internals/emergency_oxygen/source = allocate(/obj/item/tank/internals/emergency_oxygen)

	lab_rat.equip_to_slot_if_possible(tube, ITEM_SLOT_MASK)
	lab_rat.equip_to_slot_if_possible(source, ITEM_SLOT_HANDS)
	source.toggle_internals(lab_rat)

	lab_rat.breathe()

	TEST_ASSERT(!lab_rat.has_alert("not_enough_oxy"), "Humans can't get a full breath from standard o2 tanks")
	lab_rat.clear_alert("not_enough_oxy")

	//Prep the mob
	lab_rat.forceMove(run_loc_floor_bottom_left)
	source.toggle_internals(lab_rat)
	TEST_ASSERT(!lab_rat.internal, "toggle_internals() failed to toggle internals")

	var/turf/open/to_fill = run_loc_floor_bottom_left
	//Prep the floor
	to_fill.initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	to_fill.air = new
	to_fill.air.copy_from_turf(to_fill)

	lab_rat.breathe()

	TEST_ASSERT(!lab_rat.has_alert("not_enough_oxy"), "Humans can't get a full breath from the standard initial_gas_mix on a turf")

/// Tests to make sure plasmaman can breath from their internal tanks
/datum/unit_test/breath_sanity_plasmamen

/datum/unit_test/breath_sanity_plasmamen/Run()
	var/mob/living/carbon/human/species/plasma/lab_rat = allocate(/mob/living/carbon/human/species/plasma)
	var/obj/item/clothing/mask/breath/tube = allocate(/obj/item/clothing/mask/breath)
	var/obj/item/tank/internals/plasmaman/source = allocate(/obj/item/tank/internals/plasmaman)

	lab_rat.equip_to_slot_if_possible(tube, ITEM_SLOT_MASK)
	lab_rat.equip_to_slot_if_possible(source, ITEM_SLOT_HANDS)
	source.toggle_internals(lab_rat)

	lab_rat.breathe()

	TEST_ASSERT(!lab_rat.has_alert("not_enough_plas"), "Plasmamen can't get a full breath from a standard plasma tank")
	lab_rat.clear_alert("not_enough_plas")

	//Prep the mob
	source.toggle_internals(lab_rat)
	TEST_ASSERT(!lab_rat.internal, "Plasmaman toggle_internals() failed to toggle internals")

/// Tests to make sure ashwalkers can breath from the lavaland air
/datum/unit_test/breath_sanity_ashwalker

/datum/unit_test/breath_sanity_ashwalker/Run()
	var/mob/living/carbon/human/species/lizard/ashwalker/lab_rat = allocate(/mob/living/carbon/human/species/lizard/ashwalker)

	//Prep the mob
	lab_rat.forceMove(run_loc_floor_bottom_left)

	var/turf/open/to_fill = run_loc_floor_bottom_left
	//Prep the floor
	to_fill.initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	to_fill.air = new
	to_fill.air.copy_from_turf(to_fill)

	lab_rat.breathe()

	TEST_ASSERT(!lab_rat.has_alert("not_enough_oxy"), "Ashwalkers can't get a full breath from the Lavaland's initial_gas_mix on a turf")

/datum/unit_test/breath_sanity_ashwalker/Destroy()
	//Reset initial_gas_mix to avoid future issues on other tests
	var/turf/open/to_fill = run_loc_floor_bottom_left
	to_fill.initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	return ..()
