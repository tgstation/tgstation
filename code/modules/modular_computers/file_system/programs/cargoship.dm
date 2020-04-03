/datum/computer_file/program/shipping
	filename = "shipping"
	filedesc = "Nanotrasen Ship Scanner"
	program_icon_state = "tags"
	extended_desc = "A combination printer/scanner app that enables modular computers to print barcodes for easy scanning and shipping."
	network_destination = "ship scanner"
	size = 6
	tgui_id = "ntos_shipping"
	ui_x = 450
	ui_y = 450
	///Account used for creating barcodes.
	var/datum/bank_account/payments_acc
	///The amount which the tagger will recieve for the sale.
	var/percent_cut = 20


/datum/computer_file/program/shipping/ui_data(mob/user)
	var/list/data = get_header_data()
	var/obj/item/computer_hardware/card_slot/card_slot

	if(computer)
		var/obj/item/card/id/id_card
		card_slot = computer.all_components[MC_CARD]
		data["have_id_slot"] = card_slot
		if(card_slot)
			id_card = card_slot.stored_card
		data["has_id"] = !!id_card
		data["card_owner"] = id_card.registered_name ? id_card.registered_name : "No Card Inserted."
	if(payments_acc)
		data["logged_user"] = payments_acc.account_holder ? payments_acc.account_holder : "N/A"

	return data

/datum/computer_file/program/shipping/ui_act(action, list/params)
	if(..())
		return TRUE
	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/printer/printer
	var/mob/user = usr
	if(computer)
		card_slot = computer.all_components[MC_CARD]
		printer = computer.all_components[MC_PRINT]
		if(!card_slot || !printer) //We need both to successfully use this app.
			return
	var/obj/item/card/id/id_card = card_slot.stored_card

	switch(action)
		if("ejectid")
			if(!computer || !card_slot)
				return
			if(id_card)
				card_slot.try_eject(TRUE, user)
		if("selectid")
			payments_acc = id_card.registered_account
			playsound(get_turf(ui_host()), 'sound/machines/ping.ogg', 50, TRUE, -1)
		if("resetid")
			payments_acc = null
		if("print")
			if(!printer)
				to_chat(usr, "<span class='notice'>Hardware error: A printer is required to print barcodes.</span>")
				return
			if(printer.stored_paper <= 0)
				to_chat(usr, "<span class='notice'>Hardware error: Printer is out of paper.</span>")
				return
			var/obj/item/barcode/barcode = new /obj/item/barcode(get_turf(ui_host()))
			barcode.payments_acc = payments_acc
			barcode.percent_cut = percent_cut
			printer.stored_paper -= 1
			to_chat(usr, "<span class='notice'>The computer prints out a barcode.</span>")
	return
