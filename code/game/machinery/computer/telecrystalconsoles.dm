#define NUKESCALINGMODIFIER 1

GLOBAL_LIST_INIT(possible_uplinker_IDs, list("Alfa","Bravo","Charlie","Delta","Echo","Foxtrot","Zero", "Niner"))

/obj/machinery/computer/telecrystals
	name = "\improper telecrystal assignment station"
	desc = "A device used to manage telecrystals during group operations. You shouldn't be looking at this particular one..."
	icon_state = "tcstation"
	icon_keyboard = "tcstation_key"
	icon_screen = "syndie"
	clockwork = TRUE //it'd look weird, at least if ratvar ever got there
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	light_color = LIGHT_COLOR_RED

/////////////////////////////////////////////
/obj/machinery/computer/telecrystals/uplinker
	name = "\improper telecrystal upload/receive station"
	desc = "A device used to manage telecrystals during group operations. To use, simply insert your uplink. With your uplink installed \
			you can upload your telecrystals to the group's pool using the console, or be assigned additional telecrystals by your lieutenant."
	var/obj/item/uplinkholder = null
	var/obj/machinery/computer/telecrystals/boss/linkedboss = null

/obj/machinery/computer/telecrystals/uplinker/Initialize()
	..()

	var/ID = pick_n_take(GLOB.possible_uplinker_IDs)
	if(!ID)
		ID = rand(1,999)
	name = "[name] [ID]"

/obj/machinery/computer/telecrystals/uplinker/attackby(obj/item/O, mob/user, params)
	if(uplinkholder)
		to_chat(user, "<span class='notice'>The [src] already has an uplink in it.</span>")
		return
	if(O.hidden_uplink)
		var/obj/item/I = user.get_active_held_item()
		if(!user.drop_item())
			return
		uplinkholder = I
		I.loc = src
		I.add_fingerprint(user)
		update_icon()
		updateUsrDialog()
	else
		to_chat(user, "<span class='notice'>The [O] doesn't appear to be an uplink...</span>")

/obj/machinery/computer/telecrystals/uplinker/update_icon()
	..()
	if(uplinkholder)
		add_overlay("[initial(icon_state)]-closed")

/obj/machinery/computer/telecrystals/uplinker/proc/ejectuplink()
	if(uplinkholder)
		uplinkholder.loc = get_turf(src.loc)
		uplinkholder = null
		update_icon()

/obj/machinery/computer/telecrystals/uplinker/proc/donateTC(amt, addLog = 1)
	if(uplinkholder && linkedboss)
		if(amt < 0)
			linkedboss.storedcrystals += uplinkholder.hidden_uplink.telecrystals
			if(addLog)
				linkedboss.logTransfer("[src] donated [uplinkholder.hidden_uplink.telecrystals] telecrystals to [linkedboss].")
			uplinkholder.hidden_uplink.telecrystals = 0
		else if(amt <= uplinkholder.hidden_uplink.telecrystals)
			uplinkholder.hidden_uplink.telecrystals -= amt
			linkedboss.storedcrystals += amt
			if(addLog)
				linkedboss.logTransfer("[src] donated [amt] telecrystals to [linkedboss].")

/obj/machinery/computer/telecrystals/uplinker/proc/giveTC(amt, addLog = 1)
	if(uplinkholder && linkedboss)
		if(amt < 0)
			uplinkholder.hidden_uplink.telecrystals += linkedboss.storedcrystals
			if(addLog)
				linkedboss.logTransfer("[src] received [linkedboss.storedcrystals] telecrystals from [linkedboss].")
			linkedboss.storedcrystals = 0
		else if(amt <= linkedboss.storedcrystals)
			uplinkholder.hidden_uplink.telecrystals += amt
			linkedboss.storedcrystals -= amt
			if(addLog)
				linkedboss.logTransfer("[src] received [amt] telecrystals from [linkedboss].")

///////

