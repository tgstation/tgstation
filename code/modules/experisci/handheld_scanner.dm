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
	item_state = "analyzer"

/obj/item/experi_scanner/Initialize()
	. = ..()
	AddComponent(/datum/component/experiment_handler,
		_allowedExperiments = list(/datum/experiment/scanning),
		_blacklistedExperiments = list(/datum/experiment/scanning/destructive))

/obj/item/experi_scanner/attack_self(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_EXPERIMENT_CONFIGURE, user)
