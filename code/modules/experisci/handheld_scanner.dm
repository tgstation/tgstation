/**
  * # Experi-Scanner
  *
  * Handheld scanning unit to perform scanning experiments
  */
/obj/item/experi_scanner
	name = "Experi-Scanner"
	desc = "A handheld scanner used for completing the many experiments of modern science."
	icon = 'icons/obj/device.dmi'
	icon_state = "experiscanner"
	inhand_icon_state = "analyzer"

/obj/item/experi_scanner/Initialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler, \
		allowed_experiments = list(/datum/experiment/scanning, /datum/experiment/physical),\
		disallowed_traits = EXP_TRAIT_DESTRUCTIVE)

