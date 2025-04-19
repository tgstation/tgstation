/// Computer which starts the experimental cloning process
/obj/machinery/computer/experimental_cloner
	name = "experimental cloner control console"
	desc = "It scans DNA structures."
	circuit = /obj/item/circuitboard/computer/experimental_cloner
	icon_screen = "crew"
	icon_keyboard = "med_key"
	light_color = LIGHT_COLOR_GREEN
	/// Our current stored cloning record
	var/datum/experimental_cloning_record/stored_record
	/// Scanner we save a test subject from
	var/obj/machinery/experimental_cloner_scanner/input
	/// Pod we print someone into
	var/obj/machinery/experimental_cloner/output
