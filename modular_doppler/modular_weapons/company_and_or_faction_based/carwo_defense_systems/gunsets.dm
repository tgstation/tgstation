// Base yellow carwo case

/obj/item/storage/toolbox/guncase/modular/carwo_large_case
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely."

	icon = 'modular_doppler/modular_weapons/icons/obj/gunsets.dmi'
	icon_state = "case_carwo"

	worn_icon_state = "yellowcase"

	lefthand_file = 'modular_doppler/modular_weapons/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_weapons/icons/mob/inhands/cases_righthand.dmi'
	inhand_icon_state = "yellowcase"

// Empty version of the case

/obj/item/storage/toolbox/guncase/modular/carwo_large_case/empty

/obj/item/storage/toolbox/guncase/modular/carwo_large_case/empty/PopulateContents()
	return
