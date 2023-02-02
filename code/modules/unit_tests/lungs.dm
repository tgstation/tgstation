/// WORK IN PROGRESS - DO NOT USE
/// Tests the lungs organ to ensure it processes gas correctly.
/datum/unit_test/lungs_sanity/Run()
	var/obj/item/organ/internal/lungs/test_lungs = allocate(/obj/item/organ/internal/lungs/)
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)

	// Test with normal gas mixture.
	var/datum/gas_mixture/gas_mix = allocate(/datum/gas_mixture)
	gas_mix.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	test_lungs.check_breath(gas_mix, lab_rat)
