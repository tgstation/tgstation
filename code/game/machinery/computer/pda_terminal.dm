/obj/machinery/computer/pda_terminal
	name = "\improper PDA Terminal"
	desc = "It can be used to download Apps on your PDA."
	icon_state = "pdaterm"
	circuit = "/obj/item/weapon/circuitboard/pda_terminal"
	l_color = "#993300"

	var/obj/item/device/pda/pda_device = null

	var/obj/machinery/account_database/linked_db
	var/datum/money_account/linked_account

/obj/machinery/computer/pda_terminal/New()
	..()
	reconnect_database()
	linked_account = vendor_account

/obj/machinery/computer/pda_terminal/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in world)
		// FIXME: If we're on asteroid z-level, use whatever's on the station. - N3X
		if(DB.z == src.z || (src.z == ASTEROID_Z && DB.z == STATION_Z))
			linked_db = DB
			break

/obj/machinery/computer/pda_terminal/proc/format_apps(var/obj/item/device/pda/pda_hardware)//makes a list of all the apps that aren't yet installed on the PDA
	if(!istype(pda_hardware))
		return list()

	var/list/formatted = list()

	var/list/notinstalled = list()

	for(var/app in (typesof(/datum/pda_app) - /datum/pda_app))
		if(!(locate(app) in pda_hardware.applications))
			notinstalled += app

	for(var/app in notinstalled)
		var/datum/pda_app/appli = new app()
		formatted.Add(list(list(
			"app" = get_app_name(appli),
			"app_name" = get_display_name(appli),
			"app_desc" = get_display_desc(appli),
			)))

	return formatted

/obj/machinery/computer/pda_terminal/proc/get_app_name(var/datum/pda_app/app)
	return "[app.name]"

/obj/machinery/computer/pda_terminal/proc/get_display_name(var/datum/pda_app/app)
	return "[app.name] ([!(app.price) ? "free" : "[app.price]$"])"

/obj/machinery/computer/pda_terminal/proc/get_display_desc(var/datum/pda_app/app)
	return "[app.desc]"

/obj/machinery/computer/pda_terminal/verb/eject_pda()
	set category = "Object"
	set name = "Eject PDA"
	set src in oview(1)

	if(!usr || usr.stat || usr.lying)	return

	if(pda_device)
		usr << "You remove \the [pda_device] from \the [src]."
		pda_device.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(pda_device)
		pda_device = null
		update_icon()
	else
		usr << "There is nothing to remove from the console."
	return

/obj/machinery/computer/pda_terminal/attackby(obj/item/device/pda/user_pda, mob/user)
	if(!istype(user_pda))
		return ..()

	if(!pda_device)
		user.drop_item()
		user_pda.loc = src
		pda_device = user_pda
		update_icon()

	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/pda_terminal/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/pda_terminal/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/pda_terminal/attack_hand(var/mob/user)
	if(..()) return
	if(stat & (NOPOWER|BROKEN)) return
	ui_interact(user)

