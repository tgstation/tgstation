#define PRINTER_TIMEOUT 10

/obj/machinery/computer/bounty
	name = "Bounty console"
	desc = "Used to check and claim bounties offered by Nanotrasen"
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty
	light_color = "#E2853D"//orange
	var/printer_ready = 0 //cooldown var
	var/subverted = FALSE
	var/state = STATE_DEFAULT
	var/const/STATE_DEFAULT = 1
	var/const/STATE_SYNDICATE_CONTRACTS = 2

/obj/machinery/computer/bounty/Initialize()
	. = ..()
	printer_ready = world.time + PRINTER_TIMEOUT

	var/obj/item/circuitboard/computer/bounty/board = circuit
	subverted = board.subverted
	if (board.obj_flags & EMAGGED)
		obj_flags |= EMAGGED
	else
		obj_flags &= ~EMAGGED

/obj/machinery/computer/bounty/proc/print_paper()
	new /obj/item/paper/bounty_printout(loc)

/obj/item/paper/bounty_printout
	name = "paper - Bounties"

/obj/item/paper/bounty_printout/Initialize()
	. = ..()
	info = "<h2>Nanotrasen Cargo Bounties</h2></br>"
	for(var/datum/bounty/B in GLOB.bounties_list)
		if(B.claimed)
			continue
		info += "<h3>[B.name]</h3>"
		info += "<ul><li>Reward: [B.reward_string()]</li>"
		info += "<li>Completed: [B.completion_string()]</li></ul>"

/obj/machinery/computer/bounty/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!</span>",
	"<span class='notice'>You expertly work with the sequencer at the machine, connecting to the Syndicate bounty system. The computer's incompatible technology gives you limited access.</span>")

	obj_flags |= EMAGGED
	subverted = TRUE

	// This also permamently sets this on the circuit board
	var/obj/item/circuitboard/computer/bounty/board = circuit
	board.subverted = TRUE
	board.obj_flags |= EMAGGED

/obj/machinery/computer/bounty/ui_interact(mob/user)
	. = ..()
	if(!GLOB.bounties_list.len)
		setup_bounties()

	switch(state)
		if (STATE_DEFAULT)
			default_screen_state(user)
		if (STATE_SYNDICATE_CONTRACTS)
			syndicate_contract_screen_state(user)

// Default bounty state
/obj/machinery/computer/bounty/proc/default_screen_state(mob/user)
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/dat = ""

	dat += "<a href='?src=[REF(src)];refresh=1'>Refresh</a>"
	dat += "<a href='?src=[REF(src)];refresh=1;choice=Print'>Print Paper</a>"
	dat += "<p>Credits: <b>[D.account_balance]</b></p>"
	dat += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">"}
	dat += "<tr><th>Name</th><th>Description</th><th>Reward</th><th>Completion</th><th>Status</th></tr>"

	if (subverted)
		dat += syndicate_bounty_row()

	for(var/datum/bounty/B in GLOB.bounties_list)
		var/background
		if(B.can_claim())
			background = "'background-color:#4F7529;'"
		else if(B.claimed)
			background = "'background-color:#294675;'"
		else
			background = "'background-color:#990000;'"
		dat += "<tr style=[background]>"
		if(B.high_priority)
			dat += text("<td><b>[]</b></td>", B.name)
			dat += text("<td><b>High Priority:</b> []</td>", B.description)
			dat += text("<td><b>[]</b></td>", B.reward_string())
		else
			dat += text("<td>[]</td>", B.name)
			dat += text("<td>[]</td>", B.description)
			dat += text("<td>[]</td>", B.reward_string())
		dat += text("<td>[]</td>", B.completion_string())
		if(B.can_claim())
			dat += text("<td><A href='?src=[REF(src)];refresh=1;choice=Claim;d_rec=[REF(B)]'>Claim</a></td>")
		else if(B.claimed)
			dat += text("<td>Claimed</td>")
		else
			dat += text("<td>Unclaimed</td>")
		dat += "</tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "bounties", "Nanotrasen Bounties", 700, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

