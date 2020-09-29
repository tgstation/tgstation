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
		allowed_experiments = list(/datum/experiment/scanning), \
		blacklisted_experiments = list(/datum/experiment/scanning/destructive))

/obj/item/experi_scanner/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if (!proximity)
		return
	var/actionable = SEND_SIGNAL(src, COMSIG_EXP_CHECK_ACTIONABLE, target)
	if ((actionable & COMPONENT_EXP_ACTIONABLE) && do_after(user, 10, target = target))
		var/outcome = SEND_SIGNAL(src, COMSIG_EXP_ACTION, target)
		if (outcome & COMPONENT_EXP_SUCCESS)
			playsound(user, 'sound/machines/ping.ogg', 25)
			to_chat(user, "<span>You scan \the [target.name].</span>")

