/*
	RCD UI style.
	N3X15 wrote the stylesheet (originally RPD stylesheet)
	Made into a htmli datum by PJB3005
*/

/datum/html_interface/rcd
	default_html_file = 'html_interface_no_bootstrap.html'

/datum/html_interface/rcd/New()
	. = ..()
	head += "<link rel='stylesheet' type='text/css' href='RCD.css'>"

/datum/html_interface/rcd/sendResources(var/client/client)
	. = ..()
	client << browse_rsc('RCD.css')

	//Send the icons.
	for(var/path in typesof(/datum/rcd_schematic) - /datum/rcd_schematic)
		var/datum/rcd_schematic/C = new path()
		C.send_icons(client)
