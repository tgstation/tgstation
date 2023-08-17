//operating computer that starts with all surgeries excluding a few like necrotic revival
/obj/machinery/computer/operating/clockwork
	name = "Clockwork Operating Computer"
	desc = "A device containing (most) of the surgery secrets of the universe."
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer"
	clockwork = TRUE
	///list of surgeries we get on Init()
	var/static/list/added_surgeries = list(/datum/surgery/advanced/lobotomy,
												/datum/surgery/advanced/pacify,
												/datum/surgery/advanced/viral_bonding,
												/datum/surgery/advanced/wing_reconstruction,
												/datum/surgery/healing/brute/upgraded/femto,
												/datum/surgery/healing/burn/upgraded/femto,
												/datum/surgery/healing/combo/upgraded/femto,
												/datum/surgery/revival)

/obj/machinery/computer/operating/clockwork/Initialize(mapload)
	. = ..()
	for(var/datum/surgery/added_surgery as anything in subtypesof(/datum/surgery))
		if(added_surgery in added_surgeries)
			advanced_surgeries |= added_surgery

	for(var/datum/surgery/added_bioware as anything in subtypesof(/datum/surgery/advanced/bioware)) //cant do a check in loop one due to not making instances
		advanced_surgeries |= added_bioware
