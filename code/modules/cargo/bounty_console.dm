#define PRINTER_TIMEOUT 10

/obj/machinery/computer/bounty
	name = "Nanotrasen bounty console"
	desc = "Used to check and claim bounties offered by Nanotrasen"
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty
	light_color = "#E2853D"//orange
	var/printer_ready = 0 //cooldown var

/obj/machinery/computer/bounty/Initialize()
	. = ..()
	printer_ready = world.time + PRINTER_TIMEOUT

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

/obj/machinery/computer/bounty/ui_interact(mob/user)
	. = ..()

	if(!GLOB.bounties_list.len)
		setup_bounties()

	var/dat = ""
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	dat += "<a href='?src=[REF(src)];refresh=1'>Refresh</a>"
	dat += "<a href='?src=[REF(src)];refresh=1;choice=Print'>Print Paper</a>"
	dat += "<p>Credits: <b>[D.account_balance]</b></p>"
	dat += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">"}
	dat += "<tr><th>Name</th><th>Description</th><th>Reward</th><th>Completion</th><th>Status</th></tr>"
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

/obj/machinery/computer/bounty/Topic(href, href_list)
	if(..())
		return

	switch(href_list["choice"])
		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_paper()

		if("Claim")
			var/datum/bounty/B = locate(href_list["d_rec"])
			if(B in GLOB.bounties_list)
				B.claim()

	if(href_list["refresh"])
		playsound(src, "terminal_type", 25, 0)

	updateUsrDialog()