// Syndicate bounty state
/obj/machinery/computer/bounty/proc/syndicate_contract_screen_state(mob/user)
	var/dat = ""
	var/background = "'background-color:#4F7529;'"
	var/datum/antagonist/traitor/traitor_data = user.mind.has_antag_datum(/datum/antagonist/traitor)

	if (traitor_data)
		// Flavour text
		dat += {"<span style="text-align:center">"}
		dat += "<h1>Welcome Agent...</h1>"
		dat += "<h3>Current status: Onboard [GLOB.station_name].</h3>"
		dat += "</span>"

		dat += "<p>We've identified potentional high-value targets that are currently \
				assigned to your mission area. They are believed to hold valuable information \
				which could be of immediate importance to our organisation.</p>"

		dat += "<p>We have a list of potentional contracts for you to take on below. \
				Should you accept any, you are to bring the target to the designated drop-off, \
				and contact us via uplink. We will send a specialised extraction unit \
				to take care of the rest.</p>"

		dat += "<p>Dead or alive is of no great important, we can retrieve our intel through cloning \
				when the target is extracted, but we will provide the bonus shown if you \
				should bring them alive. Never know how memories get altered when bringing \
				them back from the dead.</p>"

		// Table creation/styling and headers
		dat += {"<table style="text-align:center;" border="2" cellspacing="0" width="100%">"}
		dat += "<tr><th>Target</th><th>Payment</th><th>Drop-Off</th><th></th></tr>"

		// Currently rolled contracts
		var/contract_id = 1
		for (var/datum/syndicate_contract/synd_contract in traitor_data.assigned_contracts)
			dat += "<tr style=[background]>"
			dat += text("<td>[]</td>", synd_contract.contract.target)
			dat += text("<td>[](+[synd_contract.contract.payout_bonus]) TC</td>", synd_contract.contract.payout)
			dat += text("<td>[]</td>", synd_contract.contract.dropoff)
			dat += text("<td><a href='?src=[REF(src)];accept_contract=1; contract_id=[contract_id]'>Accept</a></td>")
			dat += "</tr>"

			contract_id++

		dat += "</table>"

		dat += text("<td><a href='?src=[REF(src)];synd_bounty_logout=1'>Log Out</a></td>")

	var/datum/browser/popup = new(user, "bounties", "Syndicate Bounties", 700, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

// Syndicate contract row with an emagged computer - randomised slightly
/obj/machinery/computer/bounty/proc/syndicate_bounty_row()
	var/background
	var/dat = ""
	var/name = readable_corrupted_text("Relay 63")
	var/desc = readable_corrupted_text("Syndicate Bounty Database")
	var/reward = readable_corrupted_text("??")
	var/complete = readable_corrupted_text("((!")
	var/connect = readable_corrupted_text("Connect")
	switch(rand(1, 3))
		if(1)
			background = "'background-color:#4F7529;'"
		if(2)
			background = "'background-color:#294675;'"
		if(3)
			background = "'background-color:#990000;'"
	dat += "<tr style=[background]>"
	dat += text("<td>[]</td>", name)
	dat += text("<td>[]</td>", desc)
	dat += text("<td>[]</td>", reward)
	dat += text("<td>[]</td>", complete)
	dat += text("<td><a href='?src=[REF(src)];synd_bounty_connect=1'>[connect]</a></td>")
	dat += "</tr>"

	return dat

/obj/machinery/computer/bounty/Topic(href, href_list)
	if(..())
		return

	var/datum/antagonist/traitor/traitor_data = usr.mind.has_antag_datum(/datum/antagonist/traitor)

	switch(href_list["choice"])
		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_paper()

		if("Claim")
			var/datum/bounty/B = locate(href_list["d_rec"]) in GLOB.bounties_list
			if(B)
				B.claim()

	if(href_list["refresh"])
		playsound(src, "terminal_type", 25, 0)

	if(href_list["synd_bounty_connect"])
		playsound(src, "terminal_type", 25, 0)

		if (traitor_data)
			state = STATE_SYNDICATE_CONTRACTS
		else
			to_chat(usr, "You try to connect, but the system doesn't allow access.")

	if(href_list["reroll_contract"])
		if (traitor_data)
			traitor_data.current_contract.generate()

	if(href_list["synd_bounty_logout"])
		state = STATE_DEFAULT

	updateUsrDialog()
