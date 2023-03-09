/datum/export/artifact_analysis_form
	cost = -CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "artifact analysis form"
	export_types = list(/obj/item/paper/fluff/analysis_form)
	allow_negative_cost = TRUE

/datum/export/artifact_analysis_form/get_cost(obj/O)
	var/obj/item/paper/fluff/analysis_form/M = O
	return 3595354

/obj/item/paper/fluff/analysis_form
	name = "analysis form"
	desc = "A paper with adhesive to attach to artifacts."

/obj/machinery/computer/artifact_printer
	name = "analysis form printing console"
	desc = "Prints analysis forms, to export artifacts to cargo. Needs toner."
	icon_screen = "artprinter"
	icon_keyboard = "mining_key"
	light_color = LIGHT_COLOR_PURPLE
	density = TRUE
	circuit = /obj/item/circuitboard/computer/artifact_printer
	use_power = IDLE_POWER_USE
	var/obj/item/toner/ink
	var/chosenorigin = ""
	var/chosentype = ""
	var/list/chosentriggers = list()
	var/cooldown_time = 5 SECONDS
	COOLDOWN_DECLARE(cooldown)

/obj/machinery/computer/artifact_printer/Initialize(mapload)
	. = ..()
	if(mapload)
		ink = new /obj/item/toner(src)

/obj/machinery/computer/artifact_printer/proc/use_ink(mob/user)
	. = TRUE
	if(!ink)
		balloon_alert(user,"no cartridge!")
		return FALSE
	if(!ink.charges)
		balloon_alert(user,"no ink!")
		return FALSE
	ink.charges--
	playsound(src.loc, 'sound/machines/printer.ogg', 50, TRUE)

/obj/machinery/computer/artifact_printer/AltClick(mob/user)
	. = ..()
	remove_toner(user)

/obj/machinery/computer/artifact_printer/proc/remove_toner(mob/user)
	if(ink)
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		ink.forceMove(user.drop_location())
		user.put_in_hands(ink)
		to_chat(user, span_notice("You remove [ink] from [src]."))
		ink = null

/obj/machinery/computer/artifact_printer/attackby(obj/item/item, mob/living/user, params)
	if(!ink && istype(item, /obj/item/toner))
		if(!user.transferItemToLoc(item, src))
			return
		to_chat(user, span_notice("You install [item] into [src]."))
		ink = item
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	else
		return ..()
/obj/machinery/computer/artifact_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactPaperPrinter", name)
		ui.open()

/obj/machinery/computer/artifact_printer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("remove_toner")
			remove_toner(usr)
			return
		if("origin")
			chosenorigin = params["origin"]
			return
		if("type")
			chosentype = params["type"]
			return
		if("trigger")
			var/trig = params["trigger"]
			if(trig in chosentriggers)
				chosentriggers -= trig
			else
				chosentriggers += trig
			return

/obj/machinery/computer/artifact_printer/ui_static_data(mob/user)
	. = ..()
	.["allorigins"] = SSartifacts.artifact_origins_names
	.["alltypes"] = SSartifacts.artifact_type_names
	.["alltriggers"] = SSartifacts.artifact_trigger_names
	return

/obj/machinery/computer/artifact_printer/ui_data(mob/user)
	. = ..()
	.["has_toner"] = ink
	if(ink)
		.["max_toner"] = ink.max_charges
		.["current_toner"] = ink.charges
	.["chosenorigin"] = chosenorigin
	.["chosentype"] = chosentype
	.["chosentriggers"] = chosentriggers
	.["cant_print"] = (!ink || !COOLDOWN_FINISHED(src,cooldown))
	return .