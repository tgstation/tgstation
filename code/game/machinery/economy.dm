/*
Contains:

	-ATMs
	-Central banking server
	-Bank accounts

*/

var/list/atms_in_world = list()
/obj/machinery/atm
	name = "automated transfer machine"
	desc = "A Nanotrasen Bank of Credit ATM, used for transferring funds to and from ID cards."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	layer = 3
	anchored = 1
	var/obj/item/weapon/card/id/id = null //ID currently in the ATM
	var/authed = 0 //If the ATM is authenticated
	var/obj/machinery/bankserver/linked_server = null //The server the ATM is controlled by

/obj/machinery/atm/examine(mob/user)
	..()
	if(emagged)
		user << "It appears to be in maintenance mode."
	if(!linked_server)
		user << "A small red LED is flashing."

/obj/machinery/atm/New()
	..()
	atms_in_world.Add(src)
	spawn(20)
		linked_server = pick(bankservers_in_world)
		if(!linked_server)
			say("Notice: No banking servers detected to link to. Remote account access will be unavailable until this is resolved.")

/obj/machinery/atm/Destroy()
	EjectId()
	atms_in_world.Remove(src)
	..()

/obj/machinery/atm/emag_act(mob/user)
	emagged = !emagged
	audible_message("<span class='warning'>BZZZZZZzzzzzzz</span>")
	user << "<span class='warning'>You [emagged ? "disable" : "enable"] [src]'s PIN authorization protocols.</span>"

/obj/machinery/atm/power_change()
	if(stat & BROKEN)
		return
	else
		if(powered())
			stat &= ~NOPOWER
		else
			icon_state = "dorm_off"
			stat |= NOPOWER
			EjectId() //If we run out of power, eject an ID if we have one

/obj/machinery/atm/attackby(obj/item/weapon/W, mob/user, params)
	if(stat & (NOPOWER|BROKEN))
		return
	if(istype(W, /obj/item/weapon/card/id) && !id && !authed)
		user.drop_item()
		user.visible_message("<span class='notice'>[user] inserts [W] into [src].</span>", \
							 "<span class='notice'>You slide the ID into [src].</span>")
		W.loc = src
		id = W
		AttemptToInterface(user)
	return

/obj/machinery/atm/attack_hand(mob/user)
	AttemptToInterface(user)

/obj/machinery/atm/proc/AttemptToInterface(mob/user)
	/*if(user.key == "Miauw")
		user.gib()
		return
	*/
	if(!ishuman(user))
		user << "<span class='warning'>[src] rejects your attempts to interface with it.</span>"
		return
	if(stat & (BROKEN|NOPOWER))
		user << "<span class='warning'>[src] seems unpowered.</span>"
		return
	if(!id)
		user << "<span class='warning'>[src] has no ID inserted.</span>"
		return
	if(!user.canUseTopic(src))
		return
	icon_state = "dorm_taken"
	if(!authed)
		if(emagged)
			say("Maintenance override detected. Welcome, [id.registered_name].")
			authed = 1
			Interface(user)
			return
		var/code
		code = (input(user, "Enter the PIN number of your ID card.", "Authentication", "[code]") as num)
		say("Validating code...")
		sleep(20)
		if(code != id.pin)
			say("Authentication denied.")
			return EjectId(user)
		else
			say("Authentication accepted. Welcome, [id.registered_name].")
			authed = 1
	Interface(user)

/obj/machinery/atm/proc/Interface(mob/user)
	if(!user.canUseTopic(src)) return
	var/list/options = list("Check Balance", "Change PIN #", "Create New Account", "Access Banking Account", "Exit")
	switch(input(user, "Please choose an action.", "ATM Interface", null) in options)
		if("Check Balance")
			if(!user.canUseTopic(src)) return
			user << "<span class='notice'>[id] currently has $[id.credits] stored.</span>"
			return Interface(user)
		if("Change PIN #")
			if(!user.canUseTopic(src)) return
			var/newPin
			newPin = (input(user, "Enter a new PIN number for your ID card.", "PIN Change", "[newPin]") as num)
			newPin = Clamp(newPin, 0001, 9999)
			say("Processing...")
			sleep(20)
			say("PIN change complete.")
			id.pin = newPin
			return Interface(user)
		if("Create New Account")
			if(!user.canUseTopic(src)) return
			if(!linked_server)
				say("No linked banking server. Online functions unavailable.")
				return Interface(user)
			var/pinToAccount = null
			var/accountId = null
			while(!accountId)
				accountId = stripped_input(user, "Enter a name for your bank account.", "Account Name", "[accountId]")
				for(var/datum/bankaccount/B in linked_server.bank_accounts)
					if(B.id == accountId)
						accountId = null
						say("Bank account name taken. Please enter new name.")
			pinToAccount = (input(user, "Enter a PIN number to access your bank account.", "Account PIN", "[pinToAccount]") as num)
			pinToAccount = Clamp(pinToAccount, 0001, 9999)
			var/datum/bankaccount/newAccount = new
			newAccount.id = accountId
			newAccount.pin = pinToAccount
			linked_server.bank_accounts.Add(newAccount)
		if("Access Banking Account")
			if(!user.canUseTopic(src)) return
			if(!linked_server)
				say("No linked banking server. Online functions unavailable.")
				return Interface(user)
			var/inputtedId = null
			var/inputtedPin = null
			inputtedId = stripped_input(user, "Enter the name of your bank account.", "Account Access", "[inputtedId]")
			var/datum/bankaccount/accountToAccess = null
			for(var/datum/bankaccount/B in linked_server.bank_accounts)
				if(B.id == inputtedId)
					accountToAccess = B
			inputtedPin = (input(user, "Enter the PIN of your bank account.", "Account Access", "[inputtedPin]") as num)
			say("Validating ID and PIN...")
			sleep(20)
			if(inputtedPin != accountToAccess.pin)
				say("PIN number mismatch. Operation aborted.")
				return Interface(user)
			say("Crediential check complete. Accessing bank account.")
			AccessBankAccount(user, accountToAccess)
		if("Exit")
			if(!user.canUseTopic(src)) return
			EjectId(user)
			say("Ejecting ID. Thank you for letting us keep your money safe.")
			return

