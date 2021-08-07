/datum/computer_file/program/shipping
	filename = "shipping"
	filedesc = "GrandArk Exporter"
	category = PROGRAM_CATEGORY_SUPL
	program_icon_state = "shipping"
	extended_desc = "A combination printer/scanner app that enables modular computers to print barcodes for easy scanning and shipping."
	size = 6
	tgui_id = "NtosShipping"
	program_icon = "tags"
	///Account used for creating barcodes.
	var/datum/bank_account/payments_acc
	///The person who tagged this will receive the sale value multiplied by this number.
	var/cut_multiplier = 0.5
	///Maximum value for cut_multiplier.
	var/cut_max = 0.5
	///Minimum value for cut_multiplier.
	var/cut_min = 0.01

/datum/computer_file/program/shipping/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	var/obj/item/card/id/id_card = card_slot ? card_slot.stored_card : null
	data["has_id_slot"] = !!card_slot
	data["has_printer"] = !!printer
	data["paperamt"] = printer ? "[printer.stored_paper] / [printer.max_paper]" : null
	data["card_owner"] = card_slot?.stored_card ? id_card.registered_name : "No Card Inserted."
	data["current_user"] = payments_acc ? payments_acc.account_holder : null
	data["barcode_split"] = cut_multiplier * 100
	return data

/datum/computer_file/program/shipping/ui_act(action, list/params)
	. = ..()
	if(.)
		return
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
				card_slot.try_eject(usr, TRUE)
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
			var/potential_cut = input("How much would you like to pay out to the registered card?","Percentage Profit ([round(cut_min*100)]% - [round(cut_max*100)]%)") as num|null
			cut_multiplier = potential_cut ? clamp(round(potential_cut/100, cut_min), cut_min, cut_max) : initial(cut_multiplier)
		if("print")
			if(!printer)
				to_chat(usr, span_notice("Hardware error: A printer is required to print barcodes."))
				return
			if(printer.stored_paper <= 0)
				to_chat(usr, span_notice("Hardware error: Printer is out of paper."))
				return
			if(!payments_acc)
				to_chat(usr, span_notice("Software error: Please set a current user first."))
				return
			var/obj/item/barcode/barcode = new /obj/item/barcode(get_turf(ui_host()))
			barcode.payments_acc = payments_acc
			barcode.cut_multiplier = cut_multiplier
			printer.stored_paper--
			to_chat(usr, span_notice("The computer prints out a barcode."))