/obj/machinery/computer/pda_terminal/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null)
	user.set_machine(src)

	var/data[0]
	data["src"] = "\ref[src]"
	data["pda_name"] = pda_device ? pda_device.name : "-----"
	data["pda_owner"] = pda_device && pda_device.owner ? pda_device.owner : "Unknown"
	data["has_pda_device"] = !!pda_device
	data["pda_apps"] = format_apps(pda_device)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "pda_terminal.tmpl", src.name, 800, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/pda_terminal/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["choice"])
		if ("pda_device")
			if (pda_device)
				if(ishuman(usr))
					pda_device.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(pda_device)
					pda_device = null
				else
					pda_device.loc = loc
					pda_device = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/device/pda))
					usr.drop_item()
					I.loc = src
					pda_device = I
			update_icon()

		if ("purchase")
			if (pda_device)
				var/app_name = href_list["chosen_app"]

				var/datum/pda_app/appdatum

				for(var/app in typesof(/datum/pda_app))
					var/datum/pda_app/A = new app
					if(A.name == app_name)
						appdatum = A
						break

				if(!appdatum)
					usr << "\icon[src]<span class='warning'>An error occured while trying to download: \"[app_name]\"</span>"
					flick("pdaterm-problem", src)
					return

				if(istype(usr, /mob/living/carbon/human))
					var/mob/living/carbon/human/H=usr
					var/obj/item/weapon/card/card = null
					var/obj/item/device/pda/pda = null

					if(pda_device.id)//we look for an ID in the inserted PDA first
						card = pda_device.id
					else if(istype(H.wear_id,/obj/item/weapon/card))
						card=H.wear_id
					else if(istype(H.get_active_hand(),/obj/item/weapon/card))
						card=H.get_active_hand()
					else if(istype(H.wear_id,/obj/item/device/pda))
						pda=H.wear_id
						if(pda.id)
							card=pda.id
					else if(istype(H.get_active_hand(),/obj/item/device/pda))
						pda=H.get_active_hand()
						if(pda.id)
							card=pda.id
					if(card)
						if (connect_account(card,appdatum))
							appdatum.onInstall(pda_device)
							usr << "\icon[pda_device]<span class='notice'>Application successfully downloaded!</span>"
							flick("pdaterm-purchase", src)
						else
							flick("pdaterm-problem", src)
					else
						usr << "\icon[src]<span class='warning'>No ID detected. Cannot proceed with the purchase.</span>"
						flick("pdaterm-problem", src)

		if ("new_pda")
			if(istype(usr, /mob/living/carbon/human))
				var/mob/living/carbon/human/H=usr
				var/obj/item/weapon/card/card = null
				var/obj/item/device/pda/pda = null

				if(pda_device && pda_device.id)//we look for an ID in the inserted PDA first
					card = pda_device.id
				else if(istype(H.wear_id,/obj/item/weapon/card))
					card=H.wear_id
				else if(istype(H.get_active_hand(),/obj/item/weapon/card))
					card=H.get_active_hand()
				else if(istype(H.wear_id,/obj/item/device/pda))
					pda=H.wear_id
					if(pda.id)
						card=pda.id
				else if(istype(H.get_active_hand(),/obj/item/device/pda))
					pda=H.get_active_hand()
					if(pda.id)
						card=pda.id
				if(card)
					if (connect_account(card,0))
						usr << "\icon[src]<span class='notice'>Enjoy your new PDA!</span>"
						flick("pdaterm-purchase", src)
						if(prob(10))
							new /obj/item/device/pda/clear(src.loc)//inserting mandatory hidden feature.
						else
							new /obj/item/device/pda(src.loc)
					else
						flick("pdaterm-problem", src)
				else
					usr << "\icon[src]<span class='warning'>No ID detected. Cannot proceed with the purchase.</span>"
					flick("pdaterm-problem", src)
	return 1

/obj/machinery/computer/pda_terminal/proc/connect_account(var/obj/item/weapon/card/W,var/appdatum)
	if(istype(W))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				return	scan_card(W,appdatum)
			else
				usr << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"
	return	0

/obj/machinery/computer/pda_terminal/proc/scan_card(var/obj/item/weapon/card/id/C,var/datum/pda_app/appdatum)
	if(istype(C))
		usr << "<span class='info'>\the [src] detects and scans the following ID: [C].</span>"
		if(linked_account)
			var/datum/money_account/D = linked_db.attempt_account_access(C.associated_account_number, 0, 2, 0) // Pin = 0, Sec level 2, PIN not required.
			if(D)
				var/transaction_amount = (appdatum ? appdatum.price : 100)//if appdatum == 0, that means we're purchasing a new PDA.
				if(transaction_amount <= D.money)

					//transfer the money
					D.money -= transaction_amount
					linked_account.money += transaction_amount

					usr << "\icon[src]<span class='notice'>Remaining balance: [D.money]$</span>"

					//create entries in the two account transaction logs
					var/datum/transaction/T = new()
					T.target_name = "[linked_account.owner_name] (via [src.name])"
					T.purpose = "Purchase of [appdatum ? "[appdatum.name]" : "a new PDA"]"
					T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					D.transaction_log.Add(T)
					//
					T = new()
					T.target_name = D.owner_name
					T.purpose = "Purchase of [appdatum ? "[appdatum.name]" : "a new PDA"]"
					T.amount = "[transaction_amount]"
					T.source_terminal = src.name
					T.date = current_date_string
					T.time = worldtime2text()
					linked_account.transaction_log.Add(T)

					return 1

				else
					usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
					return 0
			else
				usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"
				return 0
		else
			usr << "\icon[src]<span class='warning'>EFTPOS is not connected to an account.</span>"
			return 0

/obj/machinery/computer/pda_terminal/update_icon()
	..()
	overlays = 0
	if(pda_device)
		overlays += "pdaterm-full"
		if(stat == 0)
			overlays += "pdaterm-light"
