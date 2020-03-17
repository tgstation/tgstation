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
	/// Holds the desired experiment types for the scanner
	var/list/desired_experiments = list(/datum/experiment/scanning)

/obj/item/experi_scanner/Initialize()
	. = ..()
	AddComponent(/datum/component/experiment_consumer)

/obj/item/experi_scanner/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/datum/experiment/scanning/e = SEND_SIGNAL(src, COMSIG_GET_EXPERIMENT)
	if (e && e.scan_atom(target))
		playsound(user, 'sound/machines/ping.ogg', 25)
		to_chat(user, "<span>You scan [target.name].</span>")

/obj/item/experi_scanner/attack_self(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_EXPERIMENT_SELECT, user = user, experiment_types = desired_experiments)

/obj/item/experi_scanner/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, be_close=TRUE))
		return
	SEND_SIGNAL(src, COMSIG_TECHWEB_SELECT, user = user)
