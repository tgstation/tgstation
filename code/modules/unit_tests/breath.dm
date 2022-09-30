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



