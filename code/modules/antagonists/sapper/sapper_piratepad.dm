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
	for(var/obj/item/holochip/monay in get_turf(pad))
		export_item_and_contents(monay, apply_elastic = FALSE, dry_run = dry_run, delete_unsold = FALSE, external_report = report, ignore_typecache = nosell_typecache, export_market = EXPORT_MARKET_PIRACY)
	return report