/obj/machinery/computer/telecrystals/uplinker/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(user)
	user.set_machine(src)

	var/dat = ""
	if(linkedboss)
		dat += "[linkedboss] has [linkedboss.storedcrystals] telecrystals available for distribution. <BR><BR>"
	else
		dat += "No linked management consoles detected. Scan for uplink stations using the management console.<BR><BR>"

	if(uplinkholder)
		dat += "[uplinkholder.hidden_uplink.telecrystals] telecrystals remain in this uplink.<BR>"
		if(linkedboss)
			dat += "Donate TC: <a href='byond://?src=\ref[src];donate=1'>1</a> | <a href='byond://?src=\ref[src];donate=5'>5</a> | <a href='byond://?src=\ref[src];donate=-1'>All</a>"
		dat += "<br><a href='byond://?src=\ref[src];eject=1'>Eject Uplink</a>"


	var/datum/browser/popup = new(user, "computer", "Telecrystal Upload/Receive Station", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/telecrystals/uplinker/Topic(href, href_list)
	if(..())
		return

	if(href_list["donate"])
		var/tcamt = text2num(href_list["donate"])
		donateTC(tcamt)

	if(href_list["eject"])
		ejectuplink()

	src.updateUsrDialog()


/////////////////////////////////////////
/obj/machinery/computer/telecrystals/boss
	name = "team telecrystal management console"
	desc = "A device used to manage telecrystals during group operations. To use, simply initialize the machine by scanning for nearby uplink stations. \
	Once the consoles are linked up, you can assign any telecrystals amongst your operatives; be they donated by your agents or rationed to the squad \
	based on the danger rating of the mission."
	icon_state = "computer"
	icon_screen = "tcboss"
	icon_keyboard = "syndie_key"
	var/virgin = 1
	var/scanrange = 10
	var/storedcrystals = 0
	var/list/TCstations = list()
	var/list/transferlog = list()

/obj/machinery/computer/telecrystals/boss/proc/logTransfer(logmessage)
	transferlog += ("<b>[worldtime2text()]</b> [logmessage]")

/obj/machinery/computer/telecrystals/boss/proc/scanUplinkers()
	for(var/obj/machinery/computer/telecrystals/uplinker/A in urange(scanrange, src.loc))
		if(!A.linkedboss)
			TCstations += A
			A.linkedboss = src
	if(virgin)
		getDangerous()
		virgin = 0

/obj/machinery/computer/telecrystals/boss/proc/getDangerous()//This scales the TC assigned with the round population.
	..()
	var/danger = GLOB.joined_player_list.len - SSticker.mode.syndicates.len
	danger = Ceiling(danger, 10)
	scaleTC(danger)

/obj/machinery/computer/telecrystals/boss/proc/scaleTC(amt)//Its own proc, since it'll probably need a lot of tweaks for balance, use a fancier algorhithm, etc.
	storedcrystals += amt * NUKESCALINGMODIFIER

/////////

/obj/machinery/computer/telecrystals/boss/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(user)
	user.set_machine(src)


	var/dat = ""
	dat += "<a href='byond://?src=\ref[src];scan=1'>Scan for TC stations.</a><BR>"
	dat += "[storedcrystals] telecrystals are available for distribution. <BR>"
	dat += "<BR><BR>"


	for(var/obj/machinery/computer/telecrystals/uplinker/A in TCstations)
		dat += "[A.name] | "
		if(A.uplinkholder)
			dat += "[A.uplinkholder.hidden_uplink.telecrystals] telecrystals."
		if(storedcrystals)
			dat+= "<BR>Add TC: <a href ='?src=\ref[src];target=\ref[A];give=1'>1</a> | <a href ='?src=\ref[src];target=\ref[A];give=5'>5</a> | <a href ='?src=\ref[src];target=\ref[A];give=10'>10</a> | <a href ='?src=\ref[src];target=\ref[A];give=-1'>All</a>"
		dat += "<BR>"

	if(TCstations.len && storedcrystals)
		dat += "<BR><BR><a href='byond://?src=\ref[src];distrib=1'>Evenly distribute remaining TC.</a><BR><BR>"


	for(var/entry in transferlog)
		dat += "<small>[entry]</small><BR>"


	var/datum/browser/popup = new(user, "computer", "Team Telecrystal Management Console", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/telecrystals/boss/Topic(href, href_list)
	if(..())
		return

	if(href_list["scan"])
		scanUplinkers()

	if(href_list["give"])
		var/tcamt = text2num(href_list["give"])
		if(TCstations.len) // sanity
			var/obj/machinery/computer/telecrystals/uplinker/A = locate(href_list["target"]) in TCstations
			A.giveTC(tcamt)

	if(href_list["distrib"])
		var/sanity = 0
		while(storedcrystals && sanity < 100)
			for(var/obj/machinery/computer/telecrystals/uplinker/A in TCstations)
				A.giveTC(1,0)
			sanity++
		logTransfer("[src] evenly distributed telecrystals.")

	src.updateUsrDialog()
	return

#undef NUKESCALINGMODIFIER
