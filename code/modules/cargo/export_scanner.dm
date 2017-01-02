/obj/item/device/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports database."
	icon_state = "export_scanner"
	item_state = "radio"
	flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/obj/machinery/computer/cargo/cargo_console = null

/obj/item/device/export_scanner/examine(user)
	..()
	if(!cargo_console)
		user << "<span class='notice'>The [src] is currently not linked to a cargo console.</span>"

/obj/item/device/export_scanner/afterattack(obj/O, mob/user, proximity)
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/cargo))
		var/obj/machinery/computer/cargo/C = O
		if(!C.requestonly)
			cargo_console = C
			user << "<span class='notice'>Scanner linked to [C].</span>"
	else if(!istype(cargo_console))
		user << "<span class='warning'>You must link [src] to a cargo console first!</span>"
	else
		// Before you fix it:
		// yes, checking manifests is a part of intended functionality.
		var/price = export_item_and_contents(O, cargo_console.contraband, cargo_console.emagged, dry_run=TRUE)

		if(price)
			user << "<span class='notice'>Scanned [O], value: <b>[price]</b> \
				credits[O.contents.len ? " (contents included)" : ""].</span>"
		else
			user << "<span class='warning'>Scanned [O], no export value. \
				</span>"
