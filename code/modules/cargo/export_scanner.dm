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
		user << "<span class='notice'>You had to link it to supply console for it to work.</span>"

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
		var/exported = FALSE
		for(var/a in supply.exports)
			var/datum/export/E = a
			if(E.applies_to(O, cargo_console.contraband, cargo_console.emagged))
				var/cost = E.get_cost(O, cargo_console.contraband, cargo_console.emagged)
				user << "<span class='notice'>Export cost: [cost] credits.</span>"
				if(is_type_in_list(O, supply.storage_objects) && O.contents.len)
					user << "<span class='notice'>(contents not included)</span>"
				exported = TRUE
				break
		if(!exported)
			user << "<span class='notice'>The object is unexportable.</span>"