/obj/machinery/atm/proc/AccessBankAccount(var/mob/living/carbon/human/user, var/datum/bankaccount/account)
	if(!account || !user || !ishuman(user)) return
	if(!user.canUseTopic(src)) return
	var/list/options = list("Deposit Credits from ID", "Withdraw Credits to ID", "Return to ATM")
	switch(input(user, "Please choose an action.", "ATM Interface", null) in options)
		if("Deposit Credits from ID")
			if(!user.canUseTopic(src)) return
			var/creditsToAdd = null
			creditsToAdd = (input(user, "Enter credit amount to deposit.", "Deposit Credits", "[creditsToAdd]") as num)
			if(!creditsToAdd)
				return AccessBankAccount(user, account)
			creditsToAdd = Clamp(creditsToAdd, 1, id.credits)
			account.credits += creditsToAdd
			id.credits -= creditsToAdd
			say("Deposited [creditsToAdd] credits to bank account.")
			return AccessBankAccount(user, account)
		if("Withdraw Credits to ID")
			if(!user.canUseTopic(src)) return
			var/creditsToRemove = null
			creditsToRemove = (input(user, "Enter credit amount to withdraw.", "Withdraw Credits", "[creditsToRemove]") as num)
			if(!creditsToRemove)
				return AccessBankAccount(user, account)
			creditsToRemove = Clamp(creditsToRemove, 1, account.credits)
			account.credits -= creditsToRemove
			id.credits += creditsToRemove
			say("Withdrew [creditsToRemove] credits to ID card.")
			return AccessBankAccount(user, account)
		if("Return to ATM")
			if(!user.canUseTopic(src)) return
			say("Returning to main menu.")
			return Interface(user)

/obj/machinery/atm/proc/EjectId(var/mob/living/carbon/human/user)
	if(!id)
		return
	id.loc = get_turf(src)
	if(in_range(user, src) && istype(user) && user)
		user.put_in_hands(id)
	visible_message("<span class='notice'>[id] slides out of [src].</span>")
	id = null
	if(!emagged)
		icon_state = "dorm_available"
	else
		icon_state = "dorm_inside"
	authed = 0

var/list/bankservers_in_world = list()
/obj/machinery/bankserver
	name = "central banking server"
	desc = "A hefty piece of hardware responsible for controlling commerce and credit transactions across the station. It's heavily reinforced against blunt trauma and uses an internal power source."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "comm_server"
	anchored = 1
	density = 1
	use_power = 0 //Internally powered
	var/offline = 1 //If the server is offline, digital money cannot be sent or received. Physical money still works, however, as well as money stored on IDs.
	var/list/bank_accounts = list() //The list of bank accounts currently on the server.

/obj/machinery/bankserver/power_change()
	..()
	if(stat & BROKEN)
		return
	else
		if(powered())
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]_off"
			stat |= NOPOWER

/obj/machinery/bankserver/New()
	..()
	bankservers_in_world.Add(src)

/obj/machinery/bankserver/Destroy()
	bankservers_in_world.Remove(src)
	message_admins("Banking server destroyed in [get_area(src)]")
	..()

/obj/machinery/bankserver/ex_act(severity)
	visible_message("<span class='warning'>[src]'s reinforced plating protects it from the blast!</span>")
	return

/obj/machinery/bankserver/fire_act(severity)
	return

/datum/bankaccount //Stores credits and credientials of the holder.
	var/credits = 0
	var/pin = 1234
	var/id = "Bank Account"
