/obj/item/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports database."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL

/obj/item/export_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	// Before you fix it:
	// yes, checking manifests is a part of intended functionality.
	var/datum/export_report/ex = export_item_and_contents(O, dry_run=TRUE)
	var/price = 0
	for(var/x in ex.total_amount)
		price += ex.total_value[x]
	if(price)
		to_chat(user, "<span class='notice'>Scanned [O], value: <b>[price]</b> credits[O.contents.len ? " (contents included)" : ""].</span>")
	else
		to_chat(user, "<span class='warning'>Scanned [O], no export value.</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/scan_man = user
		if(istype(O, /obj/item/bounty_cube))
			var/obj/item/bounty_cube/cube = O

			if(!istype(get_area(cube), /area/shuttle/supply))
				to_chat(user, "<span class='notice'>Shuttle placement not detected, handling tip not registered.</span>")

			else if(scan_man.get_bank_account() && cube.GetComponent(/datum/component/pricetag))
				var/datum/component/pricetag/pricetag = cube.GetComponent(/datum/component/pricetag)
				var/maximum_payee_cut = cube.holder_cut + cube.handler_cut

				//if the payee isn't listed or their current cut is less than the maximum cut, give them the handler cut
				if(!pricetag.payees[scan_man.get_bank_account()] || pricetag.payees[scan_man.get_bank_account()] < maximum_payee_cut)
					pricetag.payees[scan_man.get_bank_account()] += cube.handler_cut

				cube.bounty_handler_account = scan_man.get_bank_account()
				to_chat(user, "<span class='notice'>Bank account for [price ? "<b>[price]</b> credit " : ""]handling tip successfully registered.</span>")

			else
				to_chat(user, "<span class='notice'>Bank account not detected, handling tip not registered.</span>")
