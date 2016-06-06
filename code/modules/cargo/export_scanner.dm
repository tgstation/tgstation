/obj/item/device/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports database."
	icon_state = "export_scanner"
	item_state = "radio"
	flags = NOBLUDGEON
	w_class = 2
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
		var/obj/docking_port/mobile/supply/supply = SSshuttle.supply
		if(!supply)
			user << "<span class='warning'>Falied to connect to exports database!</span>"
			return

		user << "<span class='notice'>Scanned [O].</span>"

		// Before you fix it: yes, checking manifests is a part of intended functionality.
		var/price = export_item_and_contents(O, supply.exports, cargo_console.contraband, cargo_console.emagged, dry_run=TRUE)
	
		if(price)	
			user << "<span class='notice'>Export value: [price] \
				credits.</span>"
			if(O.contents.len)
				user << "<span class='notice'>(contents included)</span>"
