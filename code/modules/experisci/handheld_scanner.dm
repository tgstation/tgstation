/**
  * # Experi-Scanner
  *
  * Handheld scanning unit to perform scanning experiments
  */
/obj/item/experi_scanner
	name = "Experi-Scanner"
	desc = "A handheld scanner used for completing the many experiments of modern science."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	/// Holds the desired experiment types for the scanner
	var/list/desired_experiments = list(/datum/experiment/scanning)

/obj/item/experi_scanner/Initialize()
	. = ..()
	AddComponent(/datum/component/experiment_consumer)

/obj/item/experi_scanner/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/datum/component/experiment_consumer/C = GetComponent(/datum/component/experiment_consumer)
	var/datum/experiment/scanning/e = C.selected_experiment
	if (C.linked_web && e && e.scan_atom(target))
		playsound(user, 'sound/machines/ping.ogg', 25)
		to_chat(user, "<span>You scan [target.name].</span>")

/obj/item/experi_scanner/attack_self(mob/user)
	. = ..()
	var/datum/component/experiment_consumer/C = GetComponent(/datum/component/experiment_consumer)
	C.select_experiment(user, desired_experiments)

/obj/item/experi_scanner/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, be_close=TRUE))
		return
	var/datum/component/experiment_consumer/C = GetComponent(/datum/component/experiment_consumer)
	C.select_techweb(user)
