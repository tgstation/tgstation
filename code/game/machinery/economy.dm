/*
Contains:

	-ATMs
	-Central banking server
	-Bank accounts

*/

/*
 * ATM's
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
	var/authenticated = FALSE // if the ID has been authenticated
	var/obj/machinery/bankserver/linked_server = null //The server the ATM is controlled by
	var/datum/html_interface/hi
	var/datum/bankaccount/current_account
	var/global/list/valid_screens = list("change_card_pin", "create_account", "switch_account", "change_account_pin", "withdraw", "deposit", "transfer")
	var/current_screen = null

/obj/machinery/atm/examine(mob/user)
	..()
	if(emagged)
		user << "It appears to be in maintenance mode."
	if(!linked_server)
		user << "A small red LED is flashing."

/obj/machinery/atm/New()
	. = ..()

	src.hi = new/datum/html_interface/nanotrasen(src, "Automated Teller Machine", 400, 600)

	src.update()

	atms_in_world.Add(src)
	spawn(20)
		linked_server = bankservers_in_world.len > 0 ? pick(bankservers_in_world) : null
		if(!linked_server)
			say("Notice: No banking servers detected to link to. Remote account access will be unavailable until this is resolved.")

/obj/machinery/atm/Destroy()
	qdel(src.hi)
	src.hi = null

	src.ejectID()
	atms_in_world.Remove(src)
	return ..()

/obj/machinery/atm/proc/validatePIN(pin)
	pin = text2num(pin)
	return pin >= 1000 && pin <= 9999

/obj/machinery/atm/Topic(href, href_list[], datum/html_interface_client/hclient)
	if (istype(hclient))
		if (hclient && hclient.client && hclient.client.mob)
			if (href_list["screen"] && (href_list["screen"] in valid_screens))
				src.current_screen = href_list["screen"]
			else
				switch (href_list["action"])
					if ("change_card_pin", "change_account_pin")
						if (src.authenticated && (href_list["action"] != "change_account_pin" || src.current_account))
							var/new_pin = text2num(href_list["pin"])

							if (src.validatePIN(new_pin))
								if (href_list["action"] == "change_account_pin")
									src.current_account.pin = new_pin
								else
									src.id.pin = new_pin

								src.current_screen = null

								alert(hclient.client, "Modification successful!")
							else
								alert(hclient.client, "Invalid PIN. A PIN must contain 4 numbers.")

					if ("create_account")
						if (src.authenticated)
							var/account_id = href_list["name"]
							var/new_pin = text2num(href_list["pin"])

							if (src.linked_server)
								if (src.validatePIN(new_pin))
									var/found = FALSE

									for (var/datum/bankaccount/B in linked_server.bank_accounts)
										if (B.id == account_id)
											found = TRUE
											break

									if (found)
										alert(hclient.client, "Bank account name taken. Please provide a different name.")
									else
										var/datum/bankaccount/new_account = new
										new_account.id  = account_id
										new_account.pin = new_pin
										linked_server.bank_accounts.Add(new_account)
										src.current_account = new_account
										src.current_screen = null

										spawn(-1) alert(hclient.client, "Account created.")
								else
									alert(hclient.client, "Invalid PIN. A PIN must contain 4 numbers.")
							else
								alert(hclient.client, "No linked banking server. Online functions unavailable.")

					if ("switch_account")
						if (src.authenticated)
							var/account_id = href_list["name"]
							var/pin = text2num(href_list["pin"])
							var/datum/bankaccount/account = null

							for (account in linked_server.bank_accounts)
								if (account.id == account_id && account.pin == pin)
									break

							if (account != null)
								src.current_account = account
								src.current_screen = null
							else
								alert(hclient.client, "Access denied. Invalid account name or PIN.")

					if ("withdraw", "deposit", "transfer")
						if (src.authenticated)
							var/amount = text2num(href_list["amount"])

							if (amount <= 0 || !isnum(amount))
								alert(hclient.client, "Invalid amount.")
							else
								if (href_list["action"] == "transfer")
									if (src.current_account)
										var/account_id = href_list["name"]
										var/datum/bankaccount/account = null

										for (account in linked_server.bank_accounts)
											if (account.id == account_id)
												break

										if (account)
											if ((account.credits + amount >= 0) && (src.current_account.credits - amount) >= 0)
												src.current_account.credits -= amount
												account.credits             += amount

												src.current_screen = null
										else
											alert(hclient.client, "Invalid account name.")
								else
									var/delta = amount

									if (href_list["action"] == "withdraw") delta = -delta

									if ((src.current_account.credits + delta) >= 0 && (src.id.credits - delta) >= 0)
										src.current_account.credits += delta
										src.id.credits              -= delta

										src.current_screen = null

					if ("authenticate")
						var/pin = href_list["pin"]

						if (src.id)
							if ("[src.id.pin]" == "[pin]")
								src.current_screen = null // sanity check: in case it was accidentally set
								src.authenticated = TRUE
							else
								alert(hclient.client, "Access denied. Invalid PIN.")

					if ("id")
						var/mob/living/carbon/human/H = hclient.client.mob
						var/obj/item/weapon/card/id/id

						if (istype(H))                 id = H.get_idcard()
						if (!id && hclient.client.mob) id = hclient.client.mob.get_active_hand()

						if (istype(id) && hclient.client.mob.remove_from_mob(id))
							hclient.client.mob.visible_message("<span class='notice'>[hclient.client.mob] inserts [id] into [src].</span>", "<span class='notice'>You slide the ID into [src].</span>")
							id.loc = src
							src.authenticated = src.emagged
							src.id = id
							icon_state = "dorm_taken"

					if ("eject_id")
						if (src.id && hclient.client.mob)
							src.ejectID(hclient.client.mob)

			src.update()

/obj/machinery/atm/proc/ejectID(var/mob/mob)
	src.id.loc = get_turf(src)

	if (mob) mob.put_in_hands(id)

	src.id              = null
	src.current_account = null
	src.current_screen  = null
	src.authenticated   = FALSE

	if(!emagged)
		icon_state = "dorm_available"
	else
		icon_state = "dorm_inside"

	src.update()

/obj/machinery/atm/proc/update()
	if (src.id == null)
		src.hi.updateContent("content", "<p>Please present your ID to use this device: <a href=\"byond://?src=\ref[src.hi]&action=id\">------</a></p>")
	else
		var/html = {"
			<table>
				<tr>
					<td>Selected account:</td><td>[src.current_account ? src.current_account.id : "<em>None selected</em>"]</td>
				</tr>
				<tr>
					<td>Balance on card:</td><td>[src.id.credits] credits</td>
				</tr>"}

		if (src.current_account)
			html += {"
				<tr>
					<td>Balance on account:</td><td>[src.current_account.credits] credits</td>
				</tr>
			"}

		html += {"
			</table>
			<br />
			<p>Commands:</p>
		"}

		if (src.authenticated)
			html += {"
				<a href=\"byond://?src=\ref[src.hi]&screen=change_card_pin\">Change card PIN</a><br />
				<a href=\"byond://?src=\ref[src.hi]&screen=create_account\">Create an account</a><br />
				<a href=\"byond://?src=\ref[src.hi]&screen=switch_account\">Switch account</a>
			"}

			if (src.current_account)
				html += {"<br />
					<a href=\"byond://?src=\ref[src.hi]&screen=change_account_pin\">Change account PIN</a><br />
					<a href=\"byond://?src=\ref[src.hi]&screen=withdraw\">Withdraw from account</a><br />
					<a href=\"byond://?src=\ref[src.hi]&screen=deposit\">Deposit into account</a><br />
					<a href=\"byond://?src=\ref[src.hi]&screen=transfer\">Make transfer</a>
				"}

		html += "<br /><a href=\"byond://?src=\ref[src.hi]&action=eject_id\">Eject ID</a>"

		if (src.authenticated)
			switch (src.current_screen)
				if ("change_card_pin")
					html += {"
						<br /><p>Specify the new PIN to continue.</p><br />
						<form action=\"byond://\" method=\"post\">
							<input type=\"hidden\" name=\"src\" value=\"\ref[src.hi]\" />
							<input type=\"hidden\" name=\"action\" value=\"change_card_pin\" />
							<input type=\"password\" name=\"pin\" /><br /><br /><button type=\"submit\" class=\"linkOff\">Change card PIN</button>
						</form>
					"}
				if ("create_account")
					html += {"
						<br /><p>Specify the desired account name and a PIN for security.</p><br />
						<form action=\"byond://\" method=\"post\">
							<input type=\"hidden\" name=\"src\" value=\"\ref[src.hi]\" />
							<input type=\"hidden\" name=\"action\" value=\"create_account\" />
							<strong>Account name:</strong><br />
							<input type=\"text\" name=\"name\" /><br /><br />
							<strong>Account PIN:</strong><br />
							<input type=\"password\" name=\"pin\" /><br /><br />
							<button type=\"submit\" class=\"linkOff\">Create account</button>
						</form>
					"}
				if ("switch_account")
					html += {"
						<br /><p>Specify the account name and the account PIN.</p><br />
						<form action=\"byond://\" method=\"post\">
							<input type=\"hidden\" name=\"src\" value=\"\ref[src.hi]\" />
							<input type=\"hidden\" name=\"action\" value=\"switch_account\" />
							<strong>Account name:</strong><br />
							<input type=\"text\" name=\"name\" /><br /><br />
							<strong>Account PIN:</strong><br />
							<input type=\"password\" name=\"pin\" /><br /><br />
							<button type=\"submit\" class=\"linkOff\">Switch to account</button>
						</form>
					"}
				else
					if (src.current_account)
						switch (src.current_screen)
							if ("change_account_pin")
								html += {"
									<br /><p>Specify the new PIN to continue.</p><br />
									<form action=\"byond://\" method=\"post\">
										<input type=\"hidden\" name=\"src\" value=\"\ref[src.hi]\" />
										<input type=\"hidden\" name=\"action\" value=\"change_account_pin\" />
										<input type=\"password\" name=\"pin\" /><br /><br /><button type=\"submit\" class=\"linkOff\">Change account PIN</button>
									</form>
								"}
							if ("withdraw", "deposit", "transfer")
								html += {"
									<br /><p>Specify the amount to [src.current_screen][src.current_screen == "transfer" ? " and the account name to transfer it to" : ""].</p><br />
									<form action=\"byond://\" method=\"post\">
										<input type=\"hidden\" name=\"src\" value=\"\ref[src.hi]\" />
										<input type=\"hidden\" name=\"action\" value=\"[src.current_screen]\" />"}

								if (src.current_screen == "transfer")
									html += "<strong>Account name:</strong><br /><input type=\"text\" name=\"name\" /><br /><br /><strong>Amount:</strong><br />"

								html += {"
										<input type="text\" name=\"amount\" name=\"amount\" /><br /><br />
										<button type=\"submit\" class=\"linkOff\">Change account PIN</button>
									</form>
								"}
		else
			html += {"
				<br /><p>Authentication required. Please provide your PIN to continue.</p><br />
				<form action=\"byond://\" method=\"post\">
					<input type=\"hidden\" name=\"src\" value=\"\ref[src.hi]\" />
					<input type=\"hidden\" name=\"action\" value=\"authenticate\" />
					<input type=\"password\" name=\"pin\" /><br /><br /><button type=\"submit\" class=\"linkOff\">Authenticate</button>
				</form>
			"}

		src.hi.updateContent("content", html)

/obj/machinery/atm/emag_act(mob/user)
	emagged = !emagged
	audible_message("<span class='warning'>BZZZZZZzzzzzzz</span>")
	user << "<span class='warning'>You [emagged ? "disable" : "enable"] [src]'s PIN authorization protocols.</span>"

/obj/machinery/atm/power_change()
	if (!(stat & BROKEN))
		if (powered())
			stat &= ~NOPOWER
		else
			icon_state = "dorm_off"
			stat |= NOPOWER
			src.ejectID() // If we run out of power, eject an ID if we have one.

/obj/machinery/atm/attackby(obj/item/weapon/W, mob/user, params)
	if(!(stat & (NOPOWER|BROKEN)) && istype(W, /obj/item/weapon/card/id) && !src.id)
		src.attack_hand(user)
		user << link("byond://?src=\ref[src.hi]&action=id")
	else
		return ..()

/obj/machinery/atm/attack_hand(mob/user)
	user.set_machine(src)
	src.hi.show(user)

/*
 * Servers
*/
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
	for(var/obj/machinery/atm/A in atms_in_world)
		if(A.linked_server == src)
			A.say("Notice: Banking server link severed. Online functions nonfunctional until link is restored.")
			A.linked_server = null
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
