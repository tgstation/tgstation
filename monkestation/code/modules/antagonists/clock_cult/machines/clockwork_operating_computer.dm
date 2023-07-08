//operating computer that starts with all surgeries excluding a few like necrotic revival
/obj/machinery/computer/operating/clockwork
	name = "Clockwork Operating Computer"
	desc = "A device containing (most) of the surgery secrets of the universe."
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer"
	clockwork = TRUE
	///list of surgeries we dont get on Init()
	var/static/list/restricted_surgeries = list(/datum/surgery/advanced/necrotic_revival,
												/datum/surgery/advanced/brainwashing,
												/datum/surgery/advanced/brainwashing_sleeper) //no getting around conversion limits for you, might also want to add bioware to this list

/obj/machinery/computer/operating/clockwork/Initialize(mapload)
	. = ..()
	for(var/datum/surgery/added_surgery as anything in subtypesof(/datum/surgery))
		if(added_surgery in restricted_surgeries || !initial(added_surgery.requires_tech))
			continue
		advanced_surgeries |= added_surgery

//need to check syncing to R&D
