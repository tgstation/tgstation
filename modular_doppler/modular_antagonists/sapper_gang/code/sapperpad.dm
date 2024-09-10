/obj/machinery/piratepad/sapper
	name = "credit-bank pad"
	desc = "A bluespace pad used for beaming holochips into a secure account."

/obj/machinery/computer/piratepad_control/sapper
	name = "credit-bank console"
	desc = "A computer used to scan items ready for bluespace transportation."
	icon_screen = "request"
	icon_keyboard = "power_key"

///The loop that calculates the value of stuff on a pad, or plain sell them if dry_run is FALSE.
/obj/machinery/computer/piratepad_control/sapper/pirate_export_loop(obj/machinery/piratepad/pad, dry_run = TRUE)
	var/datum/export_report/report = new
	for(var/obj/item/holochip/item_on_pad in get_turf(pad))
		export_item_and_contents(item_on_pad, apply_elastic = FALSE, dry_run = dry_run, delete_unsold = FALSE, external_report = report, ignore_typecache = nosell_typecache)
	return report

/obj/machinery/computer/piratepad_control/sapper/post_machine_initialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/sapper/pad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/piratepad/sapper))
			if(pad.cargo_hold_id == cargo_hold_id)
				pad_ref = WEAKREF(pad)
				return
	else
		var/obj/machinery/piratepad/sapper/pad = locate() in range(4, src)
		pad_ref = WEAKREF(pad)
