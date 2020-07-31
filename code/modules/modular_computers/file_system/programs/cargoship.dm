/datum/computer_file/program/shipping
	filename = "shipping"
	filedesc = "Nanotrasen Shipping Scanner"
	program_icon_state = "shipping"
	extended_desc = "A combination printer/scanner app that enables modular computers to print barcodes for easy scanning and shipping."
	network_destination = "ship scanner"
	size = 6
	tgui_id = "NtosShipping"
	///Account used for creating barcodes.
	var/datum/bank_account/payments_acc
	///The amount which the tagger will receive for the sale.
	var/percent_cut = 20

/datum/computer_file/program/shipping/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	var/obj/item/card/id/id_card = card_slot ? card_slot.stored_card : null
	data["has_id_slot"] = !!card_slot
	data["has_printer"] = !!printer
	data["paperamt"] = printer ? "[printer.stored_paper] / [printer.max_paper]" : null
	data["card_owner"] = card_slot && card_slot.stored_card ? id_card.registered_name : "No Card Inserted."
	data["current_user"] = payments_acc ? payments_acc.account_holder : null
	data["barcode_split"] = percent_cut
	return data

/datum/computer_file/program/shipping/ui_act(action, list/params)
	if(..())
		return TRUE
	if(!computer)
		return

	// Get components
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	var/obj/item/card/id/id_card = card_slot ? card_slot.stored_card : null
	if(!card_slot || !printer) //We need both to successfully use this app.
		return

	switch(action)
		if("ejectid")
			if(id_card)
				card_slot.try_eject(TRUE, usr)
		if("selectid")
			if(!id_card)
				return
			if(!id_card.registered_account)
				playsound(get_turf(ui_host()), 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
				return
			payments_acc = id_card.registered_account
			playsound(get_turf(ui_host()), 'sound/machines/ping.ogg', 50, TRUE, -1)
		if("resetid")
			payments_acc = null
		if("setsplit")
			var/potential_cut = input("How much would you like to payout to the registered card?","Percentage Profit") as num|null
			percent_cut = potential_cut ? clamp(round(potential_cut, 1), 1, 50) : 20
		if("print")
			if(!printer)
				to_chat(usr, "<span class='notice'>Hardware error: A printer is required to print barcodes.</span>")
				return
			if(printer.stored_paper <= 0)
				to_chat(usr, "<span class='notice'>Hardware error: Printer is out of paper.</span>")
				return
			if(!payments_acc)
				to_chat(usr, "<span class='notice'>Software error: Please set a current user first.</span>")
				return
			var/obj/item/barcode/barcode = new /obj/item/barcode(get_turf(ui_host()))
			barcode.payments_acc = payments_acc
			barcode.percent_cut = percent_cut
			printer.stored_paper--
			to_chat(usr, "<span class='notice'>The computer prints out a barcode.</span>")